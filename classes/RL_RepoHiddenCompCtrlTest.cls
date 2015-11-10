@isTest
private class RL_RepoHiddenCompCtrlTest {
	
	
    static testmethod void testControllerInitAndActionFunction() {
                
        Financial_Account__c financialAccount = new Financial_Account__c(
                                                            Financial_Account_Number__c = '400921', 
                                                            Finance_Account_Status__c = 'Open');
        insert financialAccount;
        
        Case rlCase = generateAndInsertCase(financialAccount.Id);
        
        Repossession__c repo = generateAndInsertRepo(rlCase);
        
        repo = [select id, Proposed_Notice_Date__c, Case__r.RL_System_Required_Notice_Date_Time__c,
                    State_of_Jurisdiction__c, Case__r.BusinessHoursId, Financial_Account__r.RecordType.Name,
                    Case__c, Proposed_Notice_Date_Override__c, Case__r.Form_Rule__c, Case__r.Form_Rule__r.Certified__c 
                 from Repossession__c where id = :repo.Id]; //doing this to get values populated via page layout.        

        PageReference pageRef = Page.RL_RepoHiddenComponent;
        //RL_TakeOwnershipPassThru?cs1={id1}&cs2={id2}
            
        ApexPages.StandardController standardController = new ApexPages.StandardController(repo);
        RL_RepoHiddenComponentController ctrl = new RL_RepoHiddenComponentController(standardController);
        
        User testUser = TFSC_TestUtils.generateTestUser(RL_Constants.RL_AGENT_PROFILE_NAME, true);        
        System.RunAs(testUser)
        {
            Test.setCurrentPage(pageRef);

            system.assert(ctrl.errorStringOnUpdate == null || ctrl.errorStringOnUpdate == '');
            system.assert(ctrl.businessHrs != null);
            
            ctrl.updateProposedStartDate();
        }
    }
    
    
    private static Case generateAndInsertCase(Id financialAccountId) {
        Id recordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Rights_Letter_on_case', 'Case');
        System.debug(recordTypeId);
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        
        Case caseToInsert = new Case( Financial_Account__c = financialAccountId,
                                      BusinessHours = bhs,
                                      RecordTypeId = recordTypeId );
        
        insert caseToInsert;
        return caseToInsert;
    }
    
    
    private static Repossession__c generateAndInsertRepo(Case rlCase) {
    	
    	Repossession__c repo = new Repossession__c();
    	repo.Case__c = rlCase.Id;
    	
    	
    	insert repo;
    	return repo;
    }
    
    
    
}