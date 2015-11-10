@isTest(SeeAllData=false)
private class PreformCaseController_Test {
	
	static testMethod void test_PreformCaseController2() {
		//setup the test data
		TFSC_TestUtility test = new TFSC_TestUtility();
		System.runAs(test.testAdmin) { //not a community user

			PageReference pr = Page.TFSC_PreformDueDateChangeRequest;
			pr.getParameters().put('id', test.finAcctCust.Id);
			System.test.setCurrentPage(pr);

			TFSC_PreformCaseController con = new TFSC_PreformCaseController(
				new ApexPages.StandardSetController(new List<Case> {})
			);

			PageReference preform = con.preformCase();
			
			//required fields not yet set. cover error criteria
			PageReference preformShellError = con.preformCaseWithNewContact();
			
			//set required fields and re-execute to preform with shell case contact created.
			con.NewShellCaseContact.FirstName = 'mock';
			con.NewShellCaseContact.LastName = 'mock';
			con.NewShellCaseContact.Email = 'mock@test.com';
			PageReference preformShell = con.preformCaseWithNewContact();

		}

	}
	
}