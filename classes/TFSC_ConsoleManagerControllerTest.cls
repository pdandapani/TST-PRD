@isTest
private class TFSC_ConsoleManagerControllerTest {
    
    
    static testmethod void testPublicStaticMethods() {
    	
    	Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
    	String accountNum = TFSC_TestUtils.generateRandomString(8);
    	Financial_Account__c fa = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct, accountNum);
    	TFSC_TestUtils.setupAndReturnFAC(fa, acct, 'Primary');
    	
    	Skip_Trace__c skipTrace = new Skip_Trace__c(Financial_Account__c = fa.Id);
        skipTrace.Address1__c = '1234 addy ST';
        skipTrace.Phone1__c = '4063775012';
        insert skipTrace;
    	
    	String testStr = TFSC_ConsoleManagerController.getObjectIdFromAccountNumber(accountNum);
    	System.assert( testStr != null ); 
    	
    	List<TFSC_ConsoleManagerController.FaObject> testList;
    	testList = TFSC_ConsoleManagerController.getFaObjectsFromFaIdList( new String[]{fa.Id} );
    	System.assert( testList != null ); 
        // Story S-311850 7/10/2015 #start
        TFSC_ConsoleManagerController.setInteractionType(String.valueOf(fa.id).left(15),'Inbound Call' );
        TFSC_ConsoleManagerController.deleteInteractionType(String.valueOf(fa.id).left(15));
        // Story S-311850 #end
    }
    
    
    
    
}