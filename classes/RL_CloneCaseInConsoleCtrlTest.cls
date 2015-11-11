@isTest
private class RL_CloneCaseInConsoleCtrlTest {
	
	
	static testmethod void testControllerMethods() {
		
        Case caseRef;
        Repossession__c repo = setupData(caseRef);
		
		repo = [select Id, Case__c from Repossession__c where id = :repo.Id];
        Document_Request__c dr = new Document_Request__c(Case__c=repo.Case__c, Repossession__c=repo.Id);
        insert dr;

		PageReference pageRef = Page.Rl_CloneCaseInConsole;
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(repo);
        Rl_CloneCaseInConsoleController controller = new Rl_CloneCaseInConsoleController(standardCtrler);
        Test.setCurrentPage(pageRef);
        
        controller.cloneCaseAndRelatedRecords();
        
        System.debug(controller.errDisplayText);        
        System.assert((controller.errDisplayText == null || controller.errDisplayText == ''));
	}
	
	
	static testmethod void testForErrors() {
		
		Case caseRef;
		Repossession__c repo = setupData(caseRef);
     	
		//Case__r.Form_Rule__c, Case__c
		repo = [select Id from Repossession__c where id = :repo.Id];
		
		PageReference pageRef = Page.Rl_CloneCaseInConsole;
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(repo);
        Rl_CloneCaseInConsoleController controller = new Rl_CloneCaseInConsoleController(standardCtrler);
        Test.setCurrentPage(pageRef);
        
        controller.cloneCaseAndRelatedRecords();

        System.assert(controller.errDisplayText != null); 
	}
	
	
	
	static private Repossession__c setupData(Case caseRef) {
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
        caseRef = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        System.debug('caseRef: ' + caseRef.Id);
        caseRef.Form_Rule__c = formRuleMap.get('4015MD').Id;
        caseRef.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        update caseRef;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(caseRef, faRetail);  
        
        Third_Party__c tp = new Third_Party__c(Repossession__c = repo.Id);
        insert tp;
        
        return repo;
	}
	
}