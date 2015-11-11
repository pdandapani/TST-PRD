@isTest
private class TFSC_SoftPhoneExceptionControllerTest {

    static testMethod void testControllerAndStaticMethod() {
        
        
        
        
        String acctNum = '11qqaazz22wwssxx';
        Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
        Financial_Account__c fa = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct, acctNum);
        
        
        Test.startTest();
        
            TFSC_SoftPhoneExceptionController ctrl = new TFSC_SoftPhoneExceptionController();
            
            TFSC_SoftPhoneExceptionController.getFaidStringListFromAccountNumSearch(acctNum);
            
        
        Test.stopTest();
        
        
    }
}