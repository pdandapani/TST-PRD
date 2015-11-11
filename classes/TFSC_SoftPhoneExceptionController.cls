global class TFSC_SoftPhoneExceptionController {
    
    
    public TFSC_SoftPhoneExceptionController() {
    	
    }
    
    @RemoteAction
    global static List<Financial_Account__c> getFaidStringListFromAccountNumSearch(String acctNum) {
    	List<Financial_Account__c> listToReturn = new List<Financial_Account__c>();
    	
    	for(Financial_Account__c fa : [select id, name from Financial_Account__c
    									where Financial_Account_Number__c = :acctNum])
		{
			listToReturn.add(fa);
		}
    	
    	
    	return listToReturn;
    }
    
    
    
    
}