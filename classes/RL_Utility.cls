global class RL_Utility {
    // Adds business days to a given DateTime based on a BusinessHours calendar
    static public DateTime AddBusinessDays(DateTime StartDate, integer BusinessDaysToAdd, Id bHoursId) {
      //Add or decrease in BusinessDaysToAdd days 
        DateTime finalDate = StartDate;
        while(BusinessDaysToAdd != 0)
        {
            finalDate = finalDate.AddDays(1);
            if (BusinessHours.isWithin(bHoursId, finalDate)){
                BusinessDaysToAdd -= 1;
            }
        }
        return finalDate;
    }

    static public Repossession__c executeRepoQuery(List<String> repoFields, Id repoId) {
        String query = 'SELECT ';
        for (String field : repoFields) {
            query += field + ', ';
        }
        query += 'Name FROM Repossession__c WHERE Id =: repoId';
        return Database.query(query);
    }

    static public List<String> getListOfRepoFields() {
        List<Form_Field__c> repoFormFields = [SELECT Id, Name, Source_Field__c, Source_Object__c FROM Form_Field__c WHERE Source_Object__c =: 'Repossession__c'];
        List<String> fieldsList = new List<String>();
        for (Form_Field__c ff : repoFormFields) {
            fieldsList.add(ff.Source_Field__c);
        }
        fieldsList.addAll(new String[] {'Financial_Account__r.Financial_Account_Number__c', 'Case__r.Form_Rule__c', 'Id', 'Salvage__c', 'Validation_Comments__c', 'Validation_Comments__c', 
            'Recorded_Legal_Sale_Date__c', 'Proposed_Legal_Sale_Date__c', 'Case__c', 'BK_Active_or_Discharged__c', 'Transport_Fees_for_Form__c', 'recordtype.name','Reinstatement_Denial_Reason__c'});
        Set<String> repoFormFieldsSet = new Set<String>(fieldsList); //Remove duplicate fields.
        return new List<String>(repoFormFieldsSet);
    }
    
    
    /*
     * getQueryStringForSelectStar()
     * fldObjMapfldObjMap = schema.SObjectType.Case.fields.getMap();
     * sobjType = 'Case' or 'Repossession__c' for example
     *
    */ 
    
    static public String getQueryStringForSelectStar(Map<String, Schema.SObjectField> fldObjMap, String sobjType, String[] otherRelationshipFieldsToInclude) {
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
        String queryString = 'SELECT ';
        Boolean appendComma = false;
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theName = s.getDescribe().getName();
            //Boolean isFormula = s.getDescribe().isCalculated() ;
            
            if(appendComma) {
                queryString += ',' ;
            }
            queryString += theName;
            appendComma = true;
        }
        
        if(otherRelationshipFieldsToInclude != null) {
            for(String otherField : otherRelationshipFieldsToInclude) {
                queryString += ',' ;
                queryString += otherField ;
            }
        }
        
        queryString += ' FROM ' + sobjType + ' ';
        
        return queryString;
    }
    
}