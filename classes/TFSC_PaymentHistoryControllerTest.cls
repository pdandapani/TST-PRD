@isTest
private class TFSC_PaymentHistoryControllerTest {
    
    
    
    static testmethod void testController() {
    	
    	String randomString = TFSC_TestUtils.generateRandomString(6);
    	
    	
    	Account acct = new Account(name = 'test' + randomString);
        insert acct;
        
        Financial_Account__c fAcct = setupData(acct);
    	
    	
    	PageReference pageRef = Page.TFSC_PaymentHistory;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recordId', fAcct.Id);
        
        TFSC_PaymentHistoryController ctrl = new TFSC_PaymentHistoryController();
        
        
    	
    }
    
    
    private static Financial_Account__c setupData(Account acct) {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Financial_Account__c financialAccount = new Financial_Account__c(Financial_Account_Number__c = randomString);
        financialAccount.Collection_List_Number_1__c = '1704'; // for FPD
        financialAccount.History_Counter_Days_Past_Due__c = '10';
        financialAccount.Region_Number__c = '01';
        insert financialAccount;
        
        
        return financialAccount;
    }
    
    
}