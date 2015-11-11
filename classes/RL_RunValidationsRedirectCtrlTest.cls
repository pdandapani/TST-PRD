@isTest
private class RL_RunValidationsRedirectCtrlTest {
	
	
	static testmethod void testControllerMethods() {
		
		Case caseRef;
		Repossession__c repo = setupData(caseRef);
		
		Map<String, Schema.SObjectField> fldObjMapfldObjMap = schema.SObjectType.Repossession__c.fields.getMap();
		String[] otherFields = new String[]{'Financial_Account__r.Collateral__r.Vehicle_Identification_Number__c, Case__r.Form_Rule__c'};
		String repoQueryString = RL_Utility.getQueryStringForSelectStar(fldObjMapfldObjMap, 'Repossession__c', otherFields);
		repoQueryString += ' WHERE id = \'' + repo.Id + '\'';
		repo = (Repossession__c)Database.query(repoQueryString);
		
		PageReference pageRef = Page.Rl_CloneCaseInConsole;
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(repo);
        
        Test.setCurrentPage(pageRef);
        RL_RunValidationsRedirectController controller = new RL_RunValidationsRedirectController(standardCtrler);
        
        controller.executeValidations();
        
	}
	
	
	static testmethod void testControllerMethodsWithErrorCatch() {
		
		Case caseRef;
		Repossession__c repo = setupData(caseRef);
		
		
		
		
		Map<String, Schema.SObjectField> fldObjMapfldObjMap = schema.SObjectType.Repossession__c.fields.getMap();
		String[] otherFields = new String[]{'Financial_Account__r.Collateral__r.Vehicle_Identification_Number__c', 'Case__r.Form_Rule__c'};
		String repoQueryString = RL_Utility.getQueryStringForSelectStar(fldObjMapfldObjMap, 'Repossession__c', otherFields);
		repoQueryString += ' WHERE id = \'' + repo.Id + '\'';
		repo = (Repossession__c)Database.query(repoQueryString);
		
		Form_Rule_Validation_Junction__c junctObj = [select Form_Validation__c, Form_Rule__c, Form_Validation__r.RL_Field_Name1__c
														from Form_Rule_Validation_Junction__c
														where Form_Validation__r.SObject__c = 'Repossession__c'
														and Form_Rule__c = :repo.Case__r.Form_Rule__c
														limit 1];
		
		Form_Validation__c formValidationRef = junctObj.Form_Validation__r;
		formValidationRef.RL_Field_Name1__c = 'Dummy_Field__c_x'; //to force error.
		update formValidationRef; 
		
		
		PageReference pageRef = Page.Rl_CloneCaseInConsole;
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(repo);
        
        Test.setCurrentPage(pageRef);
        RL_RunValidationsRedirectController controller = new RL_RunValidationsRedirectController(standardCtrler);
        
        controller.executeValidations();
        
        system.assert(controller.errDisplayText != null);
	}
	
	
	
	
	static private Repossession__c setupData(Case caseRef) {
		//Setup Data
		
		Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
		
		List<Form_Validation__c> fvList = RL_GenerateTestData.generateListOfValidations();
        insert fvList;
        Form_Rule_Validation_Junction__c frJunction = new Form_Rule_Validation_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form_Validation__c = fvList[0].Id);
        insert frJunction;
		
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        faRetail.Bankruptcy_Flag__c = 'A'; //for repo formula field;
        Id personAccountRT = RL_GenerateTestData.getRecordType('Account', 'Customer');
        List<Account> accList = new Account[]{new Account(FirstName='TEST1', LastName='ACCOUNT1', recordTypeId=personAccountRT), new Account(FirstName='TEST2', LastName='ACCOUNT2', recordTypeId=personAccountRT)};
        insert accList;

        List<Financial_Account_Customer__c> facs = new Financial_Account_Customer__c[] {
            new Financial_Account_Customer__c(Customer_Role_Type__c='0-Primary Borrower', Account__c = accList[0].Id, Borrower_Status__c = 'Active', Name = 'Test FAC1', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071', RL_Bankruptcy_Status__c='test'),
            new Financial_Account_Customer__c(Customer_Role_Type__c='6-Co-Borrower', Account__c = accList[1].Id, Borrower_Status__c = 'Active', Name = 'Test FAC2', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071')
        };
        insert facs;
        
        Collateral__c collateral = new Collateral__c(Name='Test Collateral', Vehicle_Identification_Number__c='12345');
        insert collateral;
        
        faRetail.Collateral__c = collateral.Id;
        update faRetail;

        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        caseRef = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        caseRef.Form_Rule__c = formRuleMap.get('4015MD').Id;
        caseRef.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        update caseRef;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(caseRef, faRetail); 
        update repo;
        
        return repo;
	}
	
}