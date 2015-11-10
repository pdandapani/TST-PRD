@isTest
private class RL_InteractionEntryPanelControllerTest {
	
	
	static testmethod void testControllerMethods() {
		
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
        repo.Recorded_Legal_Sale_Date__c = Date.newInstance(2015, 9, 9);
        update repo;
        
		//Execute Tests
		PageReference pageRef = Page.RL_InteractionEntryPanel;
        ApexPages.currentPage().getParameters().put('Id', caseToReturn.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(caseToReturn);
        
        Test.setCurrentPage(pageRef);
        
        RL_InteractionEntryPanelController controller = new RL_InteractionEntryPanelController(standardCtrler);
        controller.contextRepo = repo;
        
        system.assert(controller.legalSaleDate != null);
        
        RL_InteractionEntryPanelController.tempURCallout();
        
        controller.updateModifyRepoNote();
        controller.getLatestFormData();
    
        Activity_Code__c ac = new Activity_Code__c(CTI_Activity__c = true, Name = 'TEST');
        insert ac;

        repo.Case__c = null;
        update repo;

        Case parentCase = RL_GenerateTestData.createCase(faRetail, caseRTId);
        Case grandparentCase = RL_GenerateTestData.createCase(faRetail, caseRTId);
        caseToReturn.ParentId = parentCase.Id;
        parentCase.ParentId = grandparentCase.Id;
        update caseToReturn;
        update parentCase;
        standardCtrler = new ApexPages.StandardController(caseToReturn);
        controller = new RL_InteractionEntryPanelController(standardCtrler);
        controller.selectedActivityCodeFromJs = 'TEST';
        controller.getLatestFormData();
    
        System.assert(controller.contextRepo == null);
        System.assertEquals(controller.contextFinancialAccount.Id, faRetail.Id);
	}
}