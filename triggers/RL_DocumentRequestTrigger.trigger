trigger RL_DocumentRequestTrigger on Document_Request__c (after insert, after update) {
	
	
	
	new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new RL_DocReqStatusChangeTriggerHandler())
        .manage();
	
	
	
	
}