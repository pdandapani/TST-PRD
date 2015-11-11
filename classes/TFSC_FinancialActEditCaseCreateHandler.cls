/**
*   @For certain profiles, when editing Financial_Account_Customer__c, we need to 
*   @ 1) disable the edit (rewrite the old value to the new).
*   @ 2) create an object (defined in a custom setting; case for example) with the new values detailed.
*   @ 3) reset the new Financial_Account_Customer__c values to the old (where applicable)
*   @This is only true for fields defined in the custom setting.  See the comments on buildMapOfMapOfCustomSettings() for more details.
*
*   
*   @Author     : Jeremy Mooer
*   @Date       : 16 May 2014
*/
public class TFSC_FinancialActEditCaseCreateHandler implements TFSC_TriggerDispatcher.Handler {
    
    public static Boolean TRIGGER_ALREADY_FIRED_IN_STACK = false;
    
    public void handle() {
        Map<Id,Financial_Account_Customer__c> newFACMap = (Map<Id,Financial_Account_Customer__c>)Trigger.newMap;
        Map<Id,Financial_Account_Customer__c> oldFACMap = (Map<Id,Financial_Account_Customer__c>)Trigger.oldMap;
        
        if(shouldExecuteFacEditingServiceRequest( (Financial_Account_Customer__c)trigger.new[0] )) {
            TFSC_FinancialActEditCaseCreateHandler.TRIGGER_ALREADY_FIRED_IN_STACK = true;
            onFacEditCreateDestinationSObjectWhereNecessary(newFACMap, oldFACMap);
        }
    }
    
    //Only profiles in Label.Profiles_to_disallow_save_on_FAC should create service requests.
    private Boolean shouldExecuteFacEditingServiceRequest(Financial_Account_Customer__c facForError) {
        
        if(TFSC_FinancialActEditCaseCreateHandler.TRIGGER_ALREADY_FIRED_IN_STACK == true) {
            return false;
        }
        
        if( TFSC_Utils.isNullOrEmpty(UserInfo.getProfileId()) || 
              TFSC_Utils.isNullOrEmpty(TFSC_Utils.getProfileNameFromProfileId(UserInfo.getProfileId())) ) {
            return false;
        }
        String usersProfileName = TFSC_Utils.getProfileNameFromProfileId(UserInfo.getProfileId());
        String delimitedProfileList = Label.Profiles_to_allow_save_on_FAC;
        
        if(delimitedProfileList == null) {
            facForError.addError( 'The Custom Label for disallowed profiles for FAC Edits has not been configured in this org.  Contact an administrator.' );
            return false;
        }
        
        String[] profileList = delimitedProfileList.split(';');
        Boolean stringInList = false;
        for(String profileName : profileList) {
            if(profileName == usersProfileName) {
                stringInList = true;
            }
        }
        
        if(stringInList) {
            return false;
        }
        
        return true;
    }
    
    
    //only call this on update.
    private void onFacEditCreateDestinationSObjectWhereNecessary(Map<Id,Financial_Account_Customer__c> newFACMap, Map<Id,Financial_Account_Customer__c> oldFACMap) 
    {
        
        Map<Id,Financial_Account_Customer__c> facsToEditForPostUpdateTrigger = buildMapOfNewFacs(newFACMap.keySet());
        Map<Id,Financial_Account_Customer__c> facsToUpdateMap = new Map<Id,Financial_Account_Customer__c>(); 
        
        //see comment on the buildMapOfMapOfCustomSettings for description of this map and how it will be used.
        Map<String, Map<String,Service_Request_Field_Map__c>> mapOfCustSettingsByTargetObjectAndSourceField;
        mapOfCustSettingsByTargetObjectAndSourceField = buildMapOfMapOfCustomSettings();
        
        List<sObject> sObjsToInsert = new List<sObject>(); //should simply be a list of 1, but if multiple sObjTypes exist in outer list, then could be > 1
        
        //FAC.Account__r.IsPersonAccount   then Case.ContactId = <FAC.Account__r.Id>
        Map<Id,Account> mapOfAccountIdToAccountRecord = buildAccountMap(newFACMap.values());
        
        
        for(Financial_Account_Customer__c fac : newFACMap.values()) {
            Financial_Account_Customer__c oldFac = oldFACMap.get(fac.Id);
            Financial_Account_Customer__c newFacForPostUpdateTrigger = facsToEditForPostUpdateTrigger.get(fac.Id);
            //there will probably only ever be one destinationSObjectName (i.e. Case or Task), so this loop will assumably only be hit one time.
            for(String destinationSObjectNameWithTypesAndGrouping : mapOfCustSettingsByTargetObjectAndSourceField.keySet()) 
            {
                String destinationSObjectName = destinationSObjectNameWithTypesAndGrouping.substring(0, destinationSObjectNameWithTypesAndGrouping.indexOf('||')) ;
                 
                sObject sObjToInsert = generateSObject(destinationSObjectName, fac, mapOfAccountIdToAccountRecord);
                if(sObjToInsert == null) { //then invalid sObjectName
                    fac.addError(destinationSObjectName + ' is not a valid sObject.  This Service_Request_Field_Map__c custom setting caused an error.  Contact your administrator with this error.');
                    continue;
                }
                
                Set<String> stringSetOfFieldsOnSObject = buildStringSetOfFieldsOnSObject(sObjToInsert);
                
                Map<String,Service_Request_Field_Map__c> childMapOfCSBySourceField;
                childMapOfCSBySourceField = mapOfCustSettingsByTargetObjectAndSourceField.get(destinationSObjectNameWithTypesAndGrouping);
                Boolean atLeastOneFieldEdited = false; //evaluates if any of the customSetting.sourceFields have been edited.
                
                for(String sourceField : childMapOfCSBySourceField.keySet()) {
                    Service_Request_Field_Map__c customSetting = childMapOfCSBySourceField.get(sourceField);
                    
                    setRecordTypeAndTypeIfNotSet(sObjToInsert, customSetting, destinationSObjectName, stringSetOfFieldsOnSObject);
                    
                    
                    //new requirement to always set all values on sobj:
                    setValueOfSObjectFieldAndResetFACValue(sObjToInsert, newFacForPostUpdateTrigger, customSetting, sourceField, oldFac, fac);
                    if( !TFSC_Utils.isNullOrEmpty(customSetting.Target_Field_Old__c) ) {
                        sObjToInsert.put(customSetting.Target_Field_Old__c, oldFac.get(sourceField));
                    }
                    //updateConsentFields(customSetting, newFacForPostUpdateTrigger, fac, oldFac, sourceField);
                    
                    
                    if( facFieldHasChanged(oldFac, fac, sourceField) ) 
                    {
                        if( destinationSObjectName == 'Case' ) {
                            setCaseFields(customSetting, sObjToInsert, fac, sourceField, oldFac, newFacForPostUpdateTrigger);
                        }
                        
                        if( !TFSC_Utils.isNullOrEmpty(customSetting.Address_Type__c) ) {
                            //currently only on case -- might need a validation to say 'sobject type = Case', but leaving here in case they want to implement this on Task, for example
                            sObjToInsert.put('Address_Type__c', customSetting.Address_Type__c);
                        }
                        
                        if( !TFSC_Utils.isNullOrEmpty(customSetting.Service_Request_Category__c) ) {
                            //currently only on case -- might need a validation to say 'sobject type = Case', but leaving here in case they want to implement this on Task, for example
                            sObjToInsert.put('Service_Request_Category__c', customSetting.Service_Request_Category__c);
                        }
                        
                        if( !TFSC_Utils.isNullOrEmpty(customSetting.Service_Result__c) ) {
                            //currently only on case -- might need a validation to say 'sobject type = Case', but leaving here in case they want to implement this on Task, for example
                            sObjToInsert.put('Service_Result__c', customSetting.Service_Result__c);
                        }
                        
                        if( !TFSC_Utils.isNullOrEmpty(customSetting.Target_Field__c) ) {
                            atLeastOneFieldEdited = true;
                            setValueOfSObjectFieldAndResetFACValue(sObjToInsert, newFacForPostUpdateTrigger, customSetting, sourceField, oldFac, fac);
                        }else{
                            fac.addError('Custom_setting Service_Request_Field_Map__c with sourceField = ' + sourceField + ' has a null target_field');
                        }
                    }
                    
                    
                }//end "FIELDS in CustomSetting" loop (for this DESTINATION-SOBJECT) 
                
                if(atLeastOneFieldEdited) {
                    // CP 2401 - This code is to have New_Mobile_Number_MOBILE__c as checked when the user updates Mobile_number__c in the generated Case
                    if(fac.get('Mobile_Phone__c') <> oldFac.get('Mobile_Phone__c') && fac.get('Flag_Mobile_Phone_IsMobile__c') == oldFac.get('Flag_Mobile_Phone_IsMobile__c')){
                        sObjToInsert.put('New_Mobile_Number_MOBILE__c', TRUE);
                    }
                               
                    //this code is here because we want to insert one sObject for each destinationSObjectName
                    sObjsToInsert.add(sObjToInsert);
                    facsToUpdateMap.put(newFacForPostUpdateTrigger.Id, newFacForPostUpdateTrigger);
                }
                
            }//end outer [TARGET/DESTINATION]-SOBJECTS loop
            
            
            insert sObjsToInsert;
            if(facsToUpdateMap.size() > 0) {
                update facsToUpdateMap.values();
            }
            
        }
        
        
    }
    
    
    
    
    
    private void setCaseFields(Service_Request_Field_Map__c customSetting, sObject sObjToInsert, Financial_Account_Customer__c fac, String sourceField, Financial_Account_Customer__c oldFac, Financial_Account_Customer__c tempFACForUpdate) {
        if(!TFSC_Utils.isNullOrEmpty(customSetting.Type__c)) {
            sObjToInsert.put('Service_Request_Type__c', customSetting.Type__c);
        }
        
        
        if(tempFACForUpdate.Account__r.isPersonAccount) {
            sObjToInsert.put('SR_Last_Name_Business_Name__c', tempFACForUpdate.Account__r.LastName);
            sObjToInsert.put('SR_First_Name__c',  tempFACForUpdate.Account__r.FirstName);
        }else{
            sObjToInsert.put('SR_Last_Name_Business_Name__c', tempFACForUpdate.Account__r.Name);
        }
        
        
        if(fac.Borrower_Position__c == 'Primary') {
            sObjToInsert.put('Service_Recipient__c', 'Borrower/Customer');
        }else{
            sObjToInsert.put('Service_Recipient__c', 'Co-Borrower/Customer');
        }
        
        if(fac.Financial_Account_Customer__c != null) {
            sObjToInsert.put('Financial_Account_Customer_ID__c', fac.Financial_Account_Customer__c);
        }
        
        
        String caseDesc = String.valueOf(sObjToInsert.get('Description'));
        if( TFSC_Utils.isNullOrEmpty(caseDesc) || caseDesc == 'null' ) {
            caseDesc = 'Information updated for:';
        }
        String fieldLabel = fieldMap.get(sourceField).getDescribe().getLabel();
        caseDesc += ' "' + fieldLabel + '" - Former: ';
        caseDesc += String.valueOf( oldFac.get(sourceField) );
        caseDesc += ', New: ';
        caseDesc += String.valueOf( fac.get(sourceField) );
        caseDesc += ';';
        sObjToInsert.put('Description', caseDesc);
    }
    
    
    
    private Map<Id,Account> buildAccountMap(Financial_Account_Customer__c[] facList) {
        Map<Id,Account> mapToReturn = new Map<Id,Account>();
        Set<Id> accountIdSet = new Set<Id>();
        for(Financial_Account_Customer__c fac : facList) {
            if(fac.Account__c != null) {
                accountIdSet.add(fac.Account__c);
            }
        }
        
        for(Account acct : [select id, IsPersonAccount, PersonContactId from Account where id in :accountIdSet]) {
            mapToReturn.put(acct.Id, acct);
        }
        
        return mapToReturn;
    }
    
   
    private void setValueOfSObjectFieldAndResetFACValue(sObject sObjToInsert, Financial_Account_Customer__c newFacForPostUpdateTrigger, Service_Request_Field_Map__c customSetting, String sourceField, Financial_Account_Customer__c oldFac, Financial_Account_Customer__c fac) {
        
        String targField = customSetting.Target_Field__c;
        
        if( !TFSC_Utils.isNullOrEmpty(customSetting.Conversion_Type__c) ) {
            if(customSetting.Conversion_Type__c == 'Boolean') {
                Boolean newBoolVal = (fac.get(sourceField) != null && String.valueOf(fac.get(sourceField)).toUpperCase() == 'YES'); 
                sObjToInsert.put(targField, newBoolVal);
            }else{
                sObjToInsert.put(targField, fac.get(sourceField));
            }
        }else{
            sObjToInsert.put(targField, fac.get(sourceField));
        }
        
        //reset value!
        if(sourceField != 'Financial_Account__c') {
            newFacForPostUpdateTrigger.put(sourceField, oldFac.get(sourceField));
        }
    
    }
    
    
    private sObject generateSObject(String destinationSObjectName, Financial_Account_Customer__c fac, Map<Id,Account> mapOfAccountIdToAccountRecord) {
        sObject sObjToInsert = TFSC_Utils.createSObjectFromTypeName(destinationSObjectName);
        Account acct;
        if(fac.Account__c != null) {
            acct = mapOfAccountIdToAccountRecord.get(fac.Account__c);
        }
        if(sObjToInsert != null) {
            
            if( destinationSObjectName == 'Case' ) {
                //On Case creation, go ahead and set Case.AccountId = <FAC.Account__r.Id> 
                //and If FAC.Account__r.IsPersonAccount then Case.ContactId = <FAC.Account__r.Id>
                sObjToInsert.put('AccountId', fac.Account__c);
                sObjToInsert.put('Financial_Account__c', fac.Financial_Account__c);
                sObjToInsert.put('Financial_Account_Customer__c', fac.Id);
                sObjToInsert.put('Subject', 'Field Update Service Request');
                sObjToInsert.put('Status', 'Closed');
                
                if( !TFSC_Utils.isNullOrEmpty(currentUser.Service_Request_User_Group__c) ) {
                    sObjToInsert.put('Service_Request_User_Group__c', currentUser.Service_Request_User_Group__c);
                }
                
                if( !TFSC_Utils.isNullOrEmpty(currentUser.Service_Request_Service_Type__c) ) {
                    sObjToInsert.put('Service_Type__c', currentUser.Service_Request_Service_Type__c);
                }
                
                
                System.debug('***** ' + fac.Financial_Account_Customer__c + ' *****');
                System.debug('***** ' + fac.Id + ' *****');
                if(acct != null && acct.IsPersonAccount && acct.PersonContactId != null) {
                    sObjToInsert.put('ContactId', acct.PersonContactId);
                }
            }
            
        }
        
        
        
        return sObjToInsert;
    }
    
    private void setRecordTypeAndTypeIfNotSet(sObject sObjToInsert, Service_Request_Field_Map__c customSetting, String destinationSObjectName, Set<String> stringSetOfFieldsOnSObject) {
        
        if( customSetting.Record_Type__c != null && destinationSObjectName != null) {
            System.debug('***** customSetting.Record_Type__c =' + customSetting.Record_Type__c + ' *****');
            System.debug('***** destinationSObjectName =' + destinationSObjectName + ' *****');
            
            try {
                Id recordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName( customSetting.Record_Type__c, destinationSObjectName );
                
                System.debug('***** recordTypeId =' + recordTypeId + ' *****');
                if(recordTypeId != null) {
                    sObjToInsert.put('RecordTypeId', recordTypeId);
                }
            }
            catch (Exception e) {
            }
        }
        
        //stringSetOfFieldsOnSObject.contains('Type')
        
        if( sObjToInsert.get('Type') == null && !TFSC_Utils.isNullOrEmpty(customSetting.Type__c) ) {
            try {
                sObjToInsert.put('Type', customSetting.Type__c);
            }
            catch (Exception e) {
            }
        }
        
        
        
    }
    
    private Set<String> buildStringSetOfFieldsOnSObject(sObject sObjToInsert) {
        Set<String> stringSetToReturn;
        String serializedString = JSON.serialize(sObjToInsert);
        Map<String,Object> hashOfFieldsToValues = (Map<String,Object>) JSON.deserializeUntyped(serializedString);
        
        stringSetToReturn = hashOfFieldsToValues.keyset().clone();
        // Salesforce always adds an extra 'attributes' key to SObjects
        // when you do JSON stuff, so let's get rid of that.
        stringSetToReturn.remove('attributes');
        
        return stringSetToReturn;
    }
    
    
    
    /**
    *   @this isn't too rough to understand... this method returns a map of a map.
    *   @the outter map is mapped by Target_Object name.
    *   @  meaning: if there are both records for Case and Task, both sObj types should be generated.
    *   @map.get() of the outerMap value returns a map that is mapped by Source_Field
    *   @  meaning: a unique list of each field in Financial_Account_Customer__c.
    *   @map.get() of the inner-child map returns the custom setting (Service_Request_Field_Map__c) 
    *   @  The custom setting can then be used to evaluate the target and destination objects and fields, 
    *   @  while also quickly/easily giving the dev the ability to evaluate other rules, like 'does the field exist on the source object', all within a simple loop of this returned map.
    *
    *   @Author     : Jeremy Mooer
    *   @Date       : 16 May 2014
    */
    private Map<String, Map<String,Service_Request_Field_Map__c>> buildMapOfMapOfCustomSettings() {
        
        Map<String, Map<String,Service_Request_Field_Map__c>> mapToReturn = new Map<String, Map<String,Service_Request_Field_Map__c>>();
        
        //map of DESTINATION OBJECT
          //which maps to a map of 'custom settings' (mapped by Target_Field__c)
        
        for(Service_Request_Field_Map__c cs : customSettingsForFacs)
        {
            if( !TFSC_Utils.isNullOrEmpty(cs.Target_Object__c) && !TFSC_Utils.isNullOrEmpty(cs.Source_Field__c) ) 
            {
                //keyValue will be like 'Case||CaseRecordType##CaseType++GroupingNumber'
                String keyValue = cs.Target_Object__c + '||' ;
                
                if( !TFSC_Utils.isNullOrEmpty(cs.Record_Type__c) ) {
                    keyValue += cs.Record_Type__c + '##';
                }else{
                    keyValue += '##';
                }
                
                if( !TFSC_Utils.isNullOrEmpty(cs.Type__c) ) {
                    keyValue += cs.Type__c + '++';
                }else{
                    keyValue += '++';
                }
                
                if( cs.Group__c != null ) { //Group__c is a number
                    keyValue += String.valueOf(cs.Group__c);
                }
                
                Map<String,Service_Request_Field_Map__c> childMap = mapToReturn.get(keyValue);
                if(childMap == null) {
                    childMap = new Map<String,Service_Request_Field_Map__c>();
                }
                
                
                childMap.put(cs.Source_Field__c, cs);
                mapToReturn.put( keyValue, childMap );
            }
        }
        
        return mapToReturn;
        
    }
    
    
    private Map<Id,Financial_Account_Customer__c> buildMapOfNewFacs(set<Id> facIds) {
        
        Map<Id,Financial_Account_Customer__c> mapToReturn;
        Map<String,String> stringMapForFields = new Map<String,String>();
        
        stringMapForFields.put('Financial_Account_Customer__c', 'Financial_Account_Customer__c');
        stringMapForFields.put('Election_Abbreviated_Consent__c', 'Election_Abbreviated_Consent__c');
        stringMapForFields.put('Account__r.isPersonAccount', 'Account__r.isPersonAccount');
        stringMapForFields.put('Account__r.LastName', 'Account__r.LastName');
        stringMapForFields.put('Account__r.FirstName', 'Account__r.FirstName');
        stringMapForFields.put('Account__r.Name', 'Account__r.Name');
        
        for(Service_Request_Field_Map__c custSetting : customSettingsForFacs) {
            stringMapForFields.put(custSetting.Source_Field__c, custSetting.Source_Field__c);
        }
        
        Integer ct = 1;
        Integer setLength = stringMapForFields.keySet().size();
        String queryString = 'SELECT ';
        for(String fieldName : stringMapForFields.keySet()) {
            queryString += fieldName;
            
            if(ct != setLength) {
                queryString += ', ';
            }
            ct++;
        }
        queryString += ' FROM Financial_Account_Customer__c where id in :facIds';
        
        mapToReturn = new Map<Id,Financial_Account_Customer__c>( (List<Financial_Account_Customer__c>)database.query(queryString) );
        return mapToReturn;
    }
    
    private static List<Service_Request_Field_Map__c> cached_customSettingsForFacs;
    public static List<Service_Request_Field_Map__c> customSettingsForFacs {
        get{
            if(cached_customSettingsForFacs == null) {
                
                cached_customSettingsForFacs = [select Name, Source_Field__c, Source_Object__c, 
                                                   Target_Field__c, Target_Object__c, Target_Field_Old__c,
                                                   Record_Type__c, Type__c, Group__c, Conversion_Type__c,
                                                   Address_Type__c, Service_Request_Category__c, Service_Result__c,
                                                   Consent_Validation__c
                                                  from Service_Request_Field_Map__c
                                                  where Source_Object__c = 'Financial_Account_Customer__c'
                                                  and Target_Object__c <> null];
                                                  
            }
            return cached_customSettingsForFacs;
            
        }
    }
    
    /*
    private void updateFieldValueToCaseTemp(sObject sObjToInsert, String sourceField, Financial_Account_Customer__c oldFac, Financial_Account_Customer__c fac) {
        String oldCaseDescription = (String)sObjToInsert.get('Description');
        
        if(oldCaseDescription == null) {
            oldCaseDescription = '';
        }
        
        oldCaseDescription += sourceField + ' old value :';
        if(oldFac.get(sourceField) != null) {
            oldCaseDescription += String.valueOf( oldFac.get(sourceField) ) ;
        }
        oldCaseDescription += '\n';
        
        oldCaseDescription += sourceField + ' new value :';
        if(fac.get(sourceField) != null) {
            oldCaseDescription += String.valueOf( fac.get(sourceField) );
        }
        oldCaseDescription += '\n';
        
        sObjToInsert.put('Description', oldCaseDescription);
    }
    */
    
    
    
    private Map<String, Schema.SObjectField> parsedFieldMap;
    //fieldMap.get(fieldName).getDescribe().getLabel() provides object field's label.
    private Map<String, Schema.SObjectField> fieldMap {
        get {
            if(parsedFieldMap == null) {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchema = schemaMap.get('Financial_Account_Customer__c');
                parsedFieldMap = leadSchema.getDescribe().fields.getMap();
            }
            return parsedFieldMap;
        }
    }
    
    
    private User current_user_cache;
    private User currentUser {
        get {
            if(current_user_cache == null) {
                current_user_cache = [select id, Service_Request_User_Group__c, Service_Request_Service_Type__c 
                                         from user where id = :UserInfo.getUserId()];
            }
            return current_user_cache;
        }
    }
    
    
    //the facField in this case should be called from a loop over the fields from the CustomSetting
    private Boolean facFieldHasChanged(Financial_Account_Customer__c oldFac, Financial_Account_Customer__c newFac, String fieldName) {
        
        try {
            //fewest lines of code to bypass null pointers
            if( oldFac.get(fieldName) == null || newFac.get(fieldName) == null ) {
                if( oldFac.get(fieldName) == newFac.get(fieldName) ) {
                    return false;
                }
                if( oldFac.get(fieldName) != null && newFac.get(fieldName) == null){
                    return true;
                }
                if( oldFac.get(fieldName) == null && newFac.get(fieldName) != null ) {
                    return true;
                }
            }else if( oldFac.get(fieldName) != newFac.get(fieldName) ) {
                return true;
            }
        }
        catch (Exception e) {
            return false; //maybe throw error, preferabally on newFac.
        }
        
        if( oldFac.get(fieldName) == newFac.get(fieldName) ) {
            return false;
        }
            
        
        
        return true;
    }
    
    
    
}