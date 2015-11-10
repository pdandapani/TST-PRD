/**
*   The purpose of this trigger handler is based on the need to try to maintain validations in sfdc-standard validations.
*   TFSC_FinancialActEditCaseCreateHandler is now an after-update trigger (when the purpose of it is to check updates to fields,
*     something that could be done before update; and reset the values to the old ones [something that screams 'before update']).
*   Now that an update occurs after update, then the changes are changed back after-update (firing the trigger again),
*     the validations need a way to determine if the values are changing from old-to-new edit, or revert-from new to old.
*
*   @Author     : Jeremy Mooer
*   @Date       : 10 Jul 2014
*/
public with sharing class TFSC_TriggerVariableHandler implements TFSC_TriggerDispatcher.Handler{

    public void handle() {
    
        List<Financial_Account_Customer__c> newList = (List<Financial_Account_Customer__c>)Trigger.new;
        Map<Id,Financial_Account_Customer__c> oldMap = (Map<Id,Financial_Account_Customer__c>)Trigger.oldMap;
        
        if(shouldExecuteTrigger()) {
        	setCorrectValueOfReentrantTriggerVarialbe(newList, oldMap);
        }
    }
    
    private Boolean shouldExecuteTrigger() {
    	String delimitedProfileList = Label.Profiles_to_allow_save_on_FAC;
        String usersProfileName = TFSC_Utils.getProfileNameFromProfileId(UserInfo.getProfileId());
        
        if(delimitedProfileList == null) {
            //facForError.addError( 'The Custom Label for disallowed profiles for FAC Edits has not been configured in this org.  Contact an administrator.' );
            return false;
        }
        
        String[] profileList = delimitedProfileList.split(';');
        Boolean shouldExecute = true;
        for(String profileName : profileList) {
            if(profileName == usersProfileName) {
                shouldExecute = false;
            }
        }
        
        return shouldExecute ;  
    }
    
    private void setCorrectValueOfReentrantTriggerVarialbe(List<Financial_Account_Customer__c> newFacs, Map<Id,Financial_Account_Customer__c> oldMap) {
    	
    	Boolean triggerFired = TFSC_FinancialActEditCaseCreateHandler.TRIGGER_ALREADY_FIRED_IN_STACK;
    	
    	List<Service_Request_Field_Map__c> customSettingsForFacs = TFSC_FinancialActEditCaseCreateHandler.customSettingsForFacs;
    	
    	
    	
    	
    	System.Debug('****TFSC_TriggerVariableHandler');
    	for(Financial_Account_Customer__c fac : newFacs) {
    		fac.Reentrant_Trigger_Executed__c = triggerFired;
    		
    		if(!triggerFired) {
	    		for(Service_Request_Field_Map__c cs : customSettingsForFacs) {
	        
			        if(cs.Consent_Validation__c != null && cs.Consent_Validation__c == true)
			        {
			            if( (fac.Election_Abbreviated_Consent__c != null && fac.Election_Abbreviated_Consent__c == 'N') ||
			                (fac.Election_Overall_Consent__c != null && fac.Election_Overall_Consent__c == 'N') )
			            {
			                //if(fac.get(cs.Source_Field__c) != null && fac.get(cs.Source_Field__c) == 'Y') {
			                fac.put(cs.Source_Field__c, 'N');
			                    //System.Debug(cs.Source_Field__c + ' updated to Y *****');
			                //}
			    		}
			    		
			    	}
	    		}
    		}
    	}
    }

}