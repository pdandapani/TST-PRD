public with sharing class TFSC_CaseOutComeHandler implements TFSC_TriggerDispatcher.Handler {
    
    private static final String XDEFAULT = 'Default'; 

    public void handle() {
        findCaseOutcome(trigger.new);
        if(trigger.isBefore && trigger.isInsert)
            setServiceTypeonCustomProfieChangeCase(trigger.new);// S-311850
    }
    // S-311850 #Start 7/10/2015 By Paras Dhingra
    private void setServiceTypeonCustomProfieChangeCase(List<Case> cases){
        Id customerProfileChangeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Change').getRecordTypeId();
        //find all related FA Ids, so that we can query against the temp interaction table
        Set<string> FAIds = new Set<string>();
        for(Case cs : Cases){
            if(cs.Financial_Account__c != null){
                FAIds.add(String.valueOf(cs.Financial_Account__c).left(15));
            }
        }
        //find corresponding interaction types based on related FA records
        Map<string, String> interactionmap = new Map<string, string>();
        for(tempInteraction__c inter : [SELECT Name, Interaction_Type__c FROM tempinteraction__c WHERE Name IN :FAIds] ){
            interactionmap.put(inter.name, inter.Interaction_Type__c);
        }
        for(Case cs : cases){
            if(cs.RecordTypeId == customerProfileChangeId && cs.Financial_Account__c!=null){
                String interactiontype = interactionmap.get(String.valueOf(cs.Financial_Account__c).left(15));
                if(interactiontype !=null){
                   cs.Service_Type__c = interactiontype;
                }
            }
        }
    }
    // S-311850 #end
    private void findCaseOutcome(List<Case> cases) {

        List<Case> filteredCases = new List<Case>{};
        Set<String> subjects = new Set<String>{ XDEFAULT };
        for(Case c : cases) {
            //find cases that are now resolved but have no related outcome
            if ( c.Status == 'Resolved' && c.CaseOutCome__c == null) {
                subjects.add(c.Subject);
                filteredCases.add(c);
            }
        }

        if (!filteredCases.isEmpty()) {

            //find available and relevant CaseOutComes.  this includes the 'Default' outcome
            Map<string, CaseOutCome__c> caseOutComesMap = new Map<String, CaseOutCome__c>();
            for(CaseOutCome__c coc : [
                select CaseSubject__c, OutComeId__c
                from CaseOutCome__c
                where CaseSubject__c in :subjects
            ]) {
                caseOutComesMap.put(coc.CaseSubject__c, coc);
            }

            if (!caseOutComesMap.isEmpty()) {
                
                for(Case c : filteredCases) {
                    //if there is an outcome by subject
                    if ( caseOutComesMap.containsKey(c.Subject) ) {
                        c.CaseOutCome__c = caseOutComesMap.get(c.Subject).id;
                    } 
                    //else assign the defult outcome if available
                    else if ( caseOutComesMap.containsKey(XDEFAULT) ) {
                        c.CaseOutCome__c = caseOutComesMap.get(XDEFAULT).Id;
                    }

                }

            }

        }

    }
}