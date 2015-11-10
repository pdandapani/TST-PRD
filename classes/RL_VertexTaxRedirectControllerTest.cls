@isTest
private class RL_VertexTaxRedirectControllerTest {
	
	@isTest static void test_method_one() {
        //Setup Data
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        faRetail.Loan_Current_Amount__c = 100;
        faRetail.INT_PAY__c = 3;
        faRetail.Charges_Miscellaneous__c = 20;
        faRetail.Contract_Receivable__c = 1;
        faRetail.Refund__c = 1;
        faRetail.Charges_Late__c = 1;
        faRetail.Payment_Amount_Past_Due__c = 1;
        update faRetail;

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
        repo.Repossession_Costs__c = 1;
        repo.United_Road_Transport_Fees__c = 1;
        repo.Impound_Fee__c = 1;
        repo.Other_Charges1__c = 1;
        repo.Other_Charges2__c = 1;
        repo.Excluded_Fee_Amount__c = 1;
        repo.Sales_Tax__c = 1;
        repo.Sales_Tax_Zip_Code__c = '12345-6789';
        repo.State_of_Jurisdiction__c = 'IL';
        update repo;

       //Execute Tests
        PageReference pageRef = Page.RL_UpdateURRedirect;
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(repo);    
        RL_VertexTaxRedirectController controller = new RL_VertexTaxRedirectController(standardCtrler);
        controller.executeTaxCallout();        

        System.assertEquals(controller.zipCode, '12345-6789');
        System.assertEquals(controller.stateAbbrev, 'IL');
        System.assertEquals(controller.salesTaxDate, Date.today());

        //Failure use case
        faRetail.Loan_Current_Amount__c = 0;
        faRetail.INT_PAY__c = 0;
        faRetail.Charges_Miscellaneous__c = 0;
        faRetail.Contract_Receivable__c = 0;
        faRetail.Refund__c = 0;
        faRetail.Charges_Late__c = 0;
        faRetail.Payment_Amount_Past_Due__c = 0;
        update faRetail;

        repo.Sales_Tax_Zip_Code__c = '';
        repo.Repossession_Costs__c = 0;
        repo.United_Road_Transport_Fees__c = 0;
        repo.Impound_Fee__c = 0;
        repo.Other_Charges1__c = 0;
        repo.Other_Charges2__c = 0;
        repo.State_of_Jurisdiction__c = '';
        update repo;
        standardCtrler = new ApexPages.StandardController(repo);   
        controller = new RL_VertexTaxRedirectController(standardCtrler);
        controller.executeTaxCallout();        

        System.assertEquals(controller.zipCode, null);
        System.assertEquals(controller.stateAbbrev, null);
        System.assertEquals(controller.salesTaxDate, Date.today());        
	}
}