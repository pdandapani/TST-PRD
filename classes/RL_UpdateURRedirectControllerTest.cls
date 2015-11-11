@isTest
private class RL_UpdateURRedirectControllerTest {
	
	@isTest static void test_method_one() {
        //Setup Data
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        Id personAccountRT = RL_GenerateTestData.getRecordType('Account', 'Customer');
        List<Account> accList = new Account[]{new Account(FirstName='TEST1', LastName='ACCOUNT1', recordTypeId=personAccountRT), new Account(FirstName='TEST2', LastName='ACCOUNT2', recordTypeId=personAccountRT)};
        insert accList;

        List<Financial_Account_Customer__c> facs = new Financial_Account_Customer__c[] {
            new Financial_Account_Customer__c(Customer_Role_Type__c='0-Primary Borrower', Account__c = accList[0].Id, Borrower_Status__c = 'Active', Name = 'Test FAC1', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071'),
            new Financial_Account_Customer__c(Customer_Role_Type__c='6-Co-Borrower', Account__c = accList[1].Id, Borrower_Status__c = 'Active', Name = 'Test FAC2', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071')
        };
        insert facs;
        
        Collateral__c collateral = new Collateral__c(Name='Test Collateral', Vehicle_Identification_Number__c='12345');
        insert collateral;
        
        faRetail.Collateral__c = collateral.Id;
        update faRetail;

        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        Case caseToReturn = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        caseToReturn.Form_Rule__c = formRuleMap.get('4015MD').Id;
        caseToReturn.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        caseToReturn.RL_Auction_Agency_Zip__c = 'xyz';
        update caseToReturn;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(caseToReturn, faRetail);  
        repo.Local_Repo_Date__c = Date.today();
        repo.United_Road_Order_Date__c = Date.today().addDays(-3);		
        update repo;

        //Execute Tests
        PageReference pageRef = Page.RL_UpdateURRedirect;
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(repo);    
        RL_UpdateURRedirectController controller = new RL_UpdateURRedirectController(standardCtrler);
        controller.updateURDetails();

        //Assertions
        System.assertEquals(controller.referrerUrl, null);
        System.assert(controller.errDisplayText.containsIgnoreCase('United Road date is before this repossession date'));
	}
	
}