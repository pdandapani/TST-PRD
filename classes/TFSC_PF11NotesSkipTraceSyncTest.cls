@isTest
private class TFSC_PF11NotesSkipTraceSyncTest {
    
    
    static testmethod void testPF11Update() {
        
        Account acct = new Account(name = 'testAcct' + TFSC_TestUtils.generateRandomString(4));
        insert acct;
        
        Financial_Account__c fAcct = setupData(acct);
        
        Financial_Account_Customer__c facPrimary = generateAndInsertFAC(fAcct.Id, 'Primary','Open', acct.Id);
        
        PF11_Notes__c pfNote = generatePF11NoteRecord(fAcct);
        insert pfNote;
        
        Test.startTest();
            TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE = false;
            pfNote.Notes_4__c = 'PHN: ___9517199257 G# 06/09, ___9517199255 G# 05/09,   06/09';
            update pfNote;
        Test.stopTest();
    }
    
    
    static testmethod void testPF11Insert() {
        
        Account acct = new Account(name = 'testAcct' + TFSC_TestUtils.generateRandomString(4));
        insert acct;
        
        Financial_Account__c fAcct = setupData(acct);
        
        Financial_Account_Customer__c facPrimary = generateAndInsertFAC(fAcct.Id, 'Primary','Open', acct.Id);
        
        Test.startTest();
            TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE = false;
            PF11_Notes__c pfNote = generatePF11NoteRecord(fAcct);
            //FOR ERR COVERAGE.
            pfNote.Notes_7__c = 'XYZ: ___5555555555 G# 06/09, ___6666666666 G# 06/09,   06/09';
            pfNote.Notes_8__c = 'PHN: ___777';
            insert pfNote;
        Test.stopTest();
        
        PF11_Notes__c noteWithErr = [select id, Validation_Errors__c from PF11_Notes__c where id = :pfNote.Id];
        system.assert( !TFSC_Utils.isNullOrEmpty(noteWithErr.Validation_Errors__c) );
    }
    
    
    private static Financial_Account_Customer__c generateAndInsertFAC(Id FAId, String borrowerPosition, String openOrClosed, Id AcctId) {
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
        fac.Borrower_Position__c = borrowerPosition;
        fac.Borrower_Status__c = 'Active';
        fac.Financial_Account__c = FAId;
        fac.Account__c = acctId;
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = 'test';
        fac.FA_Role_Status__c = 'test';
        fac.Financial_Account_Customer__c = 'test2' + TFSC_TestUtils.generateRandomString(4);
        //fac.Finance_Account_Status__c = openOrClosed;
        insert fac;
        
        return fac;
    }
    
    
    private static PF11_Notes__c generatePF11NoteRecord(Financial_Account__c fAcct) {
        
        PF11_Notes__c pf11note = new PF11_Notes__c();
        pf11note.Financial_Account__c = fAcct.Id;
        pf11note.Financial_Account_Number__c = TFSC_TestUtils.generateRandomString(10);
        
        pf11note.Notes_2__c = 'COX: H# 1299999999 G# 06/09, W# 1288888888 X# 06/09,   06/09';
        pf11note.Notes_3__c = 'CEL: C# 1277777777 D# 06/09, X# 1266666666 B# 06/09,   06/09';
        pf11note.Notes_4__c = 'PHN: ___1111111111 G# 06/09, ___2222222222 G# 06/09,   06/09';
        pf11note.Notes_5__c = 'PHN: ___3333333333 G# 06/09, ___4444444444 G# 06/09,   06/09';
        pf11note.Notes_7__c = 'PHN: ___5555555555 G# 06/09, ___6666666666 G# 06/09,   06/09';
        pf11note.Notes_8__c = 'PHN: ___7777777777 G# 06/09, ___8888888888 G# 06/09,   06/09';
        pf11note.Notes_9__c = 'PHN: ___9999999999 G# 06/09, ___9700000001 G# 06/09,   06/09';
        pf11note.Notes_10__c = 'PHN: ___9700000002 G# 06/09, ___9700000003 G# 06/09,   01/01';
        pf11note.Notes_11__c = 'C/A: M# 9700000006 H# 06/09, W# 9700000007 C# 06/09,   06/09';
        pf11note.Notes_12__c = 'X/A: H# 9700000008 S# 06/09, W# 9700000009 N# 06/09,   12/30';
        pf11note.Notes_13__c = 'CAC: C# 9700000010 L# 06/09, X# 9700000011 M# 06/09,   06/09';
        pf11note.Notes_15__c = 'AKA: MICHAEL MICHAEL MOTORCYCLE,                       06/09';
        pf11note.Notes_17__c = 'OA#: ___9700000012 D# 06/09, ___9700000013 B# 06/09,   06/09';
        pf11note.Notes_18__c = 'OA#: ___9700000014 H# 06/09, ___9700000015 L# 06/09,   06/09';
        pf11note.Notes_19__c = 'AAD: DELACEY ST, PASADENA, CA 91105,                   06/09';
        pf11note.Notes_20__c = 'CEA: 40003 CAPE COD LN, TEMECULA, CA 92591,            06/09';
        pf11note.Notes_21__c = 'XEA: 3131 RUSTIC CT, FORT COLLINS, CO 80526,           06/09';
        pf11note.Notes_22__c = 'SPC: RANDOMNESS,                                       06/09';
        //pf11note.Notes_23__c = 'MSC: MISCELLANEOUS RANDOMNESS,                         06/09';
        pf11note.Notes_25__c = 'INN: 06/09/14,                                         06/09';
        pf11note.Notes_26__c = 'FDA: 06/09/14,                                         06/09';
        pf11note.Notes_27__c = 'ACC: 06/09/14,                                         06/09';
        
        return pf11note;
    }
    
    
    private static Financial_Account__c setupData(Account acct) {
        
        Financial_Account__c financialAccount = new Financial_Account__c(Financial_Account_Number__c = '1212');
        insert financialAccount;
        
        
        return financialAccount;
    }
    
    
}