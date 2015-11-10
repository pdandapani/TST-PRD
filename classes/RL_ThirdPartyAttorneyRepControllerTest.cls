@isTest
private class RL_ThirdPartyAttorneyRepControllerTest {
    
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
            new Financial_Account_Customer__c(Customer_Role_Type__c='6-Co-Borrower', Account__c = accList[1].Id, Borrower_Status__c = 'Active', Name = 'Test FAC2', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071', RL_Bankruptcy_Status__c = 'Filing Party')
        };
        insert facs;
        
        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(aCase, faRetail);
        
        Third_Party__c tp = new Third_Party__c(Repossession__c=repo.Id);
        insert tp;
        Third_Party__c tpComplete = [select Id, Attorney_Representing_Borrower__c, Financial_Account__c, Attorney_Representing_Borrower__r.Name from Third_Party__c where Id = :tp.Id];
        
        // Load page with test Third Party record and setup controller test
        PageReference pageRef = Page.RL_ThirdPartyAttorneyRep;
        ApexPages.currentPage().getParameters().put('Id', tp.Id);
        ApexPages.StandardController tPStdController = new ApexPages.StandardController(tpComplete);
        RL_ThirdPartyAttorneyRepController controller = new RL_ThirdPartyAttorneyRepController(tPStdController);
        Test.setCurrentPage(pageRef);

        // Fill the picklist with options and set the controller's representing property to the primary borrower FAC by selecting the first queried option
        List<SelectOption> options = controller.getFACs();
        controller.representing = options.get(1).getValue();

        // Invoke the save of the Third Party record (like the picklist was changed)
        controller.saveRepresenting();

        // Verify the Third Party record was updated with the primary borrower FAC
        Third_Party__c tpAssert = [select Id, Attorney_Representing_Borrower__c, Financial_Account__c, Attorney_Representing_Borrower__r.Name from Third_Party__c where Id = :tp.Id];
        Financial_Account_Customer__c fac = [select Id from Financial_Account_Customer__c where Name = 'Test FAC2' limit 1];
        System.assertEquals(tpAssert.Attorney_Representing_Borrower__c, fac.Id);
        
        // Reload controller to load with non-null Attorney_Representing_Borrower__c
        tPStdController = new ApexPages.StandardController(tpAssert);
        controller = new RL_ThirdPartyAttorneyRepController(tPStdController);
    }
}