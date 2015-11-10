@isTest
private class RL_NewRightsLetterControllerTest {
    
    @isTest static void test_method_one() {
        
        // Ensure page loads properly
        PageReference pageRef = Page.RL_NewRightsLetter;
        Test.setCurrentPage(pageRef);

        // Setup controller test with Case standard controller and page extension
        Case blankCase = new Case();
        ApexPages.StandardController caseStdController = new ApexPages.StandardController(blankCase);
        RL_NewRightsLetterController controller = new RL_NewRightsLetterController(caseStdController);

        // Invoke the RL case creation
        controller.createRightsLetter();

        // Verify case is created
        Id createdCaseId = controller.newCaseId;
        Case[] cases = [select Id from Case where Id = :createdCaseId];
        System.assertEquals(createdCaseId, cases[0].Id);
        
        // Verify the associated repo is created
        Repossession__c[] repos = [select Id from Repossession__c where Case__c = :createdCaseId];
        System.assertEquals(repos.size(), 1);
    }
}