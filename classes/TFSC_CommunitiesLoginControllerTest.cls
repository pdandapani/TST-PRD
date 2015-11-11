@IsTest
public class TFSC_CommunitiesLoginControllerTest {

	@IsTest
	public static void unitTest() {
		TFSC_CommunitiesLoginController controller = new TFSC_CommunitiesLoginController();
		System.AssertNotEquals(null, controller.redirectUrl);
		System.AssertNotEquals(null, controller.redirect());
	}
}