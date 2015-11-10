public class TFSC_TaskTriggerHandler implements TFSC_TriggerDispatcher.Handler {
	
	static final String FINANCIAL_ACCOUNT = lookupFAId();
	
	public void handle(){
		updateFinancialAccountsCureNote((List<Task>)Trigger.new);
	}
	
	public static void updateFinancialAccountsCureNote(List<Task> taskList){
		
		List<Financial_Account__c> fasToUpdate = new List<Financial_Account__c>();
		Map<Id,Financial_Account__c> faMap = new Map<Id,Financial_Account__c>();
		
		for(Task t : taskList){
			
			if(t.WhatId != null){
							
				String taskWhatIdPrefix = String.valueOf(t.WhatId).substring(0,3); //Get the object ID from the related record ID
			
				//Only execute if the task is assocaited to an FA and is a CURE note
				if(taskWhatIdPrefix == FINANCIAL_ACCOUNT && t.Collection_Activity_Code__c != null && t.Collection_Activity_Code__c == 'CURE'){
					
					Financial_Account__c tmpFA = new Financial_Account__c(Id = t.WhatId,
																		  Most_Recent_Cure_Note__c = t.Description);
					
					//Check to see if the map currently contains the FA ID, if so remove the old and use the new; otherwise, just add it
					if(faMap.containsKey(tmpFA.Id)){ 
						faMap.remove(tmpFA.Id);
						faMap.put(tmpFA.Id,tmpFA);
					}													  
					else faMap.put(tmpFA.Id,tmpFA);
					
				}
			}
			else continue;	
			
		}
		
		if(!faMap.isEmpty()){
			fasToUpdate.addAll(faMap.values());
			update fasToUpdate;
		}
		
	}
	
	//Lookup the object ID for the FA object
	private static String lookupFAId(){
		
		Schema.DescribeSObjectResult dsr = Financial_Account__c.SObjectType.getDescribe();
		
		String objectId = dsr.getKeyprefix();
		
		return objectId;
		
	}

}