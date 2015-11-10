/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TFSC_TaskTriggerHandlerTest {
	
	static String testFAId = null;
	static String testFARecourseCode = null;
	static String testFACId = null;
	static String testFAName = null;	
	static String testFAId2 = null;
	static String testFACId2 = null;
	static String testFAName2 = null;
	
	private static void setupTestData(){

		Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
		Financial_Account__c testFA = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct);
		Financial_Account_Customer__c testFAC = TFSC_TestUtils.setupAndReturnFAC(testFA, acct, 'Primary');
		
		Account acct2 = TFSC_TestUtils.setupAndReturnNewAccount();
		Financial_Account__c testFA2 = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct2);
		Financial_Account_Customer__c testFAC2 = TFSC_TestUtils.setupAndReturnFAC(testFA2, acct2, 'Primary');
		
		
		testFAId = testFA.Id;
		testFACId = testFAC.Id;
		testFAName = testFA.Name;
		testFARecourseCode = testFA.Collection_Recourse_Code__c;
		
		testFAId2 = testFA2.Id;
		testFACId2 = testFAC2.Id;
		testFAName2 = testFA2.Name;
		
		System.debug('*************** testFAId: ' + testFAId);

	}

    static testMethod void testTaskTriggerHandler() {
    	
    	setupTestData();
    	Integer i = 0;
    	List<Task> testTasks = new List<Task>();
    	
    	while(i < 100){
    		
    		Task testTask = new Task(Priority = 'Normal',
								Status = 'Completed', 
								Description = 'Testing Cure note info', 
								Financial_Account__c = testFAId,
								Collection_Activity_Code__c = 'CURE',
								ActivityDate = Date.Today(),
								Financial_Account_Number__c = testFAName,
								Source_System_Created_By__c = 'SFDC',
								Subject = 'Test',
								WhatId = TestFAId);
								
		   testTasks.add(testTask);
		   
		   i++;
    		
    	}
    	
    	i = 0;
    	while(i < 100){
    		
    		Task testTask = new Task(Priority = 'Normal',
								Status = 'Completed', 
								Description = 'Testing Cure note info', 
								Financial_Account__c = testFAId2,
								Collection_Activity_Code__c = 'CURE',
								ActivityDate = Date.Today(),
								Financial_Account_Number__c = testFAName2,
								Source_System_Created_By__c = 'SFDC',
								Subject = 'Test',
								WhatId = testFAId2);
								
		   testTasks.add(testTask);
		   
		   i++;
    		
    	}
		    	
        Test.startTest();
        insert testTasks;
        Test.stopTest();
        
        String faCureInfo = [SELECT Id, Most_Recent_Cure_Note__c FROM Financial_Account__c WHERE Id = :testFAId LIMIT 1].Most_Recent_Cure_Note__c;
        String taskCureInfo = 'Testing Cure note info';
        
        //Assert has been commented out since the trigger has been deactivated - C. Barbour 4/9/15
        //System.assertEquals(faCureInfo,taskCureInfo);
        
    }
}