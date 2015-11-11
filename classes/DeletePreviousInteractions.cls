/**
*   Modified By : David Zheng
*   Modified Date : 7/16/2015
*   Story : S-311850
*   Description : delete old tempInteraction records 
*/
global class DeletePreviousInteractions implements Database.Batchable<SObject>{

    global String query;
    
    global DeletePreviousInteractions(){
        query = 'SELECT Id FROM tempinteraction__c';
    }

    global DeletePreviousInteractions(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<tempinteraction__c> listToDelete = new List<tempinteraction__c>();
        for (SObject s : scope) {
          listToDelete.add((tempinteraction__c)s);
        }
        delete listToDelete;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

}