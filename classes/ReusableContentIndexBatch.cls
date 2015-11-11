global class ReusableContentIndexBatch implements Database.Batchable<SObject>,Database.Stateful {

	public String SOQL = 'select id from Reusable_Content__c'; 
	public ReusableContentIndexBatch() {
    	if ( Test.isRunningTest()){
    		SOQL = SOQL + ' limit 1';
    	} 
        system.debug(SOQL);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
        System.Debug(SOQL);
        return Database.getQueryLocator(SOQL);
    }

    global void execute(Database.BatchableContext BC, List<Reusable_Content__c> rcList){
    	for(Reusable_Content__c rc : rcList) {
			ReusableContentKavModel.findReusableContentArticleForTag(rc.id);
    	}
    }  
    
    
   	global void finish(Database.BatchableContext BC){

	}
	
	//ReusableContentIndexBatch.runNow();
	//setup as webservice for the Reusable Content List Button to invoke 
	webservice static void runNow(){
    	ReusableContentIndexBatch batch = new ReusableContentIndexBatch();
        Database.executeBatch(batch, 1);
	}
}