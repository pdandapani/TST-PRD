@isTest(SeeAllData=false)
private class TouchCaseController_Test {
	
	static testMethod void test_TouchCase() {

		Case testCase = new Case(
			RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Base Service Request').getRecordTypeId(),
			Status = 'New'
		);
		insert testCase;

		PageReference pr = Page.TouchCase;
		pr.getParameters().put('id', testCase.Id);
		System.Test.setCurrentPage(pr);

		TouchCaseController con = new TouchCaseController(new ApexPages.StandardController(testCase));
		con.touchCase();

		List<Case_LastViewed__c> views = new List<Case_LastViewed__c>([
			select Id, Has_Viewed__c from Case_LastViewed__c 
			where Case__c = :testCase.Id
			and User__c = :UserInfo.getUserId()
		]);
		System.assertEquals(views.isEmpty(), false);
		System.assertEquals(views.size(), 1);
		System.assertEquals(views[0].Has_Viewed__c, true);

	}

}