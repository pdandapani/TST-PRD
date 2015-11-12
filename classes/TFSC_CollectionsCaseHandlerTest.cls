@isTest
private class TFSC_CollectionsCaseHandlerTest {

	// NOTE: This test class is rendered invalid as the only test case validated
	// no longer applies. Please see notes in body of test method for details. 
	// Prakash Dandapani, 14-Jul-2015
	/*
	static String testFAId = null;
	static String testFARecourseCode = null;
	static String testFACId = null;

	private static void setupTestFA(){

		Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
		Financial_Account__c testFA = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct);
		Financial_Account_Customer__c testFAC = TFSC_TestUtils.setupAndReturnFAC(testFA, acct, 'Primary');

		testFAId = testFA.Id;
		testFACId = testFAC.Id;
		testFARecourseCode = testFA.Collection_Recourse_Code__c;
		System.debug('*************** testFAId: ' + testFAId);

	}
	*/

	static testMethod void 	testCollectionsCase(){

		// NOTE: Performance enhancements to improve ETL job execution time.    
		// The following section of code commented because Collection_Recourse_Code__c
		// is no longer synced up to FA via. trigger. 
		// Instead this field is populated by ETL directly both to FA and Case object. 
		// Since collections cases are primarily readonly in SFDC as agents do not edit 
		// cases sourced from collection host, Collection_Recourse_Code__c values 
		// are pushed by source system (Collection host) it is ideal to get this data pushed via. ETL
		// Also it was observed that synchronously populating this attribute to FA via. Case trigger is 
		// blocking and impacts performance of ETL jobs pushing Cases, especially when dealing with
		// closed cases. 
		// Prakash Dandapani, 14-Jul-2015
		/* 
		String caseRecTypeId = RecordTypeModel.LookupRecordTypeId('Case', 'Collection');

		System.debug('****************** Collection rec type ID: ' + caseRecTypeId);

		setupTestFA();

		Case testCase = new Case(
							Status = 'New',
							Collection_Recourse_Code__c = 'N',
							RecordTypeId = caseRecTypeId,
							Financial_Account__c = testFAId,
							Financial_Account_Customer__c = testFACId
							);

		Test.startTest();
		insert testCase;
		Test.stopTest();

		System.debug('************** Case ID:' + testCase.Id + ' ~ Case Record Type: ' + testCase.RecordTypeId);

		testFARecourseCode = [SELECT Collection_Recourse_Code__c FROM Financial_Account__c WHERE Id = :testFAId LIMIT 1].Collection_Recourse_Code__c;

		System.debug('*************** testFARecourseCode: ' + testFARecourseCode);

		System.assertEquals(testFARecourseCode,testCase.Collection_Recourse_Code__c);
		*/
		
	}

}