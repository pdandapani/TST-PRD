global class WebLoginWebServiceReply {
	public String resultCode;
	public String message;
	
	global WebLoginWebServiceReply(){
		this.resultCode = '';
		this.message = '';
	}
	
	global WebLoginWebServiceReply(String resultCode, String message) {
		this.resultCode = resultCode;
		this.message = message;
		
		System.Debug('WebLoginWebServiceReply '+resultCode+' '+message);
	}
	
	global WebLoginWebServiceReply(integer resultCount, String message) {
		this.resultCode = String.ValueOf(resultCount);
		this.message = message;
		
		System.Debug('WebLoginWebServiceReply '+resultCode+' '+message);
	}
}