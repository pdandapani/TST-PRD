@isTest
private class RL_DocReqStatusChangeTriggerTest {
	
	
	static testmethod void testTrigger() {
		
		Case caze = new Case(recordTypeId = TFSC_Utils.getRecordTypeIdFromNameAndsObjectName('Rights Letter','Case'));
		insert caze;
		
		Document_Request__c docRequest = new Document_Request__c(status__c = 'test', case__c = caze.Id);
		insert docRequest;
		
		test.startTest();
			
			docRequest.status__c = 'ERROR';
			docRequest.Code__c = 'ERR';
			docRequest.Message__c = 'Error Recieved';
			docRequest.Description__c = 'Error Description Test';
			
			update docRequest;
			
		test.stopTest();
		
	}
	
	
}