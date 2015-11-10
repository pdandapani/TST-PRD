@isTest
private class RL_TakeOwnershipPassCtrlTest {
    
    
    static testmethod void testControllerWithMultipleCasesForTestUser() {
        
        User testUser = TFSC_TestUtils.generateTestUser('Collections', true);
        
        Financial_Account__c financialAccount = new Financial_Account__c(
                                                            Financial_Account_Number__c = '400921', 
                                                            Finance_Account_Status__c = 'Open');
        insert financialAccount;
        
        Integer numOfCaseRecords = 10;
        List<Case> caseList = generateAndInsert10RLCases(financialAccount.Id, numOfCaseRecords);
        
        
        //System.RunAs(testUser) {
        
        PageReference pageRef = Page.RL_TakeOwnershipPassThru;
        Test.setCurrentPage(pageRef);
        //RL_TakeOwnershipPassThru?cs1={id1}&cs2={id2}
        for(Integer i=1; i<numOfCaseRecords; i++){
            //set cs (case) parameters;
            Id curCaseId = caseList[i-1].Id;
            system.debug('***** curCaseId =' + curCaseId);
            ApexPages.currentPage().getParameters().put('cs' + String.valueOf(i), String.valueOf(curCaseId));
        }
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(caseList[0]);
        RL_TakeOwnershipPassThruController ctrl = new RL_TakeOwnershipPassThruController(standardController);
        ctrl.isInConsole = false;
        ctrl.previousPage = '/';
        
        ctrl.redir();
        
        System.assert( ctrl.currentUserId != null );
        
    }
    
    
    static testmethod void testControllerWithSingleCase() {
        
        
        Financial_Account__c financialAccount = new Financial_Account__c(
                                                            Financial_Account_Number__c = '400921', 
                                                            Finance_Account_Status__c = 'Open');
        insert financialAccount;
        
        Id recordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Rights_Letter_on_case', 'Case');
        Case curCase = generateAndReturnCase(financialAccount.Id, recordTypeId);
        insert curCase;
        
        PageReference pageRef = Page.RL_TakeOwnershipPassThru;
        Test.setCurrentPage(pageRef);
        //RL_TakeOwnershipPassThru?cs1={id1}&cs2={id2}
        ApexPages.currentPage().getParameters().put('id', String.valueOf(curCase.Id));
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(curCase);
        RL_TakeOwnershipPassThruController ctrl = new RL_TakeOwnershipPassThruController(standardController);
        ctrl.isInConsole = true;
        
        ctrl.redir();
        
        //also, test for failure where another user owns record.
        User testUser = TFSC_TestUtils.generateTestUser('Administrative Agent', true);
        curCase.ownerId = testUser.Id;
        update curCase;
        
    	ApexPages.currentPage().getParameters().put('id', String.valueOf(curCase.Id));
        standardController = new ApexPages.StandardController(curCase);
        ctrl = new RL_TakeOwnershipPassThruController(standardController);
        ctrl.isInConsole = true;
        
        ctrl.redir();
        
    }
    
    static testmethod void testControllerWithTwoCasesWhereOneFailsAndTheOtherSucceeds() {
        
        
        Financial_Account__c financialAccount = new Financial_Account__c(
                                                            Financial_Account_Number__c = '400921', 
                                                            Finance_Account_Status__c = 'Open');
        insert financialAccount;
        
        Id recordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Rights_Letter_on_case', 'Case');
        Case curCase = generateAndReturnCase(financialAccount.Id, recordTypeId);
        insert curCase;
        
        PageReference pageRef = Page.RL_TakeOwnershipPassThru;
        Test.setCurrentPage(pageRef);
        //RL_TakeOwnershipPassThru?cs1={id1}&cs2={id2}
        ApexPages.currentPage().getParameters().put('id', String.valueOf(curCase.Id));
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(curCase);
        RL_TakeOwnershipPassThruController ctrl = new RL_TakeOwnershipPassThruController(standardController);
        ctrl.isInConsole = true;
        
        ctrl.redir();
        
        User testUser = TFSC_TestUtils.generateTestUser('Administrative Agent', true);
        curCase.ownerId = testUser.Id;
        update curCase;
        Case case2 = generateAndReturnCase(financialAccount.Id, recordTypeId);
        insert case2;
        
        ApexPages.currentPage().getParameters().put('cs1', String.valueOf(curCase.Id));
        ApexPages.currentPage().getParameters().put('cs2', String.valueOf(case2.Id));
        standardController = new ApexPages.StandardController(curCase);
        ctrl = new RL_TakeOwnershipPassThruController(standardController);
        ctrl.isInConsole = true;
        
        ctrl.redir();
        
    }
    
    
    private static List<Case> generateAndInsert10RLCases(Id financialAccountId, Integer numOfRecords) {
    	List<Case> caseListToReturn = new List<Case>();
    	//TO DO... FIGURE OUT CASE RECORD TYPE
    	Id recordTypeId = TFSC_Utils.getRecordTypeIdFromDeveloperNameAndsObjectName('Rights_Letter_on_case', 'Case');
    	
    	for(Integer i=1; i<numOfRecords; i++){
    		Case caseToInsert = generateAndReturnCase(financialAccountId, recordTypeId );
            caseListToReturn.add(caseToInsert);
    	}
    	
    	insert caseListToReturn;
    	return caseListToReturn;
    }
    
    private static Case generateAndReturnCase(Id financialAccountId, Id recordTypeId) {
        Case caseToReturn = new Case( Financial_Account__c = financialAccountId,
                                          RecordTypeId = recordTypeId );
        return caseToReturn;
    }
    
    
    
}