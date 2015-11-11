@isTest
private class TFSC_SkipTraceUpdateSyncPF11Test {
    
    
    
    static testmethod void testSkipTraceUpdate() {
        
        Account acct = new Account(name = 'testAcct' + TFSC_TestUtils.generateRandomString(4));
        insert acct;
        
        Financial_Account__c fAcct = setupData(acct);
        
        Test.startTest();
            Skip_Trace__c st = generateSkipTraceRecord(fAcct);
            insert st;
        Test.stopTest();
    }
    
    
    private static Skip_Trace__c generateSkipTraceRecord(Financial_Account__c fAcct) {
        
        Skip_Trace__c st = new Skip_Trace__c();
        st.Financial_Account__c = fAcct.Id;
        st.Phone1__c = '1111111111';
        st.Phone1_CS_CX__c = 'CX';
        st.Phone1_Source__c = 'Credit App';
        st.Phone1_Status__c = 'G - Good Number (C,A)';
        st.Phone2__c = '2222222222';
        st.Phone2_CS_CX__c = 'CX';
        st.Phone2_Source__c = 'Credit App';
        st.Phone2_Status__c = 'G - Good Number (C,A)';
        st.Phone3__c = '3333333333';
        st.Phone3_CS_CX__c = 'CX';
        st.Phone3_Source__c = 'Credit App';
        st.Phone3_Status__c = 'G - Good Number (C,A)';
        st.Phone4__c = '4444444444';
        st.Phone4_CS_CX__c = 'CX';
        st.Phone4_Source__c = 'Credit App';
        st.Phone4_Status__c = 'G - Good Number (C,A)';
        st.Phone5__c = '5555555555';
        st.Phone5_CS_CX__c = 'CX';
        st.Phone5_Source__c = 'Credit App';
        st.Phone5_Status__c = 'G - Good Number (C,A)';
        st.Phone6__c = '6666666666';
        st.Phone6_CS_CX__c = 'CX';
        st.Phone6_Source__c = 'Credit App';
        st.Phone6_Status__c = 'G - Good Number (C,A)';
        st.Phone7__c = '7777777777';
        st.Phone7_CS_CX__c = 'CX';
        st.Phone7_Source__c = 'Credit App';
        st.Phone7_Status__c = 'G - Good Number (C,A)';
        st.Phone8__c = '8888888888';
        st.Phone8_CS_CX__c = 'CX';
        st.Phone8_Source__c = 'Credit App';
        st.Phone8_Status__c = 'G - Good Number (C,A)';
        st.Innovis_Date__c = Date.today();
        
        st.Phone1_Type__c = 'Mobile';
        st.Phone2_Type__c = '';
        st.Phone3_Type__c = 'Work';
        st.Phone4_Type__c = 'Work';
        st.Phone1_Date__c = Date.newInstance(Date.today().year(), 12, 30);
        st.Phone2_Date__c = Date.newInstance(Date.today().year() - 1, 1, 1);
        
        
        
        
        return st;
    }
    
    
    
    
    private static Financial_Account__c setupData(Account acct) {
        
        Financial_Account__c financialAccount = new Financial_Account__c(Financial_Account_Number__c = '1212aabb45');
        insert financialAccount;
        
        
        return financialAccount;
    }
    
    
}