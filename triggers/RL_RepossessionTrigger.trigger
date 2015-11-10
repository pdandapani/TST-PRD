/*****
 * Salesforce.com Success Services
 * Name: RL_RepossessionTrigger
 * Description: Determine the proposed legal sale date based on the proposed notice date on Repossession.
 */

trigger RL_RepossessionTrigger on Repossession__c (before insert, before update) {
    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new RL_RepossessionTriggerHandler())
        .bind(TFSC_TriggerDispatcher.Evt.beforeupdate, new RL_RepossessionTriggerHandler())
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new RL_CaseOwnershipHandler())
        .manage();
}