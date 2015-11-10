@isTest
private class TFSC_WS_CreateUpdateDemographicsTest {

    static testMethod void myUnitTest() {
        
        Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
        acct.NumberOfEmployees = 10;
        update acct;
        
        Test.startTest();
        	
        	TFSC_WS_CreateUpdateDemographics.CreateUpdateDemographicsRequest req;
        	req = new TFSC_WS_CreateUpdateDemographics.CreateUpdateDemographicsRequest(); 
        	req.account = acct;
            TFSC_WS_CreateUpdateDemographics.createUpdateDemographics(req);
            
        Test.stopTest();
        
    }
}