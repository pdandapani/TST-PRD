public class KmServerLogModel {

	public String serverLog{
		get {
			return readServerLog('http://bl90292.diskstation.me:8080/SFDCweblinkKM/kmServerLog');
		}
	}

	//KmServerLogModel.testReadServerLog();
	public static void testReadServerLog() {
		String serverLog = readServerLog('http://bl90292.diskstation.me:8080/SFDCweblinkKM/kmServerLog');
		System.debug(serverLog);
	}

	public static String readServerLog(String serverLogUrl) {
		Http h = new Http();
	
		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
		HttpRequest req = new HttpRequest();
		req.setEndpoint(serverLogUrl);
		req.setMethod('GET');
		
		HttpResponse res = h.send(req);
		return res.getBody();
	}

}