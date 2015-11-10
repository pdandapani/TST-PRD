/**
*   Modified By : David Zheng
*   Modified Date : 7/16/2015
*   Story : S-311850
*   Description : Test class for DeletePreviousInteractions 
*/
@isTest
private class DeletePreviousInteractionsTest {
    static testmethod void test() {
        //creating tempinteraction__c records
        list<tempinteraction__c> interactiontoinsert = new list<tempinteraction__c>();
        for(Integer i=0;i<100;i++) {
            interactiontoinsert.add(new tempinteraction__c(name = 'test' + string.valueof(i), Interaction_Type__c = string.valueof(i)));
        }
        insert interactiontoinsert;
        
        // The query used by the batch job.
        String query = 'SELECT Name, Interaction_Type__c FROM tempinteraction__c WHERE Name LIKE \'test%\'';
        
        Test.startTest();
        DeletePreviousInteractionsScheduler sh = new DeletePreviousInteractionsScheduler();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh);
        DeletePreviousInteractions c = new DeletePreviousInteractions(query);
        Database.executeBatch(c);
        Test.stopTest();
        
        // Verify tempinteraction__c records got deleted
        Integer i = [SELECT COUNT() FROM  tempinteraction__c WHERE Name LIKE 'test%'];
        System.assertEquals(i, 0);


    }
}