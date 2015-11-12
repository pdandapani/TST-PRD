@isTest
private class RL_GenerateDocRequestControllerTest {
    @isTest static void test_method_one() {
        //Setup Data
        Test.startTest();
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
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        aCase.Form_Rule__c = formRuleMap.get('4015MD').Id;
        aCase.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        update aCase;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(aCase, faRetail);   
        System.debug(repo.BK_Active_or_Discharged__c);
        
        List<Form__c> formList = new Form__c[] {new Form__c(Copy_per_FAC__c = TRUE, Name='4015', Document_request_record_type__c='Rights Letters'), new Form__c(Name=RL_Constants.COVER_LETTER_FORM, Document_request_record_type__c='Rights Letters', Copy_per_FAC__c = TRUE)};
        insert formList;

        List<Form_Field__c> ffList = new Form_Field__c[] {new Form_Field__c(Primary_FAC__c = FALSE, Source_Field__c='iRepo_VIN__c', Source_Object__c='Repossession__c', Target_Field__c='VIN__c'),
                                                      new Form_Field__c(Source_Field__c='FirstName', Source_Object__c='FAC Account', Target_Field__c='CoCustomer_FirstName__c', Line_Item_Field__c = true, Line_item_Type__c = 'Co-Customers', WS_DestinationNode__c='50'),
                                                      new Form_Field__c(Source_Field__c='Other_Charges1__c', Source_Object__c='Repossession__c', Target_Field__c='OtherCharge_Charge__c', Line_Item_Field__c = true, Line_item_Type__c = 'Other Charges', WS_DestinationNode__c='100'),
                                                      new Form_Field__c(Source_Field__c='Vehicle_Identification_Number__c', Source_Object__c='Collateral__c', Target_Field__c='VIN__c', WS_DestinationNode__c='150'),
                                                      new Form_Field__c(Source_Field__c='Other_Charges2__c', Source_Object__c='Repossession__c', Target_Field__c='OtherCharge_Charge__c', Line_Item_Field__c = TRUE, Line_item_Type__c = 'Other Charges', WS_DestinationNode__c='200'),
                                                      new Form_Field__c(Source_Field__c='Mailing_Street1__c', Source_Object__c='Financial_Account_Customer__c', Target_Field__c='CoCustomer_AddyAddress1__c', Line_Item_Field__c = true, Line_item_Type__c = 'Co-Customers', WS_DestinationNode__c='250'),
                                                      new Form_Field__c(Source_Field__c='RL_Customer_Type__c', Source_Object__c='Financial_Account_Customer__c', Target_Field__c='Recipient__c', WS_DestinationNode__c='300'),
                                                      new Form_Field__c(Source_Field__c='Name', Source_Object__c='Form__c', Target_Field__c='SourceFormIdentifier1__c', WS_DestinationNode__c='350'),
                                                      new Form_Field__c(Source_Field__c='BillingPostalCode', Source_Object__c='FAC Account', Target_Field__c='Customer_AddyZipCode__c', Primary_FAC__c = TRUE, WS_DestinationNode__c='400'),
                                                    new Form_Field__c(Source_Field__c='BillingState', Source_Object__c='Dealership', Target_Field__c='Dealer_State__c', WS_DestinationNode__c='450')};
        insert ffList;

        Third_Party__c tp = new Third_Party__c(First_Name__c = 'John', Last_Name__c = 'Doe', Repossession__c = repo.Id, Attorney_Representing_Borrower__c=facs[0].Id);
        insert tp;

        Form_Rule_Junction__c formRuleJunction = new Form_Rule_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form__c=formList[0].Id);
        insert formRuleJunction;

        List<Form_Field_Junction__c> ffJunctionList = new Form_Field_Junction__c[] {new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[0].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[1].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[2].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[3].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[4].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[5].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[6].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[7].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[8].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[9].Id)};
        insert ffJunctionList;

        Case_Skills__c cs = RL_GenerateTestData.createCaseSkills();

        List<Form_Validation__c> fvList = RL_GenerateTestData.generateListOfValidations();
        insert fvList;
        
        Form_Rule_Validation_Junction__c frJunction = new Form_Rule_Validation_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form_Validation__c = fvList[0].Id);
        insert frJunction;
        
        PageReference pageRef= Page.RL_GenerateDocRequestPage;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.currentPage().getParameters().put('watermark', 'true');
        ApexPages.StandardController repoStdController = new ApexPages.StandardController(repo);
        RL_GenerateDocRequestController controller = new RL_GenerateDocRequestController(repoStdController); 
        Test.setMock(HttpCalloutMock.class, new RL_MockHttpResponseGenerator());
        controller.generateDocRequest();
        Document_Request__c docRequest = [SELECT Id, VIN__c FROM Document_Request__c WHERE Repossession__c =: repo.Id LIMIT 1];

        //Assertions
        System.AssertEquals(docRequest.VIN__c, repo.iRepo_VIN__c);
        System.AssertEquals(repo.Modify_REPO_Note__c, false);
        
        //Test second doc generation
        repo.Recorded_Legal_Sale_Date__c = Date.today();
        update repo;

        tp.Attorney_Representing_Borrower__c = null;
        update tp;        
		
        controller.generateDocRequest();
        controller.addErrorMessage(ApexPages.severity.CONFIRM, 'TEST');
        RL_GenerateDocRequestController.buildSystemMessage('1', repo.Id, '3', '4', '5');
        Test.stopTest();

        System.AssertEquals(repo.Recorded_Legal_Sale_Date__c, repo.Proposed_Notice_Date__c);
        //System.AssertEquals(repo.Modify_REPO_Note__c, true);

        

    }
    
    
    
    @isTest static void test_method_testPrintingDisabled() {
        //Setup Data
        Test.startTest();
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
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        aCase.Form_Rule__c = formRuleMap.get('4015MD').Id;
        aCase.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        update aCase;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(aCase, faRetail);   
        System.debug(repo.BK_Active_or_Discharged__c);
        
        List<Form__c> formList = new Form__c[] {new Form__c(Copy_per_FAC__c = TRUE, Name='4015', Document_request_record_type__c='Rights Letters'), new Form__c(Name=RL_Constants.COVER_LETTER_FORM, Document_request_record_type__c='Rights Letters', Copy_per_FAC__c = TRUE)};
        insert formList;

        List<Form_Field__c> ffList = new Form_Field__c[] {new Form_Field__c(Primary_FAC__c = FALSE, Source_Field__c='iRepo_VIN__c', Source_Object__c='Repossession__c', Target_Field__c='VIN__c'),
                                                      new Form_Field__c(Source_Field__c='FirstName', Source_Object__c='FAC Account', Target_Field__c='CoCustomer_FirstName__c', Line_Item_Field__c = true, Line_item_Type__c = 'Co-Customers', WS_DestinationNode__c='50'),
                                                      new Form_Field__c(Source_Field__c='Other_Charges1__c', Source_Object__c='Repossession__c', Target_Field__c='OtherCharge_Charge__c', Line_Item_Field__c = true, Line_item_Type__c = 'Other Charges', WS_DestinationNode__c='100'),
                                                      new Form_Field__c(Source_Field__c='Vehicle_Identification_Number__c', Source_Object__c='Collateral__c', Target_Field__c='VIN__c', WS_DestinationNode__c='150'),
                                                      new Form_Field__c(Source_Field__c='Other_Charges2__c', Source_Object__c='Repossession__c', Target_Field__c='OtherCharge_Charge__c', Line_Item_Field__c = TRUE, Line_item_Type__c = 'Other Charges', WS_DestinationNode__c='200'),
                                                      new Form_Field__c(Source_Field__c='Mailing_Street1__c', Source_Object__c='Financial_Account_Customer__c', Target_Field__c='CoCustomer_AddyAddress1__c', Line_Item_Field__c = true, Line_item_Type__c = 'Co-Customers', WS_DestinationNode__c='250'),
                                                      new Form_Field__c(Source_Field__c='RL_Customer_Type__c', Source_Object__c='Financial_Account_Customer__c', Target_Field__c='Recipient__c', WS_DestinationNode__c='300'),
                                                      new Form_Field__c(Source_Field__c='Name', Source_Object__c='Form__c', Target_Field__c='SourceFormIdentifier1__c', WS_DestinationNode__c='350'),
                                                      new Form_Field__c(Source_Field__c='BillingPostalCode', Source_Object__c='FAC Account', Target_Field__c='Customer_AddyZipCode__c', Primary_FAC__c = TRUE, WS_DestinationNode__c='400'),
                                                    new Form_Field__c(Source_Field__c='BillingState', Source_Object__c='Dealership', Target_Field__c='Dealer_State__c', WS_DestinationNode__c='450')};
        insert ffList;

        Third_Party__c tp = new Third_Party__c(First_Name__c = 'John', Last_Name__c = 'Doe', Repossession__c = repo.Id, Attorney_Representing_Borrower__c=facs[0].Id);
        insert tp;

        Form_Rule_Junction__c formRuleJunction = new Form_Rule_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form__c=formList[0].Id);
        insert formRuleJunction;

        List<Form_Field_Junction__c> ffJunctionList = new Form_Field_Junction__c[] {new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[0].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[1].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[2].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[3].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[4].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[5].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[6].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[7].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[8].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[9].Id)};
        insert ffJunctionList;

        Case_Skills__c cs = RL_GenerateTestData.createCaseSkills();

        List<Form_Validation__c> fvList = RL_GenerateTestData.generateListOfValidations();
        insert fvList;
        
        Form_Rule_Validation_Junction__c frJunction = new Form_Rule_Validation_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form_Validation__c = fvList[0].Id);
        insert frJunction;
        
        PageReference pageRef= Page.RL_GenerateDocRequestPage;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.currentPage().getParameters().put('watermark', 'true');
        ApexPages.StandardController repoStdController = new ApexPages.StandardController(repo);
        RL_GenerateDocRequestController controller = new RL_GenerateDocRequestController(repoStdController); 
        Test.setMock(HttpCalloutMock.class, new RL_MockHttpResponseGenerator());
        
        RL_GenerateDocRequestController.printingEnabled = 'FALSE';
        
        controller.generateDocRequest();
        Document_Request__c docRequest = [SELECT Id, VIN__c FROM Document_Request__c WHERE Repossession__c =: repo.Id LIMIT 1];

        //Assertions
        System.AssertEquals(docRequest.VIN__c, repo.iRepo_VIN__c);
        System.AssertEquals(repo.Modify_REPO_Note__c, false);

    }
    
    
    
    @isTest static void test_method_testing_bankruptcy_Block() {
        //Setup Data
        Test.startTest();
        
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        faRetail.Bankruptcy_Flag__c = 'A';
        update faRetail; //TESTING 
        Id personAccountRT = RL_GenerateTestData.getRecordType('Account', 'Customer');
        List<Account> accList = new Account[]{new Account(FirstName='TEST1', LastName='ACCOUNT1', recordTypeId=personAccountRT), new Account(FirstName='TEST2', LastName='ACCOUNT2', recordTypeId=personAccountRT)};
        insert accList;

        List<Financial_Account_Customer__c> facs = new Financial_Account_Customer__c[] {
            new Financial_Account_Customer__c(Customer_Role_Type__c='0-Primary Borrower', Account__c = accList[0].Id, Borrower_Status__c = 'Active', Name = 'Test FAC1', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071', RL_Bankruptcy_Status__c='Filing Party'),
            new Financial_Account_Customer__c(Customer_Role_Type__c='6-Co-Borrower', Account__c = accList[1].Id, Borrower_Status__c = 'Active', Name = 'Test FAC2', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071')
        };

        insert facs;
        
        Collateral__c collateral = new Collateral__c(Name='Test Collateral', Vehicle_Identification_Number__c='12345');
        insert collateral;
        
        faRetail.Collateral__c = collateral.Id;
        update faRetail;

        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        aCase.Form_Rule__c = formRuleMap.get('4015MD').Id;
        aCase.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        update aCase;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(aCase, faRetail);
        System.debug(repo.BK_Active_or_Discharged__c);
        
        List<Form__c> formList = new Form__c[] {new Form__c(Copy_per_FAC__c = TRUE, Name='4015', Document_request_record_type__c='Rights Letters'), new Form__c(Name=RL_Constants.COVER_LETTER_FORM, Document_request_record_type__c='Rights Letters', Copy_per_FAC__c = TRUE)};
        insert formList;

        List<Form_Field__c> ffList = new Form_Field__c[] {new Form_Field__c(Primary_FAC__c = FALSE, Source_Field__c='iRepo_VIN__c', Source_Object__c='Repossession__c', Target_Field__c='VIN__c'),
                                                      new Form_Field__c(Source_Field__c='FirstName', Source_Object__c='FAC Account', Target_Field__c='CoCustomer_FirstName__c', Line_Item_Field__c = true, Line_item_Type__c = 'Co-Customers', WS_DestinationNode__c='50'),
                                                      new Form_Field__c(Source_Field__c='Other_Charges1__c', Source_Object__c='Repossession__c', Target_Field__c='OtherCharge_Charge__c', Line_Item_Field__c = true, Line_item_Type__c = 'Other Charges', WS_DestinationNode__c='100'),
                                                      new Form_Field__c(Source_Field__c='Vehicle_Identification_Number__c', Source_Object__c='Collateral__c', Target_Field__c='VIN__c', WS_DestinationNode__c='150'),
                                                      new Form_Field__c(Source_Field__c='Other_Charges2__c', Source_Object__c='Repossession__c', Target_Field__c='OtherCharge_Charge__c', Line_Item_Field__c = TRUE, Line_item_Type__c = 'Other Charges', WS_DestinationNode__c='200'),
                                                      new Form_Field__c(Source_Field__c='Mailing_Street1__c', Source_Object__c='Financial_Account_Customer__c', Target_Field__c='CoCustomer_AddyAddress1__c', Line_Item_Field__c = true, Line_item_Type__c = 'Co-Customers', WS_DestinationNode__c='250'),
                                                      new Form_Field__c(Source_Field__c='RL_Customer_Type__c', Source_Object__c='Financial_Account_Customer__c', Target_Field__c='Recipient__c', WS_DestinationNode__c='300'),
                                                      new Form_Field__c(Source_Field__c='Name', Source_Object__c='Form__c', Target_Field__c='SourceFormIdentifier1__c', WS_DestinationNode__c='350'),
                                                      new Form_Field__c(Source_Field__c='BillingPostalCode', Source_Object__c='FAC Account', Target_Field__c='Customer_AddyZipCode__c', Primary_FAC__c = TRUE, WS_DestinationNode__c='400'),
                                                    new Form_Field__c(Source_Field__c='BillingState', Source_Object__c='Dealership', Target_Field__c='Dealer_State__c', WS_DestinationNode__c='450')};
        insert ffList;

        Third_Party__c tp = new Third_Party__c(First_Name__c = 'John', Last_Name__c = 'Doe', Repossession__c = repo.Id, Attorney_Representing_Borrower__c=facs[0].Id);
        insert tp;

        Form_Rule_Junction__c formRuleJunction = new Form_Rule_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form__c=formList[0].Id);
        insert formRuleJunction;

        List<Form_Field_Junction__c> ffJunctionList = new Form_Field_Junction__c[] {new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[0].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[1].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[2].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[3].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[4].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[5].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[6].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[7].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[8].Id),
                                                                                new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=ffList[9].Id)};
        insert ffJunctionList;

        Case_Skills__c cs = RL_GenerateTestData.createCaseSkills();

        List<Form_Validation__c> fvList = RL_GenerateTestData.generateListOfValidations();
        insert fvList;
        
        Form_Rule_Validation_Junction__c frJunction = new Form_Rule_Validation_Junction__c(Form_Rule__c=formRuleMap.get('4015MD').Id, Form_Validation__c = fvList[0].Id);
        insert frJunction;
        
        PageReference pageRef= Page.RL_GenerateDocRequestPage;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('Id', repo.Id);
        ApexPages.currentPage().getParameters().put('watermark', 'true');
        ApexPages.StandardController repoStdController = new ApexPages.StandardController(repo);
        RL_GenerateDocRequestController controller = new RL_GenerateDocRequestController(repoStdController); 
        Test.setMock(HttpCalloutMock.class, new RL_MockHttpResponseGenerator());
        controller.generateDocRequest();
        //Document_Request__c docRequest = [SELECT Id, VIN__c FROM Document_Request__c WHERE Repossession__c =: repo.Id LIMIT 1];

        //Assertions
        System.assert(ApexPages.getMessages().get(0).getDetail() != null);

        

    }
    
    
    
    
    
    
}