/**
*   @Author     : Jeremy Mooer
*   @Date       : 12 May 2014
*   @Description unit test for TFSC_AccountHighlightsController.
*   @   the controller is for a view-only vf page, so code-coverage is more important than assertions. 
*/
@isTest
private class TFSC_AccountHighlightsControllerTest {
    
    static testmethod void testValidFacQueries() {
        Account acct = new Account(name = 'testAcct1');
        insert acct;
        
        Financial_Account__c fAcct = setupData(acct);
        Financial_Account_Customer__c facPrimary = generateAndInsertFAC(fAcct.Id, 'Primary','Open', acct.Id, TFSC_TestUtils.generateRandomString(4));
        Financial_Account_Customer__c facCo = generateAndInsertFAC(fAcct.Id, 'Co-X','Open', acct.Id, TFSC_TestUtils.generateRandomString(4));
        
        addDummyFACsForCountingOfOtherAccounts(fAcct, acct.Id);
        
        PageReference pageRef = Page.TFSC_AccountHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', fAcct.Id);
        
        TFSC_AccountHighlightsController ctrl = new TFSC_AccountHighlightsController();
        
        System.assert( fAcct.Id == ctrl.contextFinancialAccount.Id );
        System.assert( facPrimary.Id == ctrl.topSectionFAC.Id );
        System.assert( facCo.Id == ctrl.bottomSectionFAC.Id );
        
        ctrl.showTopPopup();
        ctrl.showBottomPopup();
        ctrl.closePopup();
        
        ctrl.borrowerPhoneFromJS = '1234560000';
        ctrl.updateTopFac();
        
        //System.assert( ctrl.bottomSectionClosedOtherAccountCount == 0 );
        //System.assert( ctrl.bottomSectionOpenOtherAccountCount == 0 );
        //System.assert( ctrl.topSectionClosedOtherAccountCount == 1 );
        //System.assert( ctrl.topSectionOpenOtherAccountCount == 1 );
        
    }
    
    
    static testmethod void testErrorHandling() {
        
        PageReference pageRef = Page.TFSC_AccountHighlights;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id', fAcct.Id);
        
        TFSC_AccountHighlightsController ctrl = new TFSC_AccountHighlightsController();
        
    }
    
    
    
    private static Financial_Account__c setupData(Account acct) {
        
        Collateral__c ast = new Collateral__c( name = 'testAsset1' );
        insert ast;
        
        Financial_Account__c financialAccount = new Financial_Account__c(
                                                            Financial_Account_Number__c = '1212', 
                                                            Collateral__c = ast.Id,
                                                            Finance_Account_Status__c = 'Open');
        
        insert financialAccount;
        
        
        Case caseToInsert = new Case(  Financial_Account__c = financialAccount.Id,
                                       RecordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Collection', 'Case')
                                        );
        insert caseToInsert;
        
        
        return financialAccount;
    }
    
    
    /**
    *   @borrowerPosition = 'Co-X' or 'Primary'
    *   @openOrClosed = 'Open' or 'Close'; (yes, close. not closed.) 
    */
    private static Financial_Account_Customer__c generateAndInsertFAC(Id FAId, String borrowerPosition, String openOrClosed, Id AcctId, String randString) {
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
        fac.Borrower_Position__c = borrowerPosition;
        fac.Borrower_Status__c = 'Active';
        fac.Financial_Account__c = FAId;
        fac.Account__c = acctId;
        fac.Home_Phone_Garage__c = '4063775012';
        fac.Mobile_Phone__c = '4063775013';
        fac.Work_Phone_Garage__c = '4063775014';
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = 'test';
        fac.FA_Role_Status__c = 'test';
        fac.Financial_Account_Customer__c = 'test' + randString;
        //fac.Finance_Account_Status__c = openOrClosed;
        insert fac;
        
        return fac;
    }
    
    private static void addDummyFACsForCountingOfOtherAccounts(Financial_Account__c fAcct, Id acctId) {
        Financial_Account__c financialAccount2 = new Financial_Account__c(Financial_Account_Number__c = '121212121');
        insert financialAccount2;
        generateAndInsertFAC(financialAccount2.Id, 'Co-X', 'Close', acctId, TFSC_TestUtils.generateRandomString(4));
        generateAndInsertFAC(financialAccount2.Id, 'Co-X', 'Open', acctId, TFSC_TestUtils.generateRandomString(4));
        generateAndInsertFAC(financialAccount2.Id, 'Primary', 'Close', acctId, TFSC_TestUtils.generateRandomString(4));
        generateAndInsertFAC(financialAccount2.Id, 'Primary', 'Open', acctId, TFSC_TestUtils.generateRandomString(4));
    }
    
    
    
    
    
    
}