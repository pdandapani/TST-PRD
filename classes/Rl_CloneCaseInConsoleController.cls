public with sharing class Rl_CloneCaseInConsoleController {
	
	private Repossession__c contextRepo;
	
	public String newCaseId{get;set;}
	public String errDisplayText{get;set;}
	
	public Rl_CloneCaseInConsoleController(ApexPages.StandardController stdController) {
		String[] repoFields = new String[] {'Id','Case__r.Form_Rule__c', 'Case__c'};
		if(!Test.isRunningTest()) {
			stdController.addFields(repoFields);
	        contextRepo = (Repossession__c) stdController.getRecord();
		} else {
			contextRepo = [SELECT Id, Case__r.Form_Rule__c, Case__c FROM Repossession__c WHERE Id =: stdController.getId()];
		}
	}
	
	
	
	private String validationErrorString(Case contextCase) {
		String stringToReturn = '';
		
		//try{
			List<Document_Request__c> drs = [select id from Document_Request__c where Repossession__c = :contextRepo.Id];
			if(drs == null || drs.size() == 0) {
				stringToReturn = 'There are not yet any Document Requests for this Case. Clone functionality disabled.';
			}
		//}catch(Exception e) {
		//}
		
		return stringToReturn;
	}
	
	
	public PageReference cloneCaseAndRelatedRecords() {
		errDisplayText = '';
		String tmpErrorString;
		try{
			Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Case.fields.getMap();
			Case contextCase = (Case)runQueryOnAllFields(fldObjMap, contextRepo.Case__c, 'Case');
			
			tmpErrorString = validationErrorString(contextCase);
			
			if(tmpErrorString == null || tmpErrorString.length() == 0) {
				cloneRepoAndCase(contextCase);
			}
		}catch(Exception e) {
			tmpErrorString = e.getMessage() + ' line: ' + e.getLineNumber();
		}
		
		
		
		if(tmpErrorString != null && tmpErrorString.length() > 0) {
			appendErrorMessage( tmpErrorString );
		}
		return null;
	}
	
	
	private void cloneRepoAndCase(Case contextCase) {
		Id currentUserId = Userinfo.getUserId();
		
		Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Repossession__c.fields.getMap();
		Repossession__c repoWithAll = (Repossession__c)runQueryOnAllFields(fldObjMap, contextRepo.Id, 'Repossession__c');
		
		Case newCase = contextCase.clone(false, true, false, false);
		newCase.Integration_ID__c = null;
		insert newCase;
		newCaseId = newCase.Id;
		
		Repossession__c newRepo = repoWithAll.clone(false,true,false,false);
		newRepo.iRepo_AssignmentNumber__c = null;
		newRepo.Recorded_Legal_Sale_Date__c = null;
		newRepo.Recorded_Notice_Date__c = null;
		newRepo.Case__c = newCase.Id;
		insert newRepo;
		
		fldObjMap = schema.SObjectType.Third_Party__c.fields.getMap();
		List<Third_Party__c> listThirdParty = (List<Third_Party__c>)runQueryOnAllFieldsAndReturnList(fldObjMap, contextRepo.Id, 'Third_Party__c');
		if(listThirdParty != null && listThirdParty.size() > 0) {
			List<Third_Party__c> listToInsert = new List<Third_Party__c>();
			for(Third_Party__c tp : listThirdParty) {
				Third_Party__c clonedTp = tp.clone(false,true,false,false);
				clonedTp.Repossession__c = newRepo.Id;
				listToInsert.add(clonedTp);
			}
			
			insert listToInsert;
		}
		
	}
	
	
	private sObject runQueryOnAllFields(Map<String, Schema.SObjectField> fldObjMap, String idVal, String sobjType) {
		String whereClause = ' WHERE id = \'' + idVal + '\'';
		String queryString = buildQueryString(fldObjMap, idVal, sobjType, whereClause);
		
		return Database.query(queryString);
	}
	
	private List<sObject> runQueryOnAllFieldsAndReturnList(Map<String, Schema.SObjectField> fldObjMap, String repoId, String sobjType) {
		String whereClause = ' WHERE Repossession__c = \'' + repoId + '\'';
		String queryString = buildQueryString(fldObjMap, repoId, sobjType, whereClause);
		
		return Database.query(queryString);
	}
	
	private String buildQueryString(Map<String, Schema.SObjectField> fldObjMap, String idVal, String sobjType, String whereClause) {
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
		
		String queryString = 'SELECT ';
		Integer i = 0;
		for(Schema.SObjectField s : fldObjMapValues)
		{
			String theLabel = s.getDescribe().getLabel();
			String theName = s.getDescribe().getName();
			String theNameUpper = theName.toUpperCase();
			//String theType = s.getDescribe().getType();
			Boolean isFormula = s.getDescribe().isCalculated() ;
			
			if(!isFormula && 
					theNameUpper != 'OWNER' && theNameUpper != 'OWNERID' && 
					theNameUpper != 'CREATEDBY' && theNameUpper != 'CREATEDBYID' &&
					theNameUpper != 'LASTMODIFIEDBY' && theNameUpper != 'LASTMODIFIEDBYID') {
				if(i  > 0) {
					queryString += ',' ;
				}
				queryString += theName;
				i++;
			}
		}
		
		queryString += ' FROM ' + sobjType + whereClause;
		
		return queryString;
	}
	
	
	
	/*private void appendInfoMessage(String infoMessage) {
     appendMessage(infoMessage, ApexPages.Severity.INFO);
    }*/
    private void appendErrorMessage(String errorMessage) {
        errDisplayText = errorMessage;
        appendMessage(errorMessage, ApexPages.Severity.ERROR);
    }
    
    private void appendMessage(String errorMessage, ApexPages.severity severity) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(severity, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
}