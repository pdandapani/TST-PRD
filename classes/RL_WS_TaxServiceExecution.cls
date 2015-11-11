global with sharing class RL_WS_TaxServiceExecution {

	// Request structure for the web service wrapper
	public class TaxService_RequestParams{
        public String RequestID;
        public Decimal SalesPriceAmount;
        public Date SalesTaxDate;
        public String StateCode;
        public String ZipCode;
	}

	global class TaxService_ResponseParams{
		
		public TaxService_ResponseParams() {
			this.StatusParams = new TaxService_StatusParams(); 
		}
		
		public TaxService_ResponseRecord responseRecord {get;set;}
		public TaxService_StatusParams StatusParams {get;set;}
	}
	
	// Response structure for the web service wrapper
	public class TaxService_ResponseRecord{
        public Decimal TotalAmount;
        public Decimal TotalTax;
	}
	
	public class TaxService_StatusParams{
		public String Status{get;set;} // SUCCESS or FAIL
		public String Error{get;set;} // Populated only if Status = FAIL
	}

	// Web service invocation
	public static TaxService_ResponseParams getTaxRateData(TaxService_RequestParams requestParams)	{
		// Construct Request
		RL_WS_TaxService_Req.TaxServiceReqSync_element requestDoc = 	constructRequest(requestParams);
		System.debug('***** Constructed Request *****');
		
		//Prepare Stub
		RL_WS_TaxService_Impl.ReceiveTaxRequest stub = getStub();
		
		// Initialize Response
		TaxService_ResponseParams responseParams;
		RL_WS_TaxService_Resp.TaxServiceResSync_element responseDoc = new RL_WS_TaxService_Resp.TaxServiceResSync_element();
		
		System.debug('***** Request - ' + requestDoc + ' *****');
		
		try {
			//Invoke service
			responseDoc.ProcessService = stub.GetTax(requestDoc.ProcessService);
			System.debug('***** Web Service Invoked Successfully *****');
			System.debug('***** Response - ' + responseDoc + ' *****');
		
			//Parse Response
			responseParams = parseResponse(responseDoc);
			System.debug('***** Parsed Response Successfully *****');
		}
		catch(Exception e) {
			responseParams = new TaxService_ResponseParams();
			responseParams.StatusParams.Status = 'FAIL';
			System.debug('***** Exception Occured - ' + e + ' *****');
			responseParams.StatusParams.Error = e.getTypeName() + ': ' + e.getMessage();
		}
		
		return responseParams;
	}
	
	private static RL_WS_TaxService_Req.TaxServiceReqSync_element constructRequest(TaxService_RequestParams requestParams) {			
		RL_WS_TaxService_Req.TaxServiceReqSync_element requestDoc = new RL_WS_TaxService_Req.TaxServiceReqSync_element();		
		requestDoc.ProcessService = new RL_WS_TaxService_Req.ProcessService_element();
		
		requestDoc.ProcessService.TaxServiceOReqBOD = new RL_WS_TaxService_Req.TaxServiceOReqBODType();			
		requestDoc.ProcessService.TaxServiceOReqBOD.RequestID 			= requestParams.RequestID;
		requestDoc.ProcessService.TaxServiceOReqBOD.SalesPriceAmount	= requestParams.SalesPriceAmount;
		requestDoc.ProcessService.TaxServiceOReqBOD.SalesTaxDate 		= requestParams.SalesTaxDate;
		requestDoc.ProcessService.TaxServiceOReqBOD.StateCode 			= requestParams.StateCode;
		requestDoc.ProcessService.TaxServiceOReqBOD.ZipCode 			= requestParams.ZipCode;
		
		requestDoc.ProcessService.ServiceApplicationArea = new RL_WS_TaxService_Common.ServiceApplicationAreaType();
		requestDoc.ProcessService.ServiceApplicationArea.ConversationID = TFSC_Utils.getGUID();
		requestDoc.ProcessService.ServiceApplicationArea.MessageType = 'REQ';
		requestDoc.ProcessService.ServiceApplicationArea.Mode = null;
		requestDoc.ProcessService.ServiceApplicationArea.RefToSequenceNo = null;
		requestDoc.ProcessService.ServiceApplicationArea.SenderID = null;
		requestDoc.ProcessService.ServiceApplicationArea.SentTimeStamp = Datetime.valueOf(datetime.now());
		requestDoc.ProcessService.ServiceApplicationArea.SequenceNo = null;
		requestDoc.ProcessService.ServiceApplicationArea.ServiceType = null;
		requestDoc.ProcessService.ServiceApplicationArea.TargetID = null;
		requestDoc.ProcessService.ServiceApplicationArea.VersionNo = null;		
		
		return requestDoc;		
	}
	
	private static RL_WS_TaxService_Impl.ReceiveTaxRequest setEndPointURL(RL_WS_TaxService_Impl.ReceiveTaxRequest stub){
		stub.endpoint_x = Label.Tax_Service_Endpoint;
		//stub.endpoint_x = 'https://intsvcs-tst.services.toyotafinancial.com/TFS/Services/TaxService';
		//stub.endpoint_x = 'https://intsvcs-stg.services.toyotafinancial.com/TFS/Services/TaxService';	
		return stub;
	}
	
	private static RL_WS_TaxService_Impl.ReceiveTaxRequest getStub() {
		RL_WS_TaxService_Impl.ReceiveTaxRequest stub = 
			new RL_WS_TaxService_Impl.ReceiveTaxRequest();
		
		stub = setEndPointURL(stub);
		stub = setAuthDetails(stub);	
		
		return stub;	
	}
	
	private static RL_WS_TaxService_Impl.ReceiveTaxRequest setAuthDetails(RL_WS_TaxService_Impl.ReceiveTaxRequest stub) {				
			String username;
			String password;
			String authCred;
			Map<String,String> inputHttpHeaders_x = new Map<String,String>();
			stub.inputHttpHeaders_x = inputHttpHeaders_x;
			username = System.UserInfo.getOrganizationId();
			password = username;			
			System.debug(username + ':' + password);
			Blob authCredBlob = Blob.valueOf(username + ':' + password);
        	authCred = EncodingUtil.base64Encode(authCredBlob);
			stub.inputHttpHeaders_x.put('Authorization', 'Basic '+authCred);
			return stub;		
	}
	
	private static TaxService_ResponseParams parseResponse(RL_WS_TaxService_Resp.TaxServiceResSync_element responseDoc) {
        
        //Initialize response params
        TaxService_ResponseParams responseParams = new TaxService_ResponseParams();
        TaxService_ResponseRecord responseRecord = new TaxService_ResponseRecord();
        responseParams.StatusParams = new TaxService_StatusParams();
        responseParams.StatusParams.Status = 'SUCCESS';
        
        
        //System.debug('***** Result Code - ' + responseDoc.ProcessService.ResultBOD.ResultCode + ' *****');
        
        if(responseDoc.ProcessService.ResultBOD.ResultCode != -101) {
        	
       		if(responseDoc.ProcessService.TaxServiceResBOD != null) {
        	    responseRecord.TotalTax = responseDoc.ProcessService.TaxServiceResBOD.TotalTax;
        	    responseRecord.TotalAmount = responseDoc.ProcessService.TaxServiceResBOD.TotalAmount;
        	}else{
            	System.debug('***** bod null *****');
        	}
        
        
        }
        
        else {
        	responseParams.StatusParams.Status = 'FAIL';
        	responseParams.StatusParams.Error = responseDoc.ProcessService.ResultBOD.ResultCode + ': ' 
        										+ responseDoc.ProcessService.ResultBOD.ResultDesc + ' - '
        										+ responseDoc.ProcessService.ResultBOD.ResultString;
        }
        responseParams.responseRecord = responseRecord;
        return responseParams;
    }
	
	public static TaxService_ResponseParams testService() {
		TaxService_RequestParams request = new TaxService_RequestParams();
		request.RequestID = TFSC_Utils.getGUID();
        request.SalesPriceAmount = 1000;
        request.SalesTaxDate = Date.today();
        request.StateCode = 'CO';
        request.ZipCode = '80526-2725';
        
        TaxService_ResponseParams response = getTaxRateData(request);
        return response;
	}
	
	

}