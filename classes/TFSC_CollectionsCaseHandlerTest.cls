@isTest
private class TFSC_CollectionsCaseHandlerTest {
	
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


	static testMethod void 	testCollectionsCase(){

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

	}

}