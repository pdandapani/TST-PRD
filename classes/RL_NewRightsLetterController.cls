public with sharing class RL_NewRightsLetterController{
    public Id newCaseId {get; private set;}

    public RL_NewRightsLetterController(ApexPages.StandardController stdController){
    }

    public void createRightsLetter() {

        //Create parent Rights Letter case
        Id rlRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Rights Letter').getRecordTypeId();
        Case newCase = new Case(RecordTypeId = rlRecTypeId);
        Database.SaveResult sr = Database.insert(newCase);
        newCaseId = sr.getId();

        //Create child Repossession case
        Id repoRecTypeId = Schema.SObjectType.Repossession__c.getRecordTypeInfosByName().get('RL Manual Entry').getRecordTypeId();
        Repossession__c newRepo = new Repossession__c(RecordTypeId = repoRecTypeId, Case__c = newCaseId);
        Insert newRepo;
    }
}