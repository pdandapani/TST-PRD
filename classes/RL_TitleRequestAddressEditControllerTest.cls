@isTest
private class RL_TitleRequestAddressEditControllerTest {
	
	@isTest static void test_method_one() {
        //Setup Test Data
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();        
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);

        Collateral__c collateral = new Collateral__c(Name='Test Collateral', Vehicle_Identification_Number__c='12345');
        insert collateral;
        
        faRetail.Collateral__c = collateral.Id;
        update faRetail;

        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        aCase.Form_Rule__c = formRuleMap.get('4015MD').Id;
        aCase.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        update aCase;
        
        Id auctionRTId = RL_GenerateTestData.getRecordType('Account', 'Auction');                
        Account auctionAccount = new Account(RecordTypeId=auctionRTId, Name='Test Auction Account', BillingStreet='1234 Test \n Bay street');
        insert auctionAccount;

        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(aCase, faRetail);     
        repo.Title_Zip__c = '12345';
        update repo;

        //Execute Controller methods
		PageReference pageRef= Page.RL_TitleRequestAddressEdit;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('Id', repo.Id);

        ApexPages.StandardController repoStdController = new ApexPages.StandardController(repo);
        RL_TitleRequestAddressEditController controller = new RL_TitleRequestAddressEditController(repoStdController); 
        controller.selectedAuctionAcct = auctionAccount.Id;
        controller.saveNewAccountValues();
        controller.copyVendorInformation(); //Modified by Shashank Singhal for S-311648 on 6/1/2015
        System.assertEquals(repo.Title_Zip__c, auctionAccount.BillingPostalCode);
        System.assertEquals(repo.Auction_Agency_Zip__c, repo.Title_Zip__c); //Modified by Shashank Singhal for S-311648 on 6/1/2015

        //Test for exception on repo update
        auctionAccount.BillingPostalCode = '12345678901';
        update auctionAccount;
        controller.saveNewAccountValues();
        System.debug(ApexPages.getMessages().get(0).getDetail());
        boolean errMsg = ApexPages.getMessages().get(0).getDetail().contains('max length=10') ? true : false;
        System.assert(errMsg);            
	}
	
}