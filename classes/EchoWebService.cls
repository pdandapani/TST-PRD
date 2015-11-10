@RestResource(urlMapping='/EchoWebService/v1/*')
global class EchoWebService {

 
 	//Sample parameter to invoke from postman
 	/*
	{
		"echo" : "what"
	}
	*/
	@httpPost
	global Static string post (string echo) {
		
		String msg = 'EchoWebService : '+ echo;
		System.Debug(msg);

		return echo;
	} 
}


/*

	@IsTest
	public static void EchoWebServiceTest() {
		string msg = 'Hello World';
		System.assertEquals(msg, EchoWebService.post(msg));
	}


*/