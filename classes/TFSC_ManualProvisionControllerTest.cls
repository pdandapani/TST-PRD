@isTest
public class TFSC_ManualProvisionControllerTest {
	@isTest
	private static void TestControllerMethods() {
		TFSC_manualProvisionController controller = new TFSC_manualProvisionController();
		
		controller.SGUID = 'mock';
		controller.AccountNumber = 'mock';
		controller.BorrowerPosition = 'mock';
		controller.ManagementEmail = 'mock';
		
		//cycle through methods, which are independently covered elsewhere
		controller.doProvisionWebAccount();
		System.AssertEquals('-1',controller.resultCode);
		
		controller.doRegisterWebAccountToFinancialAccountCustomer();
		System.AssertEquals('-1',controller.resultCode);
		
		controller.doUnRegisterWebAccountToFinancialAccountCustomer();
		System.AssertEquals('-1',controller.resultCode);
		
		controller.doDeProvisionWebAccount();
		System.AssertEquals('-1',controller.resultCode);
		
		controller.doChangeWebAccountProfile();
		System.AssertEquals('-1',controller.resultCode);
		
		controller.doUnReadMessageCountSinceLastLogin();
		System.AssertEquals('-1',controller.resultCode);
	}
}