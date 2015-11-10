/*****
 * Salesforce.com Success Services
 * Name: RL_CaseOwnershipHandler
 * Description: Sets the case owner to Rights Letters queue when a new repossession is created
 */

public with sharing class RL_CaseOwnershipHandler implements TFSC_TriggerDispatcher.Handler {
	private QueueSObject queue;
    private List<Repossession__c> newRepoList = (List<Repossession__c>)Trigger.new;
    private List<Case> caseList;
    private List<Id> caseIdList = new List<Id>();

    public void handle() {
        General_Settings__c gs = General_Settings__c.getInstance();
        for (Repossession__c repo : newRepoList) {
            caseIdList.add(repo.Case__c);
        }
        caseList = [SELECT Id, OwnerId FROM Case WHERE Id =: caseIdList];    
        queue = [SELECT Id, Queue.Name, Queue.Id from QueueSObject WHERE Queue.Name = 'Rights Letters' AND SObjectType = 'Case'];
        for (Case aCase : caseList) {
            if (gs.Data_Admin_Exemption__c) {
                aCase.OwnerId = queue.Queue.Id;
            }
        }
        update caseList;
    }
}