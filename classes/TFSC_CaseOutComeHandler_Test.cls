@isTest(SeeAllData=false)
private class TFSC_CaseOutComeHandler_Test {
    
    @isTest
    private static void test_resolvedCase() {
        //setup the test data
        TFSC_TestUtility test = new TFSC_TestUtility();
        System.runAs(test.testAdmin) {

            Case resolvedCase = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support Request').getRecordTypeId(),
                Subject = 'Subject',
                Status = 'Resolved',
                Closed_Disposition__c = 'Text'
            );
            insert resolvedCase;

            resolvedCase = [select Id, CaseOutCome__c from Case where Id = :resolvedCase.Id];
            System.assertEquals(resolvedCase.CaseOutCome__c, test.caseOutcomes[0].Id);

        }

    }
    
    @isTest
    private static void test_resolvedCase_Default() {
        //setup the test data
        TFSC_TestUtility test = new TFSC_TestUtility();
        System.runAs(test.testAdmin) {

            Case resolvedCase = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support Request').getRecordTypeId(),
                Subject = '',
                Status = 'Resolved',
                Closed_Disposition__c = 'Text'
            );
            insert resolvedCase;

            resolvedCase = [select Id, CaseOutCome__c from Case where Id = :resolvedCase.Id];
            System.assertEquals(resolvedCase.CaseOutCome__c, test.caseOutcomes[1].Id);

        }

    }
    // Test class added to cover changes for S-311850 by Paras Dhingra 7/10/2015 #Start
    @isTest
    private static void test_profileChangeCase(){
        //create test data
        TFSC_TestUtility test = new TFSC_TestUtility();

        System.runAs(test.testAdmin) {
            tempInteraction__c interaction  = new tempInteraction__c(name = String.valueOf(test.finAcct.id).left(15), Interaction_Type__c = 'inbound call');
            insert interaction;
            Case changeProfileCase = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Customer Profile Change').getRecordTypeId(),
                Subject = '',
                Status = 'Resolved',
                Closed_Disposition__c = 'Text',
                Financial_Account__c = test.finAcct.id
                );
            insert changeProfileCase;
        }
    }
    //S-311850 #End

}