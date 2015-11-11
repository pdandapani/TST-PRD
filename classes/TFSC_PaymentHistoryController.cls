public with sharing class TFSC_PaymentHistoryController {
    
    public Financial_Account__c contextFinancialAccount{get;set;}
    public List<TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_ResponseRecord> historyList{get;set;}
    
    
    public TFSC_PaymentHistoryController() {
        
        if(recordId != null) {
        	try {
                this.contextFinancialAccount = [ select id, Region_Number__c, Branch__r.Account_Number__c, RecordType.Name, Financial_Account_Number__c
                                                    from Financial_Account__c
                                                    where id = :recordId];
	        }
	        catch (Exception e) { }
        }
        if(this.contextFinancialAccount != null) {
        	getData();
        }
    }
    
    private String recordId {
    	get{
    		return ApexPages.currentPage().getParameters().get('recordId');
    	}
    }
    
    
    private void getData() {
    	 getAccountData();
    }
    
    private void getAccountData() {
    	//request = AccountNumber; AccountType; Branch; NoOfRecords; Region;
    	
    	String acctType = '';
    	if( !TFSC_Utils.isNullOrEmpty(contextFinancialAccount.RecordType.Name) ) {
    		acctType = contextFinancialAccount.RecordType.Name;
    		acctType = acctType.substring(0,1);
    	}
    	
    	String errorString = '';
    	//if( TFSC_Utils.isNullOrEmpty(acctType) ) {
    	//	errorString = 'Account Type is requred.';
    	//	return;
    	//}
    	
    	//AccountNumber = Financial_Account__c.Financial_Account_Number__c
		//AccountType = Financial_Account__c.RecordType.Name (first character)
		//Branch = Financial_Account__c.Branch__r.Account_Number__c
		//Region = Financial_Account__c.Region_Number__c
		if(errorString.length() == 0) {
	    	TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_RequestParams request;
	    	request = new TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_RequestParams();
	    	try {
		        request.AccountNumber = contextFinancialAccount.Financial_Account_Number__c;
		        request.AccountType = acctType;
		        request.Branch = '';
		        request.Region = '';
		        request.NoOfRecords = 30;
		        
		        errorString = executeWSFromRequestAndReturnError(request);
		        
	        }
	        catch (Exception e) {
	        	errorString = getErrorStringFromRequestAndException(e, request);
	        }
			
		}
		
		
        if(errorString.length() > 0) {
        	ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorString); 
            ApexPages.addMessage(pageMsg);
        }
    }
    
    
    //wrapped in a try-catch already
    private String executeWSFromRequestAndReturnError(TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_RequestParams request) {
    	String strToReturn = '';
    	
    	TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_ResponseParams response;
        response = TFSC_WS_GetPaymentTransactionHistory.getPaymentTransactionHistory(request);
        
        if(response.ResponseRecordList != null) {
            historyList = response.ResponseRecordList;
        }
        
        if(response.StatusParams != null && response.StatusParams.Status.toUpperCase() == 'FAIL') {
            if(response.StatusParams.Error != null) {
            	strToReturn = response.StatusParams.Error;
            }else{
            	
            	strToReturn = 'Webservice Error.'; 
            }
        }
        
        return strToReturn;
    }
    
    
    //wrapped in a try-catch already
    private String getErrorStringFromRequestAndException(Exception e, TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_RequestParams request) {
    	String errorString = e.getMessage();
        
        /*
        String tempBranch = 'null';
        if(request.Branch != null) {
            tempBranch = request.Branch;
        }
        String tempRegion = 'null';
        if(request.Region != null) {
            tempRegion = request.Region;
        }
        
        errorString += ';  request.AccountNumber = ' + request.AccountNumber;
        errorString += '; request.AccountType = ' + request.AccountType;
        errorString += '; request.Branch = ' + tempBranch;
        errorString += '; request.Region = ' + tempRegion;
        */
        
        return errorString;
    }
    
    
}