@isTest(SeeAllData=false)
private class TFSC_WebToCaseHandlerTest {
	
	@isTest static void test_method_one() {

		//no longer needed
		//create dummy person, and update custom setting to point to test user
		//Account dummy = TFSC_TestUtils.setupAndReturnNewAccount();
		//insert new WebToCase_Settings__c(
		//	Dummy_PersonId__c = dummy.Id,
		//	SetupOwnerId = UserInfo.getOrganizationId() //set as the default setting
		//);

		Id web2CaseId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Web-To-Case').getRecordTypeId();

		//create a case with an origin of 'Web'
		Case webToCase1 = new Case(
			RecordTypeId = web2CaseId,
			Status = 'New'
		);
		insert webToCase1;

		Case webToCase2 = new Case(
			RecordTypeId = web2CaseId,
			Status = 'New'
		);
		insert webToCase2;

		//assert that the case has been associated with the dummy person account
		//webToCase = [select Id, AccountId from Case where Id = :webToCase.Id];
		//System.assertEquals(webToCase.AccountId, dummy.Id);

	}
	
}