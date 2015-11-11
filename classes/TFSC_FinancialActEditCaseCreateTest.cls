@isTest
private class TFSC_FinancialActEditCaseCreateTest {
    
    
    static testmethod void testWithDefaultUser() {
        Account acct = new Account(name = 'testAcct123');
        insert acct;
        
        Financial_Account__c fAcct = setupData(acct);
        Financial_Account_Customer__c facPrimary = generateAndInsertFAC(fAcct.Id, 'Primary','Open', acct.Id, TFSC_TestUtils.generateRandomString(4));
        
        Test.startTest();
            facPrimary.Mailing_State_BillTo__c = 'MT';
            facPrimary.Election_Payment_NotReceivedText__c = 'Yes';
            update facPrimary;
        Test.stopTest();
    }
    
    
    static testmethod void testWithAcceptableUser() {
        User testUser = generateTestUser();
        
        System.RunAs(testUser){
            Test.startTest();
                
                Account acct = new Account(name = 'testAcct123321');
                insert acct;
                
                Financial_Account__c fAcct = setupData(acct);
                Financial_Account_Customer__c facPrimary = generateAndInsertFAC(fAcct.Id, 'Primary','Open', acct.Id, TFSC_TestUtils.generateRandomString(4));
                
                //facPrimary.Mailing_State_BillTo__c = 'MT';
                facPrimary.Election_Payment_NotReceivedText__c = 'Yes';
                update facPrimary;
            Test.stopTest();
        }
    }
    
    private static User generateTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Collections']; 
        User usr = new User(Alias = 'stst123', Email='standarduser123@toyotaDevish.com', 
        					Coll_Racf_Id__c = 'XXX123',
                            Lan_Id__c = 'LANID', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            Service_Request_User_Group__c = 'test',
                            Service_Request_Service_Type__c = 'test',
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@toyotaDevish.com');
        return usr;
    }
    
    
    private static Financial_Account__c setupData(Account acct) {
        
        Financial_Account__c financialAccount = new Financial_Account__c(Financial_Account_Number__c = '12123434');
        financialAccount.Communication_Comments__c = 'test comments';
        financialAccount.RecordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Lease', 'Financial_Account__c') ;
        insert financialAccount;
        
        //Asset ast = new Asset( name = 'testAsset1', AccountId = acct.Id, Financial_Account__c = financialAccount.Id );
        //insert ast;
        
        Service_Request_Field_Map__c customSettingToInsert = new Service_Request_Field_Map__c();
        customSettingToInsert.Name = 'Mailing_State_BillTo__c';
        customSettingToInsert.Source_Field__c = 'Mailing_State_BillTo__c';
        customSettingToInsert.Source_Object__c = 'Financial_Account_Customer__c';
        customSettingToInsert.Target_Object__c = 'Case';
        customSettingToInsert.Target_Field__c = 'Description';
        customSettingToInsert.Record_Type__c = 'Customer Profile Change';
        customSettingToInsert.Type__c = 'Test';
        customSettingToInsert.Group__c = 1;
        customSettingToInsert.Conversion_Type__c = '';
        customSettingToInsert.Address_Type__c = 'test';
        customSettingToInsert.Service_Request_Category__c = 'test';
        customSettingToInsert.Service_Result__c = 'test';
        insert customSettingToInsert;
        
        Service_Request_Field_Map__c customSettingToInsert2 = new Service_Request_Field_Map__c();
        customSettingToInsert2.Name = 'Election_Payment_NotReceivedText__c';
        customSettingToInsert2.Source_Field__c = 'Election_Payment_NotReceivedText__c';
        customSettingToInsert2.Source_Object__c = 'Financial_Account_Customer__c';
        customSettingToInsert2.Target_Object__c = 'Case';
        customSettingToInsert2.Target_Field__c = 'Payment_Not_Received_Text__c';
        customSettingToInsert2.Record_Type__c = 'Customer Profile Change';
        customSettingToInsert2.Type__c = 'Test';
        customSettingToInsert2.Group__c = 1;
        customSettingToInsert2.Conversion_Type__c = ''; //Boolean was here.
        customSettingToInsert.Address_Type__c = 'test';
        customSettingToInsert.Service_Request_Category__c = 'test';
        customSettingToInsert.Service_Result__c = 'test';
        insert customSettingToInsert2;
        
        
        return financialAccount;
    }
    private static Financial_Account_Customer__c generateAndInsertFAC(Id FAId, String borrowerPosition, String openOrClosed, Id AcctId, String randString) {
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
        fac.Borrower_Position__c = borrowerPosition;
        fac.Borrower_Status__c = 'Active';
        fac.Financial_Account__c = FAId;
        fac.Account__c = acctId;
        fac.Mailing_State_BillTo__c = 'CO';
        fac.Mailing_City_BillTo__c = 'Fort Collins';
        fac.Mailing_PostalCode_BillTo__c = '23456';
        fac.Mailing_Street_BillTo__c = '123 1st st';
        
        fac.Mailing_State_Garage__c = 'CO';
        fac.Mailing_City_Garage__c = 'Fort Collins';
        fac.Mailing_Postal_Code_Garage__c = '23456';
        fac.Mailing_Street_Garage__c = '123 1st st';
        //fac.Mailing_Postal_Code_Garage__c = '12345';
        fac.Financial_Account_Customer__c = '12345566';
        fac.Election_Overall_Consent__c = 'Y';
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = 'test';
        fac.FA_Role_Status__c = 'test';
        fac.Financial_Account_Customer__c = 'test' + randString;
        //fac.Finance_Account_Status__c = openOrClosed;
        insert fac;
        
        return fac;
    }
    
    
    
}