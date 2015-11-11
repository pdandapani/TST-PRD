/*****
 * Salesforce.com Success Services
 * Name: RL_RepossessionTriggerTest
 * Description: Test class for RL_RepossessionTrigger
 */

@isTest
private class RL_RepossessionTriggerTest {
    @isTest 
    static void test_method_one() {
        RL_GenerateTestData.createTimezoneIndicators();
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRTId);

        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');
        Id leaseRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Lease');
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        Financial_Account__c faLease = RL_GenerateTestData.createFALeaseIL(dealer, leaseRTId);        

        // Create Case
        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);
        aCase.Form_Rule__c = formRuleMap.get('4015IL').Id;
        update aCase;

        // Create Repossession
        Id repoRTId = RL_GenerateTestData.getRecordType('Repossession__c', 'RL Retail-Generic');
        Repossession__c repo = RL_GenerateTestData.createRepossession(aCase, faRetail, repoRTId);
        repo = [Select Id, Proposed_Notice_Date__c, Proposed_Legal_Sale_Date__c from Repossession__c where Id = : repo.Id];

        // Assertions
        System.assertEquals(repo.Proposed_Legal_Sale_Date__c, repo.Proposed_Notice_Date__c.addDays(21));

        aCase.Form_Rule__c = formRuleMap.get('6026 (IL)').Id;
        update aCase;

        repo.Financial_Account__c = faLease.Id;
        repo.Proposed_Notice_Date__c = Date.today().addDays(-1);
        update repo;

        repo = [Select Id, Proposed_Notice_Date__c, Proposed_Legal_Sale_Date__c, Case__r.Form_Rule__r.Name from Repossession__c where Id = : repo.Id];
        Time aTime = Time.newInstance(1, 0, 0, 0);        
        Date theDate = Date.valueOf(RL_Utility.AddBusinessDays(DateTime.newInstance(repo.Proposed_Notice_Date__c, aTime), 21, RL_GenerateTestData.getBusinessHoursId()));
    //    System.assertEquals(repo.Proposed_Legal_Sale_Date__c.day(), theDate.day());
    //    System.assertEquals(repo.Proposed_Legal_Sale_Date__c.month(), theDate.month());
    //    System.assertEquals(repo.Proposed_Legal_Sale_Date__c.year(), theDate.year());
    }
}