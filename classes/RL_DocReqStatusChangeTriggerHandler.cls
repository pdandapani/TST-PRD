public with sharing class RL_DocReqStatusChangeTriggerHandler implements TFSC_TriggerDispatcher.Handler {
    
    
    public void handle() {
        Map<Id,Document_Request__c> newMap = (Map<Id,Document_Request__c>)Trigger.newMap;
        Map<Id,Document_Request__c> oldMap = (Map<Id,Document_Request__c>)Trigger.oldMap;
        
        ifStatusChangedSendConsoleMessage(newMap, oldMap);
    }
    
    
    
    private void ifStatusChangedSendConsoleMessage(Map<Id,Document_Request__c> newdocReqMap, Map<Id,Document_Request__c> olddocReqMap) {
    	
    	List<System_Message__c> messagesToInsert = new List<System_Message__c>();
    	String msgType;
    	Boolean notifyUser = false;
    	
    	Set<Id> repoIds = new Set<Id>();
    	for(Document_Request__c docReq1 : newdocReqMap.values()) {
    		if(docReq1.Repossession__c != null){
    			repoIds.add(docReq1.Repossession__c);
    		}
    	}
    	
    	Map<Id,Repossession__c> repoMap = new Map<Id,Repossession__c>();
    	if(!repoIds.isEmpty()) {
    		repoMap = new Map<Id,Repossession__c>([select id, case__r.CaseNumber from Repossession__c where id in :repoIds]);
    	}
    	
    	
    	for(Document_Request__c docReq : newdocReqMap.values()) {
    		
    		Document_Request__c olddocReq = olddocReqMap.get(docReq.Id);
    		
    		if(olddocReq != null && docReq.Status__c != null && docReq.Status__c != ''  && docReq.Status__c != olddocReq.Status__c) {
    			//leaving if(olddocReq != null) because integration should only update after created.  coding against mis-use of handler in trigger implementation.
    			msgType = 'Informational';
    			Boolean success = true;
    			if(docReq.Status__c != 'Success') {
    				msgType = 'Handled Error';
    				notifyUser = true;
    				success = false;
    				Repossession__c repo = null;
    				String caseNumberString = '';
    				if(docReq.Repossession__c != null) {
    					repo = repoMap.get(docReq.Repossession__c);
    					if(repo.Case__r != null && repo.Case__r.CaseNumber != null) {
    						caseNumberString = String.valueOf(repo.Case__r.CaseNumber);
    					}
    				}
    				
    				
    				System_Message__c msg = insertMessageForNonSuccessStatus(docReq, msgType, notifyUser, success, caseNumberString);
    				messagesToInsert.add(msg);
    			}
    		}
    	}
    	
    	if(messagesToInsert.size() > 0) {
    		insert messagesToInsert;
    	}
    }
    
    private System_Message__c insertMessageForNonSuccessStatus(Document_Request__c docReq, String msgType, Boolean notifyUser, Boolean success, String caseNumber) {
    	String descriptionString = 'Reference: ' + docReq.Id + '.\n ';
    	
    	if(docReq.Status__c != null) {
    		descriptionString += docReq.Status__c + '\n';
    	}
    	if(docReq.Code__c != null) {
    		descriptionString += 'Error Code: ' + docReq.Code__c + '\n';
    	}
    	if(docReq.Message__c != null) {
    		descriptionString += docReq.Message__c + '\n';
    	}
    	if(docReq.Description__c != null) {
    		descriptionString += docReq.Description__c + '\n';
    	}
    	
    	if(descriptionString.length() > 32767) {
    		descriptionString = descriptionString.substring(0,32767);
    	}
    	
    	System_Message__c msgToInsert = new System_Message__c();
		msgToInsert.OwnerId = docReq.CreatedById;
		msgToInsert.Notify_User__c = notifyUser ;
		msgToInsert.Source__c = 'LiveCycle';
		msgToInsert.Title__c = (success) ? 'Document Generated in LiveCycle' : 'LiveCycle Error';
		msgToInsert.Title__c += '; Case ' + caseNumber;
		msgToInsert.Type__c = msgType;
		msgToInsert.Description__c = descriptionString;
		
		return msgToInsert;
    }
    
    
    
    
    
}