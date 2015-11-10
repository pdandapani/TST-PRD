@isTest
private class TFSC_TestUtilsTest {
    
    
    static testMethod void testGenerateTestUser() {
        
        Test.startTest();
        
            TFSC_TestUtils.generateTestUser('Collections', true);
            
        Test.StopTest();
    }
    
    
    static testMethod void testSetupAndReturnArticle(){
    	
    	Test.startTest();
    	
    		FAQ_A__kav testArticle = TFSC_TestUtils.setupAndReturnArticle();
    		
    	Test.stopTest();
    	
    	System.assert(testArticle != null);
    	
    }
    
    
}