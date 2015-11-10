global class TFSC_BatchUpdateCases implements Database.Batchable<sObject> {

	Map<Id, String> caseMap = new Map<Id, String>();
	
	global TFSC_BatchUpdateCases(Map<Id, String> caseUpdate) {
		caseMap = caseUpdate;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return DataBase.getQueryLocator([SELECT Id, CaseNumber, Requested_Due_Date_Day_of_Month__c, RecordTypeId FROM case WHERE Id IN :caseMap.keySet()]);
	}
	  
	global void execute(Database.BatchableContext BC,List<Case> scopeCase) {
		for (Case aCase : scopeCase) {
			aCase.Last_Comment__c = caseMap.get(aCase.Id);
		}
		update scopeCase;
	}
	
	global void finish(Database.BatchableContext BC) {
	}
}