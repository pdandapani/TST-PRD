@isTest
private class TFSC_SkipTraceControllerTest {
    
   static testmethod void testFaWithPopulatedSkipTrace() {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Account acct = new Account(name = 'test' + randomString);
        insert acct;
        
        Financial_Account__c financialAccount = setupData(acct);
        
        Financial_Account_Customer__c fac = generateAndInsertFAC(financialAccount.Id, 'Primary', 'Open', acct.Id);
        Financial_Account_Customer__c coFac = generateAndInsertFAC(financialAccount.Id, 'Co-X', 'Open', acct.Id);
        
        Skip_Trace__c skipTrace = new Skip_Trace__c(Financial_Account__c = financialAccount.Id);
        skipTrace.Address1__c = '1234 addy ST';
        skipTrace.Phone1__c = '4064434043';
        insert skipTrace;
        
        Id collectionCaseId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Collection', 'Case');
        Case newCase = new Case(Financial_Account__c = financialAccount.Id, RecordTypeId = collectionCaseId, status='PASS1x');
        insert newCase;
        
        CollectionsPassStrategy__kav helpTextObj = new CollectionsPassStrategy__kav(UrlName = '123', Title = 'test123', Details__c = 'test123', Language = 'en_US');
        insert helpTextObj;
        String articleNum = [select ArticleNumber, id from CollectionsPassStrategy__kav where id = :helpTextObj.Id].ArticleNumber ;
        
        PageReference pageRef = Page.TFSC_SkipTrace;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', financialAccount.Id);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(financialAccount);
        TFSC_SkipTraceController controllerExt = new TFSC_SkipTraceController(standardController);
        controllerExt.selectedPassStrategy = articleNum;
        controllerExt.populatePhonesAndAddresses();
        
        TFSC_SkipTraceController.generateArticleText( articleNum );
        
        testAddingRemovingPhoneNumber(controllerExt);
        testTimeStampUpdate(controllerExt);
    }
    
    
    static void testTimeStampUpdate(TFSC_SkipTraceController controller) {
        
        String newPhone = '7014457667';
        
        //insert phone
        TFSC_SkipTraceController.PhoneNumberObject tmpPhoneObj = new TFSC_SkipTraceController.PhoneNumberObject(newPhone, 'G - Good Number (C,A)', 'Mobile', 'Innovis', Date.today());
        TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest request = new TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest(tmpPhoneObj);
        request.randomId = '';
        String tempJsonRequest = JSON.serialize(request);
        controller.saveJsonRequest = tempJsonRequest;
        controller.savePhoneLineItem();
        
        TFSC_SkipTraceController.LastCalledTimestampRequestAndResponse request2 = new TFSC_SkipTraceController.LastCalledTimestampRequestAndResponse(tmpPhoneObj);
        request2.randomId = '';
        tempJsonRequest = JSON.serialize(request);
        controller.saveJsonRequest = tempJsonRequest;
        controller.updateTimestamp();
    	
    }
    
    
    
    static testmethod void testSkipTraceController() {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        Toyota_Vendor_Phone_Number__c vendorCS = new Toyota_Vendor_Phone_Number__c(Name = '7015741984');
        insert vendorCS;
        
        Account acct = new Account(name = 'test' + randomString);
        insert acct;
        
        Financial_Account__c financialAccount = setupData(acct);
        
        Financial_Account_Customer__c fac = generateAndInsertFAC(financialAccount.Id, 'Primary', 'Open', acct.Id);
        Financial_Account_Customer__c coFac = generateAndInsertFAC(financialAccount.Id, 'Co-X', 'Open', acct.Id);
        
        Id collectionCaseId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Collection', 'Case');
        Case newCase = new Case(Financial_Account__c = financialAccount.Id, RecordTypeId = collectionCaseId, status='PASS1x');
        insert newCase;
        
        CollectionsPassStrategy__kav helpTextObj = new CollectionsPassStrategy__kav(UrlName = '123', Title = 'test123', Details__c = 'test123', Language = 'en_US');
        insert helpTextObj;
        String articleNum = [select ArticleNumber, id from CollectionsPassStrategy__kav where id = :helpTextObj.Id].ArticleNumber ;
        Collections_Pass_Strategy__c passStrat = [Select Article_Number__c from Collections_Pass_Strategy__c limit 1];
        passStrat.Article_Number__c = articleNum;
        update passStrat;
        PageReference pageRef = Page.TFSC_SkipTrace;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', financialAccount.Id);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(financialAccount);
        TFSC_SkipTraceController controllerExt = new TFSC_SkipTraceController(standardController);
        controllerExt.selectedPassStrategy = articleNum;
        controllerExt.initializeNewSkipTraceRecordAndPopulateData();
        controllerExt.populatePhonesAndAddresses();
        
        testAndValidateCheckboxes(controllerExt);
        testAddingRemovingAddress(controllerExt);
        testAddingRemovingPhoneNumber(controllerExt);
        testUpdatingAltBorrower(controllerExt);
        
    }
    
    private static void testUpdatingAltBorrower(TFSC_SkipTraceController controllerExt) {
        controllerExt.borrowerPhoneFromJS = '4064434044';
        controllerExt.updateAltBorrower();
        
        //validate that phone num is 'top fac';
    }
    
    
    private static String EXISTING_PHONE = '4064434011';
    
    private static void testAddingRemovingPhoneNumber(TFSC_SkipTraceController controllerExt) {
        
        //use existing phone to hit 'disable skip phone' code.
        TFSC_SkipTraceController.PhoneNumberObject tmpPhoneObj = new TFSC_SkipTraceController.PhoneNumberObject(EXISTING_PHONE, 'G - Good Number (C,A)', 'Mobile', 'Innovis', Date.today());
        TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest request = new TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest(tmpPhoneObj);
        request.randomId = '';
        String tempJsonRequest = JSON.serialize(request);
        controllerExt.saveJsonRequest = tempJsonRequest;
        controllerExt.savePhoneLineItem();
        
        tmpPhoneObj = controllerExt.phoneNumList[0];
        request = new TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest(tmpPhoneObj);
        controllerExt.saveJsonRequest = JSON.serialize(request);
        controllerExt.savePhoneLineItem(); //for update
        controllerExt.saveJsonRequest = 'ahrdsfas';
        controllerExt.savePhoneLineItem(); //for save with error
        
        tmpPhoneObj = controllerExt.phoneNumList[0];
        request = new TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest(tmpPhoneObj);
        controllerExt.saveJsonRequest = JSON.serialize(request);
        controllerExt.deletePhoneLineItem(); //for delete
        controllerExt.saveJsonRequest = JSON.serialize('asdvabnaiena');
        controllerExt.deletePhoneLineItem(); //for delete with error
        
        //test vendor phone number update-and-alert
        tmpPhoneObj = new TFSC_SkipTraceController.PhoneNumberObject('7015741984', 'G - Good Number (C,A)', 'Mobile', 'Innovis', Date.today());
        request = new TFSC_SkipTraceController.PhoneNumberSaveResponseAndRequest(tmpPhoneObj);
        request.randomId = '';
        controllerExt.saveJsonRequest = JSON.serialize(request);
        controllerExt.savePhoneLineItem();
    }
    
    
    private static void testAddingRemovingAddress(TFSC_SkipTraceController controllerExt) {
        TFSC_SkipTraceController.AddressHistory addyObj = new TFSC_SkipTraceController.AddressHistory('1234 addy ST', 'Innovis', '1/1 - 12/12');
        TFSC_SkipTraceController.AddyJsonResponseAndRequest request = new TFSC_SkipTraceController.AddyJsonResponseAndRequest();
        request.updateValuesFromAddyObj(addyObj);
        request.randomId = '';
        
        controllerExt.saveAddyJsonRequest = JSON.serialize(request);
        controllerExt.saveAddress();
        
        addyObj = controllerExt.addressHistory[0];
        request.updateValuesFromAddyObj(addyObj);
        controllerExt.saveAddyJsonRequest = JSON.serialize(request);
        controllerExt.saveAddress(); //for update
        controllerExt.saveAddyJsonRequest = 'asdf';
        controllerExt.saveAddress(); //for update with error
        
        addyObj = controllerExt.addressHistory[0];
        request.updateValuesFromAddyObj(addyObj);
        request.randomId = '';
        controllerExt.saveAddyJsonRequest = JSON.serialize(request);
        controllerExt.saveAddress(); //for duplicate phone check.
        
        addyObj = controllerExt.addressHistory[0];
        request.updateValuesFromAddyObj(addyObj);
        controllerExt.saveAddyJsonRequest = JSON.serialize(request);
        controllerExt.deleteAddress(); //for delete
        controllerExt.saveAddyJsonRequest = 'asdhab';
        controllerExt.deleteAddress(); //for delete with error.
    }
    
    private static void testAndValidateCheckboxes(TFSC_SkipTraceController controllerExt) {
        controllerExt.contextSkipTrace.Multiple_Accounts_Checkbox__c = true;
        controllerExt.contextSkipTrace.DMS_Credit_App_Checkbox__c = true;
        controllerExt.contextSkipTrace.Payment_Review_Checkbox__c = true;
        controllerExt.contextSkipTrace.Innovis_Checkbox__c = true;
        controllerExt.contextSkipTrace.Accurint_Checkbox__c = true;
        controllerExt.contextSkipTrace.Fast_Data_Checkbox__c = true;
        
        controllerExt.saveAfterFieldValueChange();
        
        System.assert( (controllerExt.contextSkipTrace.Multiple_Accounts_Date__c != null) );
    }
    
    
    
    private static Financial_Account__c setupData(Account acct) {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Financial_Account__c financialAccount = new Financial_Account__c(Financial_Account_Number__c = randomString);
        financialAccount.Collection_List_Number_1__c = '1704'; // for FPD
        financialAccount.History_Counter_Days_Past_Due__c = '10';
        insert financialAccount;
        
        
        Collections_Pass_Strategy__c passStrat = new Collections_Pass_Strategy__c(Name = 'Test1', Sort__c = 1, Article_Number__c = '1', Account_Type__c = 'General', RES__c = 'RES1');
        Collections_Pass_Strategy__c passStrat2 = new Collections_Pass_Strategy__c(Name = 'Test2', Sort__c = 2, Article_Number__c = '2', Account_Type__c = 'General', RES__c = 'RES2');
        Collections_Pass_Strategy__c passStrat3 = new Collections_Pass_Strategy__c(Name = 'Test3', Sort__c = 3, Article_Number__c = '3', Account_Type__c = 'General', RES__c = 'RES3');
        Collections_Pass_Strategy__c passStrat4 = new Collections_Pass_Strategy__c(Name = 'Test4', Sort__c = 4, Article_Number__c = '4', Account_Type__c = 'General', RES__c = 'RES4');
        Collections_Pass_Strategy__c passStrat5 = new Collections_Pass_Strategy__c(Name = 'Test5', Sort__c = 5, Article_Number__c = '5', Account_Type__c = 'General', RES__c = 'RES5');
        insert new Collections_Pass_Strategy__c[]{passStrat, passStrat2, passStrat3, passStrat4, passStrat5};
        
        
        return financialAccount;
    }
    private static Financial_Account_Customer__c generateAndInsertFAC(Id FAId, String borrowerPosition, String openOrClosed, Id AcctId) {
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
        fac.Borrower_Position__c = borrowerPosition;
        fac.Borrower_Status__c = 'Active';
        fac.Financial_Account__c = FAId;
        fac.Account__c = acctId;
        fac.Mailing_State_BillTo__c = 'CO';
        fac.Mailing_Postal_Code_Garage__c = '80524';
        
        fac.Work_Phone_Garage__c = EXISTING_PHONE;
        fac.Mobile_Phone__c = EXISTING_PHONE;
        fac.Home_Phone_Garage__c = EXISTING_PHONE;
        fac.Work_Phone_Bill_To__c = EXISTING_PHONE;
        fac.HomePhone_BillTo__c = EXISTING_PHONE;
        
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = 'test';
        fac.FA_Role_Status__c = 'test';
        fac.Financial_Account_Customer__c = 'test2' + TFSC_TestUtils.generateRandomString(4);
        //fac.Finance_Account_Status__c = openOrClosed;
        insert fac;
        
        return fac;
    }
    
 static testmethod void testFaWithPopulatedSkipTrace1() {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Account acct = new Account(name = 'test' + randomString);
        insert acct;
        
        Financial_Account__c financialAccount = setupData(acct);
        
        Financial_Account_Customer__c fac = generateAndInsertFAC(financialAccount.Id, 'Primary', 'Open', acct.Id);
        Financial_Account_Customer__c coFac = generateAndInsertFAC(financialAccount.Id, 'Co-X', 'Open', acct.Id);
        
        Skip_Trace__c skipTrace = new Skip_Trace__c(Financial_Account__c = financialAccount.Id);
        skipTrace.Address1__c = '1234 addy ST';
        skipTrace.Phone1__c = '4064434043';
        skipTrace.Phone1_Source__c = 'Innovis';
     skipTrace.Address1_Source__c = 'Innovis';
        insert skipTrace;
        
        Id collectionCaseId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Collection', 'Case');
        Case newCase = new Case(Financial_Account__c = financialAccount.Id, RecordTypeId = collectionCaseId, status='PASS1x');
        insert newCase;
        
        CollectionsPassStrategy__kav helpTextObj = new CollectionsPassStrategy__kav(UrlName = '123', Title = 'test123', Details__c = 'test123', Language = 'en_US');
        insert helpTextObj;
        String articleNum = [select ArticleNumber, id from CollectionsPassStrategy__kav where id = :helpTextObj.Id].ArticleNumber ;
        Collections_Pass_Strategy__c passStrat = [Select Article_Number__c from Collections_Pass_Strategy__c where RES__c = 'RES3' limit 1];
        passStrat.Article_Number__c = articleNum;
        update passStrat;
        PageReference pageRef = Page.TFSC_SkipTrace;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', financialAccount.Id);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(financialAccount);
        TFSC_SkipTraceController controllerExt = new TFSC_SkipTraceController(standardController);
        controllerExt.selectedPassStrategy = articleNum;
        controllerExt.populatePhonesAndAddresses();
        
        TFSC_SkipTraceController.generateArticleText( articleNum );
        
        testAndValidateCheckboxes(controllerExt);
        testAddingRemovingAddress(controllerExt);
        testAddingRemovingPhoneNumber(controllerExt);
        testUpdatingAltBorrower(controllerExt);
        testTimeStampUpdate(controllerExt);
    }   
    
    static testmethod void testFaWithPopulatedSkipTrace2() {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Account acct = new Account(name = 'test' + randomString);
        insert acct;
        
        Financial_Account__c financialAccount = setupData(acct);
        financialAccount.Collection_List_Number_1__c = '1704';
        financialAccount.Collection_List_Status_1__c = 'A';
        update financialAccount;
        Financial_Account_Customer__c fac = generateAndInsertFAC(financialAccount.Id, 'Primary', 'Open', acct.Id);
        Financial_Account_Customer__c coFac = generateAndInsertFAC(financialAccount.Id, 'Co-X', 'Open', acct.Id);
        
        Skip_Trace__c skipTrace = new Skip_Trace__c(Financial_Account__c = financialAccount.Id);
        skipTrace.Address1__c = '1234 addy ST';
        skipTrace.Phone1__c = '4064434043';
        skipTrace.Phone1_Source__c = 'Innovis';
     skipTrace.Address1_Source__c = 'Innovis';
        insert skipTrace;
        
        Id collectionCaseId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Collection', 'Case');
        Case newCase = new Case(Financial_Account__c = financialAccount.Id, RecordTypeId = collectionCaseId, status='PASS1x');
        insert newCase;
        
        CollectionsPassStrategy__kav helpTextObj = new CollectionsPassStrategy__kav(UrlName = '123', Title = 'test123', Details__c = 'test123', Language = 'en_US');
        insert helpTextObj;
        String articleNum = [select ArticleNumber, id from CollectionsPassStrategy__kav where id = :helpTextObj.Id].ArticleNumber ;
        Collections_Pass_Strategy__c passStrat = [Select Article_Number__c from Collections_Pass_Strategy__c where RES__c = 'RES3' limit 1];
        passStrat.Article_Number__c = articleNum;
        update passStrat;
        PageReference pageRef = Page.TFSC_SkipTrace;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', financialAccount.Id);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(financialAccount);
        TFSC_SkipTraceController controllerExt = new TFSC_SkipTraceController(standardController);
        
    }
    
    static testmethod void testFaWithPopulatedSkipTrace3() {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Account acct = new Account(name = 'test' + randomString);
        insert acct;
        
        Financial_Account__c financialAccount = setupData(acct);
        financialAccount.Collection_List_Number_1__c = '1800';
        financialAccount.Collection_List_Status_1__c = 'A';
        update financialAccount;
        Financial_Account_Customer__c fac = generateAndInsertFAC(financialAccount.Id, 'Primary', 'Open', acct.Id);
        Financial_Account_Customer__c coFac = generateAndInsertFAC(financialAccount.Id, 'Co-X', 'Open', acct.Id);
        
        Skip_Trace__c skipTrace = new Skip_Trace__c(Financial_Account__c = financialAccount.Id);
        skipTrace.Address1__c = '1234 addy ST';
        skipTrace.Phone1__c = '4064434043';
        skipTrace.Phone1_Source__c = 'Accurint';
     skipTrace.Address1_Source__c = 'Accurint';
        insert skipTrace;
        
        Id collectionCaseId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Collection', 'Case');
        Case newCase = new Case(Financial_Account__c = financialAccount.Id, RecordTypeId = collectionCaseId, status='PASS1x');
        insert newCase;
        
        CollectionsPassStrategy__kav helpTextObj = new CollectionsPassStrategy__kav(UrlName = '123', Title = 'test123', Details__c = 'test123', Language = 'en_US');
        insert helpTextObj;
        String articleNum = [select ArticleNumber, id from CollectionsPassStrategy__kav where id = :helpTextObj.Id].ArticleNumber ;
        Collections_Pass_Strategy__c passStrat = [Select Article_Number__c from Collections_Pass_Strategy__c where RES__c = 'RES4' limit 1];
        passStrat.Article_Number__c = articleNum;
        update passStrat;
        PageReference pageRef = Page.TFSC_SkipTrace;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', financialAccount.Id);
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(financialAccount);
        TFSC_SkipTraceController controllerExt = new TFSC_SkipTraceController(standardController);
        
    }
    
}