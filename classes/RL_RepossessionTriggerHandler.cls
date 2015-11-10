/*****
 * Salesforce.com Success Services
 * Name: RL_RepossessionTriggerHandler
 * Description: Handler class for Repossession Trigger to reject updates from iRepo and UR after Doc request was created and to compute the legal sale date.
 */

public with sharing class RL_RepossessionTriggerHandler implements TFSC_TriggerDispatcher.Handler{
    private List<Repossession__c> newRepoList = (List<Repossession__c>)Trigger.new;
    private Map<Id,Repossession__c> newRepoMap = (Map<Id,Repossession__c>)Trigger.NewMap;
    private Map<Id,Repossession__c> oldRepoMap = (Map<Id,Repossession__c>)Trigger.oldMap;
        
    private Map<Id, Repossession__c> caseIdRepoMap = new Map<Id, Repossession__c>();
    private Map<Repossession__c, Case> repoCaseMap = new Map<Repossession__c, Case>();
    private Map<Id, Repossession__c> ruleIdRepoMap = new Map<Id, Repossession__c>();
    private Map<Repossession__c, Form_Rule__c> repoFormRuleMap = new Map<Repossession__c, Form_Rule__c>();
    private Repossession__c readOnlyRepo;
    private DateTime legalSaleDateTime = null;
    private Time aTime = Time.newInstance(1, 0, 0, 0);    

    private List<Schema.FieldSetMember> unitedRoadFields = SObjectType.Repossession__c.FieldSets.United_Road.getFields();
    private List<Schema.FieldSetMember> iRepoFields = SObjectType.Repossession__c.FieldSets.iRepo.getFields();

    public void handle() {
        // Block updates from iRepo and UR if a document request exists for this repossession
        if (Trigger.isUpdate) {
            for (Document_Request__c docRequest : [SELECT Id, Repossession__c FROM Document_Request__c WHERE Repossession__c =: newRepoList]) {
                readOnlyRepo = (Repossession__c) newRepoMap.get(docRequest.Repossession__c);

                //United Road fields
                for (Schema.FieldSetMember fs : unitedRoadFields) {
                    readOnlyRepo.put(fs.getFieldPath(), oldRepoMap.get(docRequest.Repossession__c).get(fs.getFieldPath()));
                }

                //iRepo Fields
                for (Schema.FieldSetMember iRepoFs : iRepoFields) {
                    readOnlyRepo.put(iRepoFs.getFieldPath(), oldRepoMap.get(docRequest.Repossession__c).get(iRepoFs.getFieldPath()));
                }
            }
        }
        
        // Build CaseID to Repossession sObject dictionary
        for (Repossession__c repo : newRepoList) {
            if ((repo.Proposed_Notice_Date__c != null && oldRepoMap == null) || (oldRepoMap != null && repo.Proposed_Notice_Date__c != oldRepoMap.get(repo.Id).Proposed_Notice_Date__c)) {
                caseIdRepoMap.put(repo.Case__c, repo);
            }
        }

        // Build Repossession to Case sObject dictionary
        for (Case aCase : [Select Id, Form_Rule__c, Financial_Account__c, BusinessHours.Id FROM Case where Id in : caseIdRepoMap.keySet()]) {
            repoCaseMap.put(caseIdRepoMap.get(aCase.Id), aCase);
            ruleIdRepoMap.put(aCase.Form_Rule__c, caseIdRepoMap.get(aCase.Id)); // !!!!!!!!!!!!!!!!
        }

        // Build Repossession to Form Rule sObject dictionary
        for (Form_Rule__c rule : [SELECT Id, Sale_Calendar__c, Days_Till_Sale__c from Form_Rule__c WHERE Id in : ruleIdRepoMap.keySet()]) {
            repoFormRuleMap.put(ruleIdRepoMap.get(rule.Id), rule);
        }

        // Compute Legal sale date on repossession
        for (Repossession__c repo : repoFormRuleMap.keySet()) {
            //Business Days
            if (repoFormRuleMap.get(repo).Sale_Calendar__c.equalsIgnoreCase(RL_Constants.NOTICE_CALENDAR_BUSINESS)) {
                legalSaleDateTime = RL_Utility.AddBusinessDays(DateTime.newInstance(repo.Proposed_Notice_Date__c, aTime), Integer.valueOf(repoFormRuleMap.get(repo).Days_Till_Sale__c), repoCaseMap.get(repo).BusinessHours.Id);

            //Calendar Days
            }  else if (repoFormRuleMap.get(repo).Sale_Calendar__c.equalsIgnoreCase(RL_Constants.NOTICE_CALENDAR_CALENDAR)) {
                legalSaleDateTime = (repo.Proposed_Notice_Date__c).addDays(Integer.valueOf(repoFormRuleMap.get(repo).Days_Till_Sale__c));
            }
            repo.Proposed_Legal_Sale_Date__c = Date.valueOf(legalSaleDateTime);
        }
    }
}