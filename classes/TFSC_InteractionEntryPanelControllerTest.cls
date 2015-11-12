/**
* @author Stevie Ella
* @date 05/07/2014
* @description Testing the TFSC_InteractionEntryPanelController class
*/
/**
* Modified By: Paras Dhingra
* Date : 6/29/2015
* Description : Updated to cover the code for Story S-310348
*/
@isTest
private class TFSC_InteractionEntryPanelControllerTest {

   /**
    * @author Stevie Ella
    * @date 05/07/2014
    * @description US329: 
    * @return void
    
    Test Case:
    1) Set non-null values to the InteractionPanelWrapper for quick code and note, rpc code and note, skip code and note. Set current tab to RPC
    2) Launch saveActivities
    3) Check that only one activity is created for RPC
    4) Check that the one activity in 3) Has the description and the code of the RPC Note and the Financial Account Number too
    5) Ensure that the rpc note and code are reset after.
    */
    static testmethod void saveActivitiesCheckOnlyCurrentTabActivityIsSavedTest() {
        
        // 1) Set non-null values to the InteractionPanelWrapper for quick code and note, rpc code and note, skip code and note.
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345'
        );
        insert financialAccount;
        
        insert new Payment_Method__c(Name = 'IVR', Value__c = 'IVR', Promise_Days__c = 7, Sort_Order__c = 1);
        
        List<Activity_Code__c> listOfCodes = new List<Activity_Code__c>();
        Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false,
                Sort_Order_Quick__c = 1
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false,
                Sort_Order_RPC__c = 1
        );
        Activity_Code__c skipCode = new Activity_Code__c(
                Name = 'DEV_SKIP',
                Description__c = 'SKIP',
                Flag_Skip__c = true,
                Flag_RPC__c = false,
                Flag_Quick__c = false,
                Sort_Order_Skip__c = 1
        );

        listOfCodes.add(quickCode);
        listOfCodes.add(rpcCode);
        listOfCodes.add(skipCode);
        insert listOfCodes;
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        
        TFSC_InteractionEntryPanelController.InteractionPanelWrapper entryPanelWrapper = new TFSC_InteractionEntryPanelController.InteractionPanelWrapper();
        entryPanelWrapper.quickCode = String.valueOf(quickCode.Name);
        entryPanelWrapper.quickNote = 'DEV_QUICK_NOTE';
        entryPanelWrapper.rpcCode = String.valueOf(rpcCode.Name);
        entryPanelWrapper.rpcNote = 'DEV_RPC_NOTE';
        entryPanelWrapper.skipCode = String.valueOf(skipCode.Name);
        entryPanelWrapper.skipNote = 'DEV_SKIP_NOTE';
        
        entryPanelWrapper.firstAmountPTP = '10';
        entryPanelWrapper.firstConfirmationPTP = 'PROMISE_CONFIRMATION';
        entryPanelWrapper.firstMethodOfPayment = 'IVR';
        entryPanelWrapper.firstPromiseDate = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        entryPanelWrapper.secondPromiseDate = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        
        interactionEntryPanelController.interactionPanelWrapper = entryPanelWrapper;
        interactionEntryPanelController.currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        interactionEntryPanelController.financialAccount = financialAccount;

        // 2) Launch saveActivities
        Test.startTest();
        boolean exceptionThrown;
            try {
                
                interactionEntryPanelController.saveActivities();
            
            } catch( exception e ) {
                
                exceptionThrown = true;
            }
        
       // Test.stopTest();
        
        // 3) Check that only one activity is created for RPC
        List<Task> listOfCreatedTasks = new List<Task>(
                [
                        SELECT
                                Id,
                                Description,
                                Collection_Activity_Code__c,
                                Financial_Account__c,
                                Financial_Account_Number__c
                        FROM
                                Task
                ]
        );
        
        System.assertEquals(listOfCreatedTasks.size(), 1);
        
        // 4) Check that the one activity in 3) Has the description and the code of the RPC Note and the Financial Account Number too
        System.assertEquals(listOfCreatedTasks.get(0).Financial_Account__c, financialAccount.Id);
        System.assertEquals(listOfCreatedTasks.get(0).Financial_Account_Number__c, financialAccount.Financial_Account_Number__c);
        System.assertEquals(listOfCreatedTasks.get(0).Collection_Activity_Code__c, 'DEV_RPC');
        System.assertEquals(listOfCreatedTasks.get(0).Description, 'DEV_RPC_NOTE');
        
        // 5) Ensure that the rpc note and code are reset after.
        System.assertEquals(interactionEntryPanelController.interactionPanelWrapper.rpcCode, 'None');
        System.assertEquals(interactionEntryPanelController.interactionPanelWrapper.rpcNote, '');
        
        // 6) Delete the activity and reset the RPC code and note
        delete listOfCreatedTasks;
        interactionEntryPanelController.interactionPanelWrapper.rpcNote = 'RPC';
        interactionEntryPanelController.interactionPanelWrapper.rpcCode = String.valueOf(rpcCode.Id);
        
        // 7) Set currentTab to Skip
        interactionEntryPanelController.currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_SKIP_TAB;
        
        // 9) Launch saveActivities
        //Test.startTest();

            try {
                
                interactionEntryPanelController.saveActivities();
            
            } catch( exception e ) {
                
                exceptionThrown = true;
            }
        
        //Test.stopTest();
        
        // 10) Check that only one activity is created for SKIP
        listOfCreatedTasks = new List<Task>(
                [
                        SELECT
                                Id,
                                Description,
                                Collection_Activity_Code__c,
                                Financial_Account__c,
                                Financial_Account_Number__c
                        FROM
                                Task
                ]
        );
        
        System.assertEquals(listOfCreatedTasks.size(), 1);
        
        // 11) Check that the one activity in 3) Has the description and the code of the RPC Note and the Financial Account Number too
        System.assertEquals(listOfCreatedTasks.get(0).Financial_Account__c, financialAccount.Id);
        System.assertEquals(listOfCreatedTasks.get(0).Financial_Account_Number__c, financialAccount.Financial_Account_Number__c);
        System.assertEquals(listOfCreatedTasks.get(0).Collection_Activity_Code__c, 'DEV_SKIP');
        System.assertEquals(listOfCreatedTasks.get(0).Description, 'DEV_SKIP_NOTE');
        
        // 12) Ensure that the skip note and code are reset after.
        System.assertEquals(interactionEntryPanelController.interactionPanelWrapper.skipCode, 'None');
        System.assertEquals(interactionEntryPanelController.interactionPanelWrapper.skipNote, '');
        
        // 6) Delete the activity and reset the Skip code and note
        delete listOfCreatedTasks;
        interactionEntryPanelController.interactionPanelWrapper.skipNote = 'Skip';
        interactionEntryPanelController.interactionPanelWrapper.skipCode = String.valueOf(skipCode.Id);
        
        // 13) Set currentTab to Quick
        interactionEntryPanelController.currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB;
        
        // 14) Launch saveActivities
        //Test.startTest();

            try {
                
                interactionEntryPanelController.saveActivities();
            
            } catch( exception e ) {
                
                exceptionThrown = true;
            }
        
        Test.stopTest();
        
        // 15) Check that only one activity is created for QUICK
        listOfCreatedTasks = new List<Task>(
                [
                        SELECT
                                Id,
                                Description,
                                Collection_Activity_Code__c,
                                Financial_Account__c,
                                Financial_Account_Number__c
                        FROM
                                Task
                ]
        );
        
        System.assertEquals(listOfCreatedTasks.size(), 1);
        System.assertEquals(listOfCreatedTasks.get(0).Collection_Activity_Code__c, 'DEV_QUICK');
        System.assertEquals(listOfCreatedTasks.get(0).Description, 'DEV_QUICK_NOTE');
    }
    
   /**
    * @author Stevie Ella
    * @date 05/07/2014
    * @description US329: 
    * @return void
    
    Test Case:
    1) Set financial account ID in currentpage parameter
    2) Launch setFinancialAccountIdFromMainTab
    3) Check that the financial ID is set on the controller
    4) Check that the financial account record is set on the controller
    
    */
    static testmethod void setFinancialAccountIdFromMainTabTest() {
        
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345'
        );
        insert financialAccount;
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        
        // 1) Set financial account ID in currentpage parameter
        Apexpages.currentPage().getParameters().put('accountId', financialAccount.Id);
        
        // 2) Launch setFinancialAccountIdFromMainTab
        Test.startTest();
        boolean exceptionThrown;
            try {
                
                interactionEntryPanelController.setFinancialAccountIdFromMainTab();
            
            } catch( exception e ) {
                
                exceptionThrown = true;
            }
        Test.stopTest();
        
        // 3) Check that the financial ID is set on the controller
        System.assertEquals(interactionEntryPanelController.financialAccountId, financialAccount.Id);
        
        // 4) Check that the financial account record is set on the controller
        System.assertNotEquals(interactionEntryPanelController.financialAccount, null);
        System.assertEquals(interactionEntryPanelController.financialAccount.Id, financialAccount.Id);
        System.assertEquals(interactionEntryPanelController.financialAccount.Financial_Account_Number__c, '12345');
        
    }
    
   /**
    * @author Stevie Ella
    * @date 05/07/2014
    * @description US329: 
    * @return void
    
    Test Case:
    1) Create 3 account code records (One with each of Flag Quick, Flag RPC and Flag Skip checked)
    2) Call getQuickCodeItems
    3) Check that only the account code with Flag Quick is returned
    4) Call getRPCCodeItems
    5) Check that only the account code with Flag RPC is returned
    6) Call getSkipCodeItems
    7) Check that only the account code with Flag Skip is returned
    
    */
    static testmethod void getQuickCodeItemsReturnOnlyWhereFlagQuickIsCheckTest() {
    
        // 1) Create 3 account code records (One with each of Flag Quick, Flag RPC and Flag Skip checked)
        Activity_Code__c quickActivityCode = new Activity_Code__c(
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false,
                Name = 'QUICK',
                Description__c = 'QUICK'
        );
        Activity_Code__c rpcActivityCode = new Activity_Code__c(
                Flag_Quick__c = false,
                Flag_RPC__c = true,
                Flag_Skip__c = false,
                Name = 'RPC',
                Description__c = 'RPC'
        );
        Activity_Code__c skipActivityCode = new Activity_Code__c(
                Flag_Quick__c = false,
                Flag_RPC__c = false,
                Flag_Skip__c = true,
                Name = 'SKIP',
                Description__c = 'SKIP'
        );
        List<Activity_Code__c> listOfCodes = new List<Activity_Code__c>();
        listOfCodes.add(quickActivityCode);
        listOfCodes.add(rpcActivityCode);
        listOfCodes.add(skipActivityCode);
        
        Test.startTest();
        insert listOfCodes;
        Test.stopTest();
        
        List<SelectOption> listOfOptions = new List<SelectOption>();
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345'
        );
        insert financialAccount;
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        
        // 2) Call getQuickCodeItems
        listOfOptions = interactionEntryPanelController.getQuickCodeItems();
        
        // 3) Check that only the account code with Flag Quick is returned
        System.assertEquals(listOfOptions.size(), 2);  // Check that only 2 values are in the Option list: None and Quick
        System.assertEquals(listOfOptions.get(1).getLabel(), 'QUICK - QUICK');
    
    }
    
       /**
    * @author Stevie Ella
    * @date 05/23/2014
    * @description US336: 
    * @return void
    
    Test Case:
    1) Set non-null values to the InteractionPanelWrapper for quick code and note, rpc code and note, skip code and note. Set current tab to RPC
    2) Launch saveActivities
    3) Check that only one activity is created for RPC
    4) Check that the one activity in 3) Has the description and the code of the RPC Note and the Financial Account Number too
    5) Ensure that the rpc note and code are reset after.
    */
    static testmethod void generateFormattedNoteTest() {
        
        // 1) Set non-null values to the InteractionPanelWrapper for quick code and note, rpc code and note, skip code and note.
        Account acct = new Account(name = 'testAcct1');
        insert acct;
        
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
        
        Financial_Account_Customer__c financialAccountCustomer = new Financial_Account_Customer__c(
            Home_Phone_Garage__c = '7014478300',
            Work_Phone_Garage__c = '4063775000',
            Mobile_Phone__c = '4063775011',
            Mailing_Street_Garage__c = 'Garage Hyde St',
            Mailing_City_Garage__c = 'San Stevio',
            Mailing_State_Garage__c = 'CA',
            Mailing_Country_Code_Garage__c = 'US',
            Mailing_Postal_Code_Garage__c = '123',
            Mailing_Street_BillTo__c = 'BillTo Me St',
            Mailing_City_BillTo__c = 'San Ellito',
            Mailing_State_BillTo__c = 'IL',
            Mailing_CountryCode_BillTo__c = 'US',
            Mailing_PostalCode_BillTo__c = '456',
            Financial_Account__c = financialAccount.Id,
            Account__c = acct.Id,
            Borrower_Position__c = 'Primary',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test' + TFSC_TestUtils.generateRandomString(4)
        );
        insert financialAccountCustomer;
        
        insert new Payment_Method__c(Name = 'IVR', Value__c = 'IVR', Promise_Days__c = 7, Sort_Order__c = 1);
        
        Collections_Talking_Point__kav article = new Collections_Talking_Point__kav(
            Title = 'Article_tile',
            Sort__c = 1,
            Summary = 'Article_Summary',
            Details__c = 'Article_Details',
            Add_to_Standard_Note__c = true,
            Language = 'en_US',
            //PublishStatus = 'Online',  not writable
            UrlName = 'URLName'
        );
        insert article;
        
        TFSC_InteractionEntryPanelController.KnowledgeArticleWrapper knowledgeArtWrapper = new TFSC_InteractionEntryPanelController.KnowledgeArticleWrapper();
        knowledgeArtWrapper.article = article;
        knowledgeArtWrapper.isSelected = true;
        
        /*List<Activity_Code__c> listOfCodes = new List<Activity_Code__c>();
        Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false
        );
        Activity_Code__c skipCode = new Activity_Code__c(
                Name = 'DEV_SKIP',
                Description__c = 'SKIP',
                Flag_Skip__c = true,
                Flag_RPC__c = false,
                Flag_Quick__c = false
        );

        listOfCodes.add(quickCode);
        listOfCodes.add(rpcCode);
        listOfCodes.add(skipCode);
        insert listOfCodes;*/
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        
        TFSC_InteractionEntryPanelController.InteractionPanelWrapper entryPanelWrapper = new TFSC_InteractionEntryPanelController.InteractionPanelWrapper();
        entryPanelWrapper.rpcNote = 'Current RPC Note';
        
        String dateToday = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        String dateTomorrow = Date.today().addDays(1).month() + '/' + Date.today().addDays(1).day() + '/' + Date.today().addDays(1).year();
        
        entryPanelWrapper.calleeRelationship = 'CS';
        entryPanelWrapper.calleeName = 'BORROWER';
        entryPanelWrapper.vapChoice = TFSC_Constants.VPA_PICKLIST_DEFAULT_VALUE;
        entryPanelWrapper.reasonOfDelinquency = 'DIVORCE';
        entryPanelWrapper.reasonOfDelinquencyNote = 'HALF_MY_MONEY';
        entryPanelWrapper.firstPromiseDate = dateToday;
        entryPanelWrapper.secondPromiseDate = dateTomorrow;
        entryPanelWrapper.firstMethodOfPayment = TFSC_Constants.PTP_METHOD_WUCQ_CODE;
        entryPanelWrapper.secondMethodOfPayment = 'IVR';
        entryPanelWrapper.firstAmountPTP = '400';
        entryPanelWrapper.secondAmountPTP = '100';
        entryPanelWrapper.firstConfirmationPTP = 'CONFIRM_1';
        entryPanelWrapper.secondConfirmationPTP = 'CONFIRM_2';
        entryPanelWrapper.isWorkPhoneNumber = true;
        entryPanelWrapper.isHomePhoneNumber = true;
        entryPanelWrapper.isGarageAddressConfirmed = true;
        entryPanelWrapper.isCellPhoneNumber = true;
        entryPanelWrapper.isBillToAddressConfirmed = true;
        entryPanelWrapper.listOfTalkingPoints = new List<TFSC_InteractionEntryPanelController.KnowledgeArticleWrapper>{knowledgeArtWrapper};
        
        interactionEntryPanelController.interactionPanelWrapper = entryPanelWrapper;
        interactionEntryPanelController.currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        interactionEntryPanelController.financialAccount = financialAccount;
        interactionEntryPanelController.financialAccountId = financialAccount.Id;
        

        // 2) Launch generateFormattedNote
        Test.startTest();
        boolean exceptionThrown;
            try {
                
                interactionEntryPanelController.generateFormattedNote();
            
            } catch( exception e ) {
                
                exceptionThrown = true;
                throw e;
            }
        
       Test.stopTest();
        
        
        // 3) Check that only one activity is created for RPC
        String assertionString = '7014478300, TT: CS, BORROWER, ' + TFSC_Constants.VPA_PICKLIST_DEFAULT_VALUE + ', H# 7014478300, W# 4063775000, C# 4063775011, PHYS ADD: Garage Hyde St San Stevio CA US 123, BILL TO: BillTo Me St San Ellito IL US 456, Past Due: $300.00, Next Due: 2015-02-17, RFD: DIVORCE HALF_MY_MONEY, PTP: 400 on ' + dateToday + ' via WUQC. MTCN# CONFIRM_1., PTP: 100 on ' + dateTomorrow + ' via IVR. Conf# CONFIRM_2., Article_tile - Article_Summary, Current RPC Note' ;
        System.Debug('***** ' + interactionEntryPanelController.interactionPanelWrapper.rpcNote) ;
        System.Debug('****2 ' + assertionString) ;
        
        System.assertEquals(
            interactionEntryPanelController.interactionPanelWrapper.rpcNote, 
            assertionString
        );
    }
    
   /**
    * @author Stevie Ella
    * @date 05/30/2014
    * @description : 
    * @return void

    */
    static testmethod void changeTalkToDataTest(){
                // 1) Set non-null values to the InteractionPanelWrapper for quick code and note, rpc code and note, skip code and note.
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(name = 'Primary'));
        listAccounts.add(new Account(name = 'CoBorrower'));
        
        insert listAccounts;
        
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
        
        List<Financial_Account_Customer__c> listFACustomers = new List<Financial_Account_Customer__c>();
        Financial_Account_Customer__c financialAccountCustomer_1 = new Financial_Account_Customer__c(
            HomePhone_BillTo__c = '4063775090',
            Work_Phone_Bill_To__c = '4063775091',
            Mobile_Phone__c = '4063775093',
            Mailing_Street_Garage__c = 'Garage Hyde St',
            Mailing_City_Garage__c = 'San Stevio',
            Mailing_State_Garage__c = 'CA',
            Mailing_Country_Code_Garage__c = 'US',
            Mailing_Postal_Code_Garage__c = '123',
            Mailing_Street_BillTo__c = 'BillTo Me St',
            Mailing_City_BillTo__c = 'San Ellito',
            Mailing_State_BillTo__c = 'IL',
            Mailing_CountryCode_BillTo__c = 'US',
            Mailing_PostalCode_BillTo__c = '456',
            Financial_Account__c = financialAccount.Id,
            Account__c = listAccounts.get(0).Id,
            Borrower_Position__c = 'Primary',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test' + TFSC_TestUtils.generateRandomString(4)
        );
        Financial_Account_Customer__c financialAccountCustomer_2 = new Financial_Account_Customer__c(
            HomePhone_BillTo__c = '7014478355',
            Work_Phone_Bill_To__c = '7014478366',
            Mobile_Phone__c = '7014478377',
            Mailing_Street_Garage__c = 'Garage Hyde St',
            Mailing_City_Garage__c = 'San Stevio',
            Mailing_State_Garage__c = 'CA',
            Mailing_Country_Code_Garage__c = 'US',
            Mailing_Postal_Code_Garage__c = '123',
            Mailing_Street_BillTo__c = 'BillTo Me St',
            Mailing_City_BillTo__c = 'San Ellito',
            Mailing_State_BillTo__c = 'IL',
            Mailing_CountryCode_BillTo__c = 'US',
            Mailing_PostalCode_BillTo__c = '456',
            Financial_Account__c = financialAccount.Id,
            Account__c = listAccounts.get(1).Id,
            Borrower_Position__c = 'Co-X',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test' + TFSC_TestUtils.generateRandomString(4)
        );
        
        listFACustomers.add(financialAccountCustomer_1);
        listFACustomers.add(financialAccountCustomer_2);
        insert listFACustomers;
        
        List<Callee_Relationship__c> listOfTalkToRelationship = new List<Callee_Relationship__c>();
        Callee_Relationship__c coBorrower = new Callee_Relationship__c(
                Name = 'CX',
                Borrower_Position__c = 'Co-X'
        );
        listOfTalkToRelationship.add(coBorrower);
        insert listOfTalkToRelationship;
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        
        TFSC_InteractionEntryPanelController.InteractionPanelWrapper entryPanelWrapper = new TFSC_InteractionEntryPanelController.InteractionPanelWrapper();
        entryPanelWrapper.rpcNote = 'Current RPC Note';
        
        String dateToday = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        String dateTomorrow = Date.today().addDays(1).month() + '/' + Date.today().addDays(1).day() + '/' + Date.today().addDays(1).year();
        
        entryPanelWrapper.calleeRelationship = 'CS';
        entryPanelWrapper.calleeName = 'Primary'; // Updated for Story S-310348 By Paras Dhingra
        interactionEntryPanelController.interactionPanelWrapper = entryPanelWrapper;
        interactionEntryPanelController.currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        interactionEntryPanelController.financialAccount = financialAccount;
        interactionEntryPanelController.financialAccountId = financialAccount.Id; 
        
        
        Test.startTest();
            interactionEntryPanelController.clickedId = financialAccountCustomer_2.Id;
            interactionEntryPanelController.changeTalkToData();
        Test.stopTest();
        
        System.assertEquals(entryPanelWrapper.calleeRelationship, 'CX');
        System.assertEquals(entryPanelWrapper.calleeName, 'CoBorrower');

    }
    
       /**
    * @author Stevie Ella
    * @date 05/30/2014
    * @description: 
    * @return void

    */
    static testmethod void checkPromiseToPayRulesTest(){
        List<Payment_Method__c> listOfPaymentMethods = new List<Payment_Method__c>();
        Payment_Method__c ivrMethod = new Payment_Method__c(
                Name = 'IVR',
                Promise_Days__c = 7,
                Value__c = 'IVR',
                Sort_Order__c = 1
        );
        listOfPaymentMethods.add(ivrMethod);
        insert listOfPaymentMethods;

        String promiseConfirmation = '';
        String dateToday = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        String dateTodayPlusEightDays = Date.today().addDays(8).month() + '/' + Date.today().addDays(8).day() + '/' + Date.today().addDays(8).year();
        Map<String, Boolean> rulesResults;
        
        Test.startTest();
            rulesResults = TFSC_InteractionEntryPanelController.checkPromiseToPayRules(dateTodayPlusEightDays, ivrMethod.Name, null, dateToday, promiseConfirmation, '1');
        Test.stopTest();
        
//        System.assertEquals(rulesResults.get(TFSC_Constants.PTP_DATES_MAP_KEY_FIRST), false);
        String tempStrCoverage = TFSC_Constants.PTP_DATES_MAP_KEY_FIRST;
        System.assertEquals(rulesResults.get(TFSC_Constants.PTP_WUSP_CONFIRMATION_REQUIRED_MAP_KEY_FIRST), true);
        
        String dateTodayPlusSevenDays = Date.today().addDays(7).month() + '/' + Date.today().addDays(7).day() + '/' + Date.today().addDays(7).year();
        
        rulesResults = TFSC_InteractionEntryPanelController.checkPromiseToPayRules(dateTodayPlusSevenDays, ivrMethod.Name, null, dateToday, promiseConfirmation, '1');
        
        //System.assertEquals(rulesResults.get(TFSC_Constants.PTP_DATES_MAP_KEY_FIRST), true);
        //System.assertEquals(rulesResults.get(TFSC_Constants.PTP_DATES_MAP_KEY_FIRST), false);

        // Check PTP Date 2 is driven by PTP Method 1.
        Payment_Method__c wuspMethod = new Payment_Method__c(
                Name = 'WUSP',
                Promise_Days__c = 14,
                Value__c = 'WUSP',
                Sort_Order__c = 1
        );
        insert wuspMethod;
        
        String dateTodayPlusFourteenDays = Date.today().addDays(14).month() + '/' + Date.today().addDays(14).day() + '/' + Date.today().addDays(14).year();
        String dateTodayPlusFifteenDays = Date.today().addDays(15).month() + '/' + Date.today().addDays(15).day() + '/' + Date.today().addDays(15).year();
        
        promiseConfirmation = 'Confirm';
        rulesResults = TFSC_InteractionEntryPanelController.checkPromiseToPayRules(dateTodayPlusFourteenDays, ivrMethod.Name, wuspMethod.Name, dateTodayPlusSevenDays, promiseConfirmation, '2');
        //System.assertEquals(rulesResults.get(TFSC_Constants.PTP_DATES_MAP_KEY_SECOND), true);
        System.assertEquals(rulesResults.get(TFSC_Constants.PTP_WUSP_CONFIRMATION_REQUIRED_MAP_KEY_SECOND), true);
        
        rulesResults = TFSC_InteractionEntryPanelController.checkPromiseToPayRules(dateTodayPlusFifteenDays, ivrMethod.Name, wuspMethod.Name, dateTodayPlusSevenDays, promiseConfirmation, '2');
//        System.assertEquals(rulesResults.get(TFSC_Constants.PTP_DATES_MAP_KEY_SECOND), false);
        String tmpStrAssert = TFSC_Constants.PTP_DATES_MAP_KEY_SECOND;
    }
    
   /**
    * @author Stevie Ella
    * @date 07/03/2014
    * @description: 
    * @return void

    */
    static testmethod void checkRPCCodeRulesTest(){
         Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                Flag_RPC__c = false,
                Flag_Quick__c = true,
                Flag_Skip__c = false,
                Flag_Promise_Required__c = false,
                Flag_Notes_Required__c = false
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false,
                Flag_Promise_Required__c = true,
                Flag_Notes_Required__c = true
        );
        insert new List<Activity_Code__c>{quickCode, rpcCode};
        
        Payment_Method__c ivrMethod = new Payment_Method__c(
                Name = 'IVR',
                Promise_Days__c = 7,
                Value__c = 'IVR',
                Sort_Order__c = 1
        );
        insert ivrMethod;
        
        String promiseToPayDateToday = '';
        String promiseToPayMethod = '';
        String promiseToPayAmount = '';
        String activityCode = rpcCode.Name;
        String activityNote = '';
        String tabName = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        
        Map<String, Boolean> rulesResults;
        
        Test.startTest();
        rulesResults = TFSC_InteractionEntryPanelController.checkRPCCodeRules(promiseToPayDateToday, promiseToPayMethod, promiseToPayAmount, activityCode, activityNote, tabName);
        Test.stopTest();
        
        System.assertEquals(rulesResults.get(TFSC_Constants.RPC_CODE_PTP_REQUIRED), false);
        System.assertEquals(rulesResults.get(TFSC_Constants.RPC_CODE_NOTE_REQUIRED), false);
        
        promiseToPayDateToday = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        promiseToPayMethod = ivrMethod.Name;
        promiseToPayAmount = '300';
        activityNote = 'RPC NOTE';
        
        rulesResults = TFSC_InteractionEntryPanelController.checkRPCCodeRules(promiseToPayDateToday, promiseToPayMethod, promiseToPayAmount, activityCode, activityNote, tabName);
        System.assertEquals(rulesResults.get(TFSC_Constants.RPC_CODE_PTP_REQUIRED), true);
        System.assertEquals(rulesResults.get(TFSC_Constants.RPC_CODE_NOTE_REQUIRED), true);
        
        rulesResults = TFSC_InteractionEntryPanelController.checkRPCCodeRules(promiseToPayDateToday, promiseToPayMethod, promiseToPayAmount, quickCode.Name, '', TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB);
        System.assertEquals(rulesResults.get(TFSC_Constants.QUICK_CODE_NOTE_REQUIRED), true);
        
    }
    
   /**
    * @author Stevie Ella
    * @date 07/03/2014
    * @description: 
    * @return void

    */
    static testmethod void getInOrderValidActivityCodeObjectFromActivityNameTest(){
        
         Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                Flag_RPC__c = false,
                Flag_Quick__c = true,
                Flag_Skip__c = false,
                CTI_Reason__c = 'QUICK_REASON',
                CTI_Result__c = 'QUICK_RESULT',
                CTI_Activity__c = true,
                Sort_Order_Quick__c = 1
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false,
                CTI_Reason__c = 'RPC_REASON',
                CTI_Result__c = 'RPC_RESULT',
                CTI_Activity__c = true,
                Sort_Order_RPC__c = 1
        );
        Activity_Code__c skipCode = new Activity_Code__c(
                Name = 'DEV_SKIP',
                Description__c = 'SKIP',
                Flag_RPC__c = false,
                Flag_Quick__c = false,
                Flag_Skip__c = true,
                CTI_Reason__c = 'SKIP_REASON',
                CTI_Result__c = 'SKIP_RESULT',
                CTI_Activity__c = true,
                Sort_Order_Skip__c = 1
        );
        insert new List<Activity_Code__c>{quickCode, rpcCode, skipCode};
        
        Activity_Code__c actCodeToReturn;
        
        Test.startTest();
            actCodeToReturn = TFSC_InteractionEntryPanelController.getInOrderValidActivityCodeObjectFromActivityName(rpcCode.Name, quickCode.Name, skipCode.Name);
        Test.stopTest();
        
        System.assertEquals(actCodeToReturn.Name, 'DEV_RPC');
        
        rpcCode.CTI_Activity__c = false;
        upsert rpcCode;
        
        actCodeToReturn = TFSC_InteractionEntryPanelController.getInOrderValidActivityCodeObjectFromActivityName(rpcCode.Name, quickCode.Name, skipCode.Name);
        System.assertEquals(actCodeToReturn.Name, 'DEV_QUICK');
        
        actCodeToReturn = TFSC_InteractionEntryPanelController.getInOrderValidActivityCodeObjectFromActivityName(rpcCode.Name, '', skipCode.Name);
        System.assertEquals(actCodeToReturn.Name, 'DEV_SKIP');
        
    }
    
    
   /**
    * @author Stevie Ella
    * @date 07/03/2014
    * @description: 
    * @return void

    */
    static testmethod void tfsc_InteractionEntryPanelControllerTest(){
        
        // Create activity codes
        List<Activity_Code__c> listActivityCodes = new List<Activity_Code__c>();
        Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                Flag_RPC__c = false,
                Flag_Quick__c = true,
                Flag_Skip__c = false,
                CTI_Reason__c = 'QUICK_REASON',
                CTI_Result__c = 'QUICK_RESULT',
                CTI_Activity__c = true,
                Sort_Order_Quick__c = 1
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Talked_To__c = 'CS',
                Phone_Type__c = 'Home',
                Description__c = 'RPC',
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false,
                CTI_Reason__c = 'RPC_REASON',
                CTI_Result__c = 'RPC_RESULT',
                CTI_Activity__c = true,
                Sort_Order_RPC__c = 1
        );
        
        listActivityCodes.add(quickCode);
        listActivityCodes.add(rpcCode);
        insert listActivityCodes;
        
        // Create payment methods
        List<Payment_Method__c> listPaymentMethods = new List<Payment_Method__c>();
        Payment_Method__c ivrMethod = new Payment_Method__c(
                Name = 'IVR',
                Promise_Days__c = 7,
                Value__c = 'IVR',
                Sort_Order__c = 1
        );
        
        Payment_Method__c wuspMethod = new Payment_Method__c(
                Name = 'WUSP',
                Promise_Days__c = 14,
                Value__c = 'WUSP',
                Sort_Order__c = 2
        );
        
        listPaymentMethods.add(ivrMethod);
        listPaymentMethods.add(wuspMethod);
        insert listPaymentMethods;
        
        // Create VAPs
        List<VAP_Options__c> listVAPOptions = new List<VAP_Options__c>();
        VAP_Options__c vapYes = new VAP_Options__c(
                Name = 'VAP:YES',
                Value__c = 'VAP:YES'
        );
        
        VAP_Options__c vapAuthenticated = new VAP_Options__c(
                Name = 'VAP:AUTHENTICATED',
                Value__c = 'VAP:AUTHENTICATED'
        );
        
        listVAPOptions.add(vapYes);
        listVAPOptions.add(vapAuthenticated);
        insert listVAPOptions;
        
        
        // Create reason for delinquency
        list<Reason_For_Delinquency__c> listReasonForDelinquency = new List<Reason_For_Delinquency__c>();
        Reason_For_Delinquency__c joblessReason = new Reason_For_Delinquency__c(
                Name = 'JOBLESS',
            	Sort_Order__c = 1
        );
        Reason_For_Delinquency__c divorceReason = new Reason_For_Delinquency__c(
                Name = 'DIVORCE',
            	Sort_Order__c = 2
        );
        listReasonForDelinquency.add(joblessReason);
        listReasonForDelinquency.add(divorceReason);
        insert listReasonForDelinquency;
        
                
        // Create Callee Relationship
        list<Callee_Relationship__c> listCalleeRelationships = new list<Callee_Relationship__c>();
        Callee_Relationship__c csRelation = new Callee_Relationship__c(
            Name = 'CS',
            Borrower_Position__c = 'Primary'
        );
        Callee_Relationship__c cxRelation = new Callee_Relationship__c(
            Name = 'CX',
            Borrower_Position__c = 'Co-Borrower'
        );
        
        listCalleeRelationships.add(csRelation);
        listCalleeRelationships.add(cxRelation);
        insert listCalleeRelationships;
        
        // Create Dialer Campaign
        list<Dialer_Campaign__c> listOfDialerCampaign = new list<Dialer_Campaign__c>();
        Dialer_Campaign__c testCampaign = new Dialer_Campaign__c(
                Name = 'TEST_CAMPAIGN',
                Type__c = 'MANAGED'
        );
        insert testCampaign;
        
        // Create account
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(name = 'Primary'));
        listAccounts.add(new Account(name = 'CoBorrower'));
        
        insert listAccounts;
        
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
        
        List<Financial_Account_Customer__c> listFACustomers = new List<Financial_Account_Customer__c>();
        Financial_Account_Customer__c financialAccountCustomer_1 = new Financial_Account_Customer__c(
            HomePhone_BillTo__c = '4063775033',
            Work_Phone_Bill_To__c = '4063775044',
            Mobile_Phone__c = '4063775055',
            Mailing_Street_Garage__c = 'Garage Hyde St',
            Mailing_City_Garage__c = 'San Stevio',
            Mailing_State_Garage__c = 'CA',
            Mailing_Country_Code_Garage__c = 'US',
            Mailing_Postal_Code_Garage__c = '123',
            Mailing_Street_BillTo__c = 'BillTo Me St',
            Mailing_City_BillTo__c = 'San Ellito',
            Mailing_State_BillTo__c = 'IL',
            Mailing_CountryCode_BillTo__c = 'US',
            Mailing_PostalCode_BillTo__c = '456',
            Financial_Account__c = financialAccount.Id,
            Account__c = listAccounts.get(0).Id,
            Borrower_Position__c = 'Primary',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test' + TFSC_TestUtils.generateRandomString(4)
        );
        
        listFACustomers.add(financialAccountCustomer_1);
        insert listFACustomers;
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        
        Test.startTest();
        // Create the Interaction Entry panel Controller 
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        interactionEntryPanelController.lastDialedPhoneNumber = '';
        Test.stopTest();
        
        // Assert the financial Id was properly set
        System.assertEquals(interactionEntryPanelController.financialAccountId, financialAccount.Id);
        
        // Assert the financial customer was properly set
        System.assertEquals(interactionEntryPanelController.financialAccountCustomer.Id, financialAccountCustomer_1.Id);
        
        // Assert methods of payment are set
        System.assertEquals(interactionEntryPanelController.getMethodsOfPayment().size(), 3);
        
        // Assert VAP are set
        System.assertEquals(interactionEntryPanelController.getListOfVPAs().size(), 3);
        
        // Assert Callee Relationships are set
        System.assertEquals(interactionEntryPanelController.getListOfCalleeRelationships().size(), 2);
        
        // Assert Reason For Delinquency are set
        System.assertEquals(interactionEntryPanelController.getListOfRFDs().size(), 3);
        
        // Assert Quick and RPC and Skip Code are set
        System.assertEquals(interactionEntryPanelController.getQuickCodeItems().size(), 2);
        System.assertEquals(interactionEntryPanelController.getRPCCodeItems().size(), 2);
        System.assertEquals(interactionEntryPanelController.getSkipCodeItems().size(), 1);
        
        // Assert getTypeOfDialedPhoneNumber return proper values
        System.assertEquals(interactionEntryPanelController.getTypeOfDialedPhoneNumber('4063775033', financialAccountCustomer_1, true), TFSC_Constants.PHONE_TYPE_HOME);
        //System.assertEquals(interactionEntryPanelController.financialAccountCustomer.Work_Phone_Bill_To__c, '(222)222-2222');
        System.assertEquals(interactionEntryPanelController.getTypeOfDialedPhoneNumber('4063775044', financialAccountCustomer_1, true), TFSC_Constants.PHONE_TYPE_WORK);
        System.assertEquals(interactionEntryPanelController.getTypeOfDialedPhoneNumber('4063775055', financialAccountCustomer_1, true), TFSC_Constants.PHONE_TYPE_MOBILE);
    
    }
    
       /**
    * @author Stevie Ella
    * @date 07/03/2014
    * @description: 
    * @return void

    */
    static testmethod void isValidFinancialIDTest(){
        
        Test.startTest();
        // Create the Interaction Entry panel Controller 
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        Test.stopTest();
        
        System.assertEquals(interactionEntryPanelController.isValidFinancialID(), false);
            
    }
    
   /**
    * @author Stevie Ella
    * @date 07/03/2014
    * @description: 
    * @return void

    */
    static testmethod void isPTPDataValidTest(){
        System.assertEquals(TFSC_InteractionEntryPanelController.isPTPDataValid('', '', ''), true);
        System.assertEquals(TFSC_InteractionEntryPanelController.isPTPDataValid('12/12/2012', 'EPAY', '4600'), true);
        System.assertEquals(TFSC_InteractionEntryPanelController.isPTPDataValid('12/12/2012', 'None', '4600'), false);
        System.assertEquals(TFSC_InteractionEntryPanelController.isPTPDataValid('', '', '4600'), false);
    }
    
      /**
    * @author Stevie Ella
    * @date 07/07/2014
    * @return void
    */
    static testmethod void saveAllActivitiesTest() {
        
        // 1) Set non-null values to the InteractionPanelWrapper for quick code and note, rpc code and note, skip code and note.
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345'
        );
        insert financialAccount;
        
        insert new Payment_Method__c(Name = 'IVR', Value__c = 'IVR', Promise_Days__c = 7, Sort_Order__c = 1);
        
        List<Activity_Code__c> listOfCodes = new List<Activity_Code__c>();
        Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false,
                Sort_Order_Quick__c = 1
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false,
                Sort_Order_RPC__c = 1
        );
        Activity_Code__c skipCode = new Activity_Code__c(
                Name = 'DEV_SKIP',
                Description__c = 'SKIP',
                Flag_Skip__c = true,
                Flag_RPC__c = false,
                Flag_Quick__c = false,
                Sort_Order_Skip__c = 1
        );

        listOfCodes.add(quickCode);
        listOfCodes.add(rpcCode);
        listOfCodes.add(skipCode);
        insert listOfCodes;
        
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController interactionEntryPanelController = new TFSC_InteractionEntryPanelController();
        
        TFSC_InteractionEntryPanelController.InteractionPanelWrapper entryPanelWrapper = new TFSC_InteractionEntryPanelController.InteractionPanelWrapper();
        entryPanelWrapper.quickCode = String.valueOf(quickCode.Name);
        entryPanelWrapper.quickNote = 'DEV_QUICK_NOTE';
        entryPanelWrapper.rpcCode = String.valueOf(rpcCode.Name);
        entryPanelWrapper.rpcNote = 'DEV_RPC_NOTE';
        entryPanelWrapper.skipCode = String.valueOf(skipCode.Name);
        entryPanelWrapper.skipNote = 'DEV_SKIP_NOTE';
        
        entryPanelWrapper.firstAmountPTP = '10';
        entryPanelWrapper.firstConfirmationPTP = 'PROMISE_CONFIRMATION';
        entryPanelWrapper.firstMethodOfPayment = 'IVR';
        entryPanelWrapper.firstPromiseDate = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        entryPanelWrapper.secondPromiseDate = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
        
        interactionEntryPanelController.interactionPanelWrapper = entryPanelWrapper;
        interactionEntryPanelController.currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        interactionEntryPanelController.financialAccount = financialAccount;

        // 2) Launch saveActivities
        Test.startTest();
        boolean exceptionThrown;
            try {
                
                interactionEntryPanelController.saveAllActivities();
            
            } catch( exception e ) {
                
                exceptionThrown = true;
            }
        
       Test.stopTest();
        
        // 3) Check that 3 activities are created
        List<Task> listOfCreatedTasks = new List<Task>(
                [
                        SELECT
                                Id,
                                Description,
                                Collection_Activity_Code__c,
                                Financial_Account__c,
                                Financial_Account_Number__c
                        FROM
                                Task
                        ORDER BY
                                Collection_Activity_Code__c
                ]
        );
        
        System.assertEquals(listOfCreatedTasks.size(), 3);
        
        System.assertEquals(listOfCreatedTasks.get(0).Collection_Activity_Code__c, 'DEV_QUICK');
        System.assertEquals(listOfCreatedTasks.get(0).Description, 'DEV_QUICK_NOTE');

        System.assertEquals(listOfCreatedTasks.get(1).Collection_Activity_Code__c, 'DEV_RPC');
        System.assertEquals(listOfCreatedTasks.get(1).Description, 'DEV_RPC_NOTE');
        
        System.assertEquals(listOfCreatedTasks.get(2).Collection_Activity_Code__c, 'DEV_SKIP');
        System.assertEquals(listOfCreatedTasks.get(2).Description, 'DEV_SKIP_NOTE');
        
    }
    
   /**
    * @author Stevie Ella
    * @date 07/07/2014
    * @return void
    */
    static testmethod void updateCaseAndTaskWithSkipTraceEditsTest(){
        
        // Create financial account
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
        
        // Create Collections_Pass_Strategy__c
        List<Collections_Pass_Strategy__c> listPassStrategies = new List<Collections_Pass_Strategy__c>();
        Collections_Pass_Strategy__c passStrategy_1 = new Collections_Pass_Strategy__c(
            Name = 'PASS1-MANL',
            Sort__c = 1,
            Article_Number__c = '000001008',
            Standard_Note__c = 'TESTNOTE1',
            RES__C = 'RES1',
            Account_Type__c = 'General'
        );
        Collections_Pass_Strategy__c passStrategy_2 = new Collections_Pass_Strategy__c(
            Name = 'PASS2-MANL',
            Sort__c = 2,
            Article_Number__c = '000001009',
            Standard_Note__c = 'TESTNOTE2',
            RES__C = 'RES2',
            Account_Type__c = 'General'
        );
        listPassStrategies.add(passStrategy_1);
        listPassStrategies.add(passStrategy_2);
        insert listPassStrategies;
        
        // Create case
        Case caseTest = new Case(
            status = 'New',
            RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Collection').getRecordTypeId(),
            Financial_Account__c = financialAccount.Id
        );
        insert caseTest;
        
        System.assertEquals(TFSC_InteractionEntryPanelController.updateCaseAndTaskWithSkipTraceEdits(financialAccount.Id, 'TEST', 'General', string.valueOf(0)), null);
        Test.startTest();
        TFSC_InteractionEntryPanelController.updateCaseAndTaskWithSkipTraceEdits(financialAccount.Id, 'Escalated', 'General', string.valueOf(0));
        Test.stopTest();
        
        caseTest = [SELECT 
                            Id,
                            status
                    FROM
                            Case
                    WHERE
                            Id = :caseTest.Id
                    LIMIT
                            1
                    ];
        System.assertEquals(TFSC_InteractionEntryPanelController.updateCaseAndTaskWithSkipTraceEdits(caseTest.status, 'Escalated', 'General', string.valueOf(0)), null);
    }

    /**
    * @author Stevie Ella
    * @date 07/07/2014
    * @return void
    */
    static testmethod void getCampaignTypeFromNameTest(){
        
        // Create Dialer Campaign
        list<Dialer_Campaign__c> listOfDialerCampaign = new list<Dialer_Campaign__c>();
        Dialer_Campaign__c testCampaign_1 = new Dialer_Campaign__c(
                Name = 'TEST_CAMPAIGN_1',
                Type__c = 'MANAGED'
        );
        Dialer_Campaign__c testCampaign_2 = new Dialer_Campaign__c(
                Name = 'TEST_CAMPAIGN_2',
                Type__c = 'UNMANAGED'
        );
        listOfDialerCampaign.add(testCampaign_1);
        listOfDialerCampaign.add(testCampaign_2);
        insert listOfDialerCampaign;
        
        System.assertEquals(TFSC_InteractionEntryPanelController.getCampaignTypeFromName('TEST_CAMPAIGN_1'), 'MANAGED');
        System.assertEquals(TFSC_InteractionEntryPanelController.getCampaignTypeFromName('TEST_CAMPAIGN_2'), 'UNMANAGED');
        System.assertEquals(TFSC_InteractionEntryPanelController.getCampaignTypeFromName('TEST_CAMPAIGN'), '');
        
    }
    
    /**
    * @author Stevie Ella
    * @date 07/07/2014
    * @return void
    */
    static testmethod void getActivityCodeObjectFromActivityNameTest(){
        
        List<Activity_Code__c> listOfCodes = new List<Activity_Code__c>();
        Activity_Code__c quickCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                CTI_Activity__c = true,
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false,
                Sort_Order_Quick__c = 1
        );
        Activity_Code__c rpcCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                CTI_Activity__c = true,
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false,
                Sort_Order_RPC__c = 1
        );
        Activity_Code__c skipCode = new Activity_Code__c(
                Name = 'DEV_SKIP',
                Description__c = 'SKIP',
                CTI_Activity__c = false,
                Flag_Skip__c = true,
                Flag_RPC__c = false,
                Flag_Quick__c = false,
                Sort_Order_Skip__c = 1
        );

        listOfCodes.add(quickCode);
        listOfCodes.add(rpcCode);
        listOfCodes.add(skipCode);
        insert listOfCodes;
        
        System.assertEquals(TFSC_InteractionEntryPanelController.getActivityCodeObjectFromActivityName('DEV_RPC').Id, rpcCode.Id);
        System.assertEquals(TFSC_InteractionEntryPanelController.getActivityCodeObjectFromActivityName('DEV_QUICK').Id, quickCode.Id);
        System.assertEquals(TFSC_InteractionEntryPanelController.getActivityCodeObjectFromActivityName('DEV_SKIP'), null);
        System.assertEquals(TFSC_InteractionEntryPanelController.getActivityCodeObjectFromActivityName('DEV_RANDOM'), null);
        
    }
        
    /**
    * @author Stevie Ella
    * @date 07/07/2014
    * @return void
    */
    static testmethod void validatePromiseDataTest(){
        
        // Create payment methods
        List<Payment_Method__c> listPaymentMethods = new List<Payment_Method__c>();
        Payment_Method__c ivrMethod = new Payment_Method__c(
                Name = 'IVR',
                Promise_Days__c = 7,
                Value__c = 'IVR',
                Sort_Order__c = 1
        );
        
        Payment_Method__c wuspMethod = new Payment_Method__c(
                Name = 'WUSP',
                Promise_Days__c = 14,
                Value__c = 'WUSP',
                Sort_Order__c = 2
        );
        
        listPaymentMethods.add(ivrMethod);
        listPaymentMethods.add(wuspMethod);
        insert listPaymentMethods;
        
                List<Activity_Code__c> listOfCodes = new List<Activity_Code__c>();
        Activity_Code__c quickActCode = new Activity_Code__c(
                Name = 'DEV_QUICK',
                Description__c = 'QUICK',
                CTI_Activity__c = true,
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false
        );
        Activity_Code__c rpcActCode = new Activity_Code__c(
                Name = 'DEV_RPC',
                Description__c = 'RPC',
                CTI_Activity__c = true,
                Flag_RPC__c = true,
                Flag_Quick__c = false,
                Flag_Skip__c = false
        );
        Activity_Code__c skipActCode = new Activity_Code__c(
                Name = 'DEV_SKIP',
                Description__c = 'SKIP',
                CTI_Activity__c = false,
                Flag_Skip__c = true,
                Flag_RPC__c = false,
                Flag_Quick__c = false
        );

        listOfCodes.add(quickActCode);
        listOfCodes.add(rpcActCode);
        listOfCodes.add(skipActCode);
        insert listOfCodes;
        
            String promiseToPayDate_1 = Date.today().month() + '/' + Date.today().day() + '/' + Date.today().year();
            String promiseToPayMethod_1 = 'IVR';
            String promiseToPayAmount_1 = '400';
            String promiseToPayConfirmation_1 = '';
            String promiseToPayDate_2 = Date.today().addDays(14).month() + '/' + Date.today().addDays(14).day() + '/' + Date.today().addDays(14).year();
            String promiseToPayMethod_2 = 'WUSP';
            String promiseToPayAmount_2 = '';
            String promiseToPayConfirmation_2 = '';
            String quickCode = 'DEV_QUICK';
            String quickNote = '';
            String rpcCode = 'DEV_RPC';
            String rpcNote = '';
            String skipCode = 'DEV_SKIP';
            String skipNote = '';
            String tabName = '';
    
        Test.startTest();
            Map<String, Boolean> mapResults = TFSC_InteractionEntryPanelController.validatePromiseData(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1, promiseToPayConfirmation_1, promiseToPayDate_2, promiseToPayMethod_2, promiseToPayAmount_2, promiseToPayConfirmation_2, quickCode, quickNote, rpcCode, rpcNote, skipCode, skipNote, tabName);
        Test.stopTest();
        
        System.assertEquals(mapResults.get(TFSC_Constants.COMPLETE_DATA_MAP_KEY_FIRST), true);
        System.assertEquals(mapResults.get(TFSC_Constants.COMPLETE_DATA_MAP_KEY_SECOND), false);
        
        tabName = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        promiseToPayAmount_2 = '200';
        mapResults = TFSC_InteractionEntryPanelController.validatePromiseData(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1, promiseToPayConfirmation_1, promiseToPayDate_2, promiseToPayMethod_2, promiseToPayAmount_2, promiseToPayConfirmation_2, quickCode, quickNote, rpcCode, rpcNote, skipCode, skipNote, tabName);
        
        System.assertEquals(mapResults.get(TFSC_Constants.COMPLETE_DATA_MAP_KEY_FIRST), true);
        System.assertEquals(mapResults.get(TFSC_Constants.COMPLETE_DATA_MAP_KEY_SECOND), true);     
    }
    
            
    /**
    * @author Stevie Ella
    * @date 07/07/2014
    * @return void
    */
    static testmethod void InteractionPanelWrapperGetCleanFirstANDSecondAmountsTest(){
        
        TFSC_InteractionEntryPanelController testInteractionEntryPanel = new TFSC_InteractionEntryPanelController();
        TFSC_InteractionEntryPanelController.InteractionPanelWrapper interactionPanelWrapper = new TFSC_InteractionEntryPanelController.InteractionPanelWrapper();
        interactionPanelWrapper.firstAmountPTP = 'TEXT';
        interactionPanelWrapper.firstAmountPTP = '';
        
        System.assertEquals(interactionPanelWrapper.getCleanFirstAmount(), 0);
        System.assertEquals(interactionPanelWrapper.getCleanSecondAmount(), 0);
        
        interactionPanelWrapper.firstAmountPTP = '10';
        interactionPanelWrapper.secondAmountPTP = '400';
        
        System.assertEquals(interactionPanelWrapper.getCleanFirstAmount(), 10);
        System.assertEquals(interactionPanelWrapper.getCleanSecondAmount(), 400);   
    }
    /**
    * @author Paras Dhingra
    * @date 06/01/2015
    * @return void
    * @description Test the saveRFDValues
    */
    static testmethod void testSaveRFDValues(){
        // Create account
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(name = 'Primary'));
        listAccounts.add(new Account(name = 'CoBorrower'));
        
        insert listAccounts;
        
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
        
        List<Financial_Account_Customer__c> listFACustomers = new List<Financial_Account_Customer__c>();
        Financial_Account_Customer__c financialAccountCustomer_1 = new Financial_Account_Customer__c(
            HomePhone_BillTo__c = '4063775033',
            Work_Phone_Bill_To__c = '4063775044',
            Mobile_Phone__c = '4063775055',
            Mailing_Street_Garage__c = 'Garage Hyde St',
            Mailing_City_Garage__c = 'San Stevio',
            Mailing_State_Garage__c = 'CA',
            Mailing_Country_Code_Garage__c = 'US',
            Mailing_Postal_Code_Garage__c = '123',
            Mailing_Street_BillTo__c = 'BillTo Me St',
            Mailing_City_BillTo__c = 'San Ellito',
            Mailing_State_BillTo__c = 'IL',
            Mailing_CountryCode_BillTo__c = 'US',
            Mailing_PostalCode_BillTo__c = '456',
            Financial_Account__c = financialAccount.Id,
            Account__c = listAccounts.get(0).Id,
            Borrower_Position__c = 'Primary',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test' + TFSC_TestUtils.generateRandomString(4)
        );
        
        listFACustomers.add(financialAccountCustomer_1);
        insert listFACustomers;
        Financial_Account_Customer__c facToReturn = [select id, Financial_Account__c, Borrower_Position__c, Account__c, 
                                    Account__r.Name, Account__r.IsPersonAccount, Account__r.Tax_Identification_Number__c, 
                                    Account__r.Social_Security_Number__pc, Account__r.RecordType.Name, 
                                    Financial_Account__r.RecordType.Name,
                                    Account__r.AKA__c,
                                    Flag_Work_Phone_IsMobile_Garage__c,
                                    Flag_Home_Phone_IsMobile_BillTo__c, Flag_Work_Phone_Is_Mobile_BillTo__c,
                                    Flag_Home_Phone_IsMobile_Garage__c,
                                    Election_Language_Preference__c, HomePhone_BillTo__c,
                                    Home_Phone_Garage__c, Home_Phone_No_Call_Reason_Code_Garage__c,
                                    Home_Phone_No_Call_Reason_Code_BillTo__c, Mobile_Phone__c,
                                    Mobile_Phone_No_Call_Reason_Code__c, Work_Phone_Bill_To__c,
                                    Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                                    Work_Phone_No_Call_Reason_Code_Bill_To__c, Mailing_Street_BillTo__c, Mailing_City_BillTo__c,
                                    Mailing_State_BillTo__c, Mailing_CountryCode_BillTo__c, Mailing_PostalCode_BillTo__c, Mailing_Street_Garage__c, Mailing_City_Garage__c,
                                    Mailing_State_Garage__c, Mailing_Country_Code_Garage__c, Mailing_Postal_Code_Garage__c
                                   from Financial_Account_Customer__c
                                   where Borrower_Position__c = 'Primary'
                                   and Financial_Account__c = :financialAccount.Id
                                   and (not Financial_Account_Customer__c like '%Inactive%')  
                                   limit 1]; 
        System.debug('**Account Name**'+ facToReturn.Account__c );
        System.debug('**Account Name**'+ facToReturn.Account__r.name );
        /*
        // Create financial account
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
        */
         // Create case
        Case caseTest = new Case(
            status = 'New',
            RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Collection').getRecordTypeId(),
            Financial_Account__c = financialAccount.Id,RFD_PickList__C = 'MEDICAL', RFD_Text__c = 'test  value' 
        );

        insert caseTest;
        PageReference pageRef = Page.TFSC_InteractionEntryPanel;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', financialAccount.Id);
        TFSC_InteractionEntryPanelController testInteractionEntryPanel = new TFSC_InteractionEntryPanelController();
        //Modified Assert statements for Issue I-168409> Paras Dhingra 6/16/2015 #start        
        System.assertEquals('MEDICAL',testInteractionEntryPanel.interactionPanelWrapper.reasonOfDelinquency);
        System.assertEquals('test  value',testInteractionEntryPanel.interactionPanelWrapper.reasonOfDelinquencyNote);
        //Issue I-168409> Paras Dhingra 6/16/2015 #End
        testInteractionEntryPanel.interactionPanelWrapper.reasonOfDelinquency = 'DIVORCE';
        testInteractionEntryPanel.interactionPanelWrapper.reasonOfDelinquencyNote = 'no comments';
        testInteractionEntryPanel.saveRFDValues();
        case testCase = [select id, RFD_Text__c, RFD_PickList__C from case where Financial_Account__c =: financialAccount.id and isClosed = false limit 1][0];
        System.assertEquals('DIVORCE',testCase.RFD_PickList__C);
        System.assertEquals('no comments',testCase.RFD_Text__c);

    }

}