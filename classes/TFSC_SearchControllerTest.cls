@isTest
private class TFSC_SearchControllerTest {
    
   static testmethod void testCustomSearch() {
        
    Id persAccId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Customer', 'Account');
    Id bussAccId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Business_Account', 'Account');

    Account personAcct = new Account(FirstName='FName',LastName ='LName',RecordTypeId=persAccId, Social_Security_Number__pc='11111111');
    insert personAcct;

    Account bussAcc = new Account(name = 'Business Account123' ,RecordTypeId=bussAccId,Tax_Identification_Number__c='11111111');
    insert bussAcc;

    Collateral__c car = new Collateral__c(Vehicle_Identification_Number__c ='11111111111111111111',Make__c='Toyota', Model_Name__c='Camry',Model_Year__c='2015');
    insert car;

    Financial_Account__c fa = insertFA(car);    
    
    Financial_Account_Customer__c personfac = insertFAC(fa, personAcct);
    Financial_Account_Customer__c busifac = insertFAC(fa, bussAcc);        
    
    TFSC_searchController searchController1 = new TFSC_searchController();
    TFSC_searchController searchController2 = new TFSC_searchController();
    TFSC_searchController searchController3 = new TFSC_searchController();
    
    //Positive Scenario1
    searchController1.fANumber = '00070411111111110001';
    searchController1.sSN = '11111111';
    searchController1.fName = 'FN';
    searchController1.lName = 'LName';
    searchController1.garZip = '11111';
    searchController1.vINFull = '11111111111111111111';
    searchController1.vIN8 = '11111111';
    searchController1.searchFAC();
    searchController1.reset();
    Integer tempInt =  searchController1.getnoOfFAC();
    tempInt =  searchController1.getnoOfFA();
    String tempStr = searchController1.getoneFAId();
    tempStr = searchController1.getoneFANo();

    //Positive Scenario1
    searchController2.fANumber = '1111111111';
    searchController2.tIN = '11111111';
    searchController2.busiName = 'Business';

    searchController2.searchFAC();
    
    //Negative Scenario = 0 records
    searchController3.fANumber = '00000000001111110001';
    searchController3.sSN = '00000000';
    searchController3.searchFAC();
    System.assertEquals(searchController3.searchedFACs.size(), 0);

    }


    private static Financial_Account__c insertFA(Collateral__c car) {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Financial_Account__c financialAccount = new Financial_Account__c(Financial_Account_Number__c = '1111111111', Collateral__c=car.Id,Finance_Account_Status__c='Active', CO_Host_Account_Number__c='00070411111111110001' );
        financialAccount.Collection_List_Number_1__c = '1704'; // for FPD
        financialAccount.History_Counter_Days_Past_Due__c = '10';
        insert financialAccount;        
       
        return financialAccount;
    }

    private static Financial_Account_Customer__c insertFAC(Financial_Account__c fa, Account acc) {
        
        String randomString = TFSC_TestUtils.generateRandomString(6);
        
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c(Financial_Account__c = fa.Id, Account__c = acc.Id, Mailing_Postal_Code_Garage__c='11111' );
    fac.Borrower_Position__c = 'Primary';
        fac.Borrower_Status__c = 'Active';
        fac.Mailing_State_BillTo__c = 'CO';        
        fac.Work_Phone_Garage__c = '1111111111';
        fac.Mobile_Phone__c = '1111111111';
        fac.Home_Phone_Garage__c = '1111111111';
        fac.Work_Phone_Bill_To__c = '1111111111';
        fac.HomePhone_BillTo__c = '1111111111';
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = 'test';
        fac.FA_Role_Status__c = 'test';
    fac.Financial_Account_Customer__c = 'test2' + TFSC_TestUtils.generateRandomString(4);


        insert fac;        
       
        return fac;
    }


}