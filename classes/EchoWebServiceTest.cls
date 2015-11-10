@IsTest
public class EchoWebServiceTest {

	@IsTest
	public static void UnitTest() {
		string msg = 'Hello World';
		System.assertEquals(msg, EchoWebService.post(msg));
	}
}