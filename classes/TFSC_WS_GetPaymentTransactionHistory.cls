public with sharing class TFSC_WS_GetPaymentTransactionHistory {

	// Request structure for the web service wrapper
	public class PaymentTransactionHistory_RequestParams{
        public String AccountNumber;
        public String AccountType;
        public String Branch;
        public Integer NoOfRecords;
        public String Region;	
	}

	public class PaymentTransactionHistory_ResponseParams{
		
		public PaymentTransactionHistory_ResponseParams() {
			this.StatusParams = new PaymentTransactionHistory_StatusParams(); 
		}
		
		public List <PaymentTransactionHistory_ResponseRecord> ResponseRecordList {get;set;}
		public PaymentTransactionHistory_StatusParams StatusParams {get;set;}
	}
	
	// Response structure for the web service wrapper
	public class PaymentTransactionHistory_ResponseRecord{
        public String AccountNumber{get;set;}
        public String AccoutId{get;set;}
        public String Bank{get;set;}
        public String CustomerNumber{get;set;}
        public String EffectiveDate{get;set;}
        public String Id{get;set;} 
        public Decimal InterestAmount{get;set;}
        public Decimal LateCharge{get;set;}
        public String LeaseBranchNumber{get;set;}
        public Decimal LoanBalanceAmount{get;set;}
        public Decimal MiscellaneousPaymentAmount{get;set;}
        public Decimal PaymentAmount{get;set;}
        public String PaymentTypeCode{get;set;}
        public String PaymentDescription{get;set;}
        public Decimal PrincipleAmount{get;set;}
        public String ProcessedDate{get;set;}
        public String RegionNumber{get;set;}
        public String RetailBranchNumber{get;set;}
        public Decimal TransactionAmount{get;set;}
        public String TransactionDescription{get;set;}
        public String TransactionType{get;set;}
        public String Type_x{get;set;}
	}
	
	public class PaymentTransactionHistory_StatusParams{
		public String Status{get;set;} // SUCCESS or FAIL
		public String Error{get;set;} // Populated only if Status = FAIL
	}

	// Web service invocation
	public static PaymentTransactionHistory_ResponseParams getPaymentTransactionHistory(
	PaymentTransactionHistory_RequestParams requestParams)	{
		// Construct Request
		TFSC_WS_PaymentTransactionHistoryReq.PaymentTransactionHistoryReqSync_element requestDoc = 	constructRequest(requestParams);
		System.debug('***** Constructed Payment Transaction History Request *****');
		
		//Prepare Stub
		TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest stub = getStub();
		stub = setEndPointURL(stub);
		stub = setAuthDetails(stub);	
		System.debug('***** Prepared Stub *****');
		
		// Initialize Response
		PaymentTransactionHistory_ResponseParams responseParams;
		TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResSync_element responseDoc 
		= new TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResSync_element();
		
		System.debug('***** Request - ' + requestDoc + ' *****');
		
		try {
			//Invoke service
			responseDoc.ProcessService = stub.PaymentTransactionHistory(requestDoc.ProcessService);
			System.debug('***** Web Service Invoked Successfully *****');
			System.debug('***** Response - ' + responseDoc + ' *****');
		
			//Parse Response
			responseParams = parseResponse(responseDoc);
			System.debug('***** Parsed Response Successfully *****');
		}
		catch(Exception e) {
			responseParams = new PaymentTransactionHistory_ResponseParams();
			responseParams.StatusParams.Status = 'FAIL';
			System.debug('***** Exception Occured - ' + e + ' *****');
			responseParams.StatusParams.Error = e.getTypeName() + ': ' + e.getMessage();
		}
		
		return responseParams;
	}
	
	private static TFSC_WS_PaymentTransactionHistoryReq.PaymentTransactionHistoryReqSync_element constructRequest(
		PaymentTransactionHistory_RequestParams requestParams) {			
		TFSC_WS_PaymentTransactionHistoryReq.PaymentTransactionHistoryReqSync_element requestDoc = 
		new TFSC_WS_PaymentTransactionHistoryReq.PaymentTransactionHistoryReqSync_element();		
		requestDoc.ProcessService = new TFSC_WS_PaymentTransactionHistoryReq.ProcessService_element();
		
		requestDoc.ProcessService.PaymentTransactionHistoryReqBOD = new TFSC_WS_PaymentTransactionHistoryReq.PaymentTransactionHistoryReqBODType();			
		requestDoc.ProcessService.PaymentTransactionHistoryReqBOD.AccountNumber = requestParams.AccountNumber;
		requestDoc.ProcessService.PaymentTransactionHistoryReqBOD.AccountType = requestParams.AccountType;
		requestDoc.ProcessService.PaymentTransactionHistoryReqBOD.Branch = requestParams.Branch;
		requestDoc.ProcessService.PaymentTransactionHistoryReqBOD.Region = requestParams.Region;
		requestDoc.ProcessService.PaymentTransactionHistoryReqBOD.NoOfRecords = requestParams.NoOfRecords;
		
		requestDoc.ProcessService.ServiceApplicationArea = new TFSC_WS_PaymentTransactionHistoryCommon.ServiceApplicationAreaType();
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
	
	private static TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest setEndPointURL(
	TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest stub){
		//stub.endpoint_x = 'https://intsvcs-tst.services.toyotafinancial.com/TFS/Services/PaymentHistory'; //Label.Payment_Transaction_History_End_Point;
		stub.endpoint_x = Label.Payment_Transaction_History_End_Point;	
		System.debug('***** End Point URL is - ' + stub.endpoint_x + ' *****');
		return stub;
	}
	
	private static TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest getStub() {
		TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest stub = 
			new TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest();
		return stub;	
	}
	
	private static TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest setAuthDetails(
	TFSC_WS_PaymentTransactionHistoryImpl.ReceivePaymentTransactionRequest stub) {				
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
	
	private static PaymentTransactionHistory_ResponseParams parseResponse (TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResSync_element responseDoc) {
        
        //Initialize response params
        PaymentTransactionHistory_ResponseParams responseParams = new PaymentTransactionHistory_ResponseParams();
        List <PaymentTransactionHistory_ResponseRecord> responseRecordList = new List <PaymentTransactionHistory_ResponseRecord>();
        responseParams.StatusParams = new PaymentTransactionHistory_StatusParams();
        responseParams.StatusParams.Status = 'SUCCESS';
        
                
        List <TFSC_WS_PaymentTransactionHistoryResp.TransactionType> transactionList;
        
        System.debug('***** Result Code - ' + responseDoc.ProcessService.ResultBOD.ResultCode + ' *****');
        
        if(responseDoc.ProcessService.ResultBOD.ResultCode != -101) {
        	
        
       		if(responseDoc.ProcessService.PaymentTransactionHistoryResBOD != null && responseDoc.ProcessService.PaymentTransactionHistoryResBOD.ListOfTransactions != null && responseDoc.ProcessService.PaymentTransactionHistoryResBOD.ListOfTransactions.Transaction_x != null) {
        	    transactionList = responseDoc.ProcessService.PaymentTransactionHistoryResBOD.ListOfTransactions.Transaction_x;
            	System.debug('***** Number of Transactions - ' + transactionList.size() + ' *****');
        	}else{
            	System.debug('***** Number of Transactions - empty *****');
        	}
        
        
        	if(transactionList != null) {
            	for(integer i=0; i<transactionList.size(); i++) {
                	// Retrieve individual records
                	TFSC_WS_PaymentTransactionHistoryResp.TransactionType txn = transactionList.get(i);
                	System.debug('***** Parsing record - ' + i + ' *****');
                	PaymentTransactionHistory_ResponseRecord responseRecord = new PaymentTransactionHistory_ResponseRecord();
                
                	//Map individual records
                	responseRecord.AccountNumber = txn.AccountNumber;
                	System.debug('***** AccountNumber - ' + responseRecord.AccountNumber + ' *****');
                	responseRecord.AccoutId = txn.AccoutId;
                	System.debug('***** AccoutId - ' + responseRecord.AccoutId + ' *****');
                	responseRecord.Bank = txn.Bank;
                	System.debug('***** Bank - ' + responseRecord.Bank + ' *****');
                	responseRecord.CustomerNumber = txn.CustomerNumber;
                	System.debug('***** CustomerNumber - ' + responseRecord.CustomerNumber + ' *****');
                	responseRecord.EffectiveDate = txn.EffectiveDate;
                	System.debug('***** EffectiveDate - ' + responseRecord.EffectiveDate + ' *****');
                	responseRecord.Id = txn.Id;
                	System.debug('***** Id - ' + responseRecord.Id + ' *****');
                	responseRecord.InterestAmount = txn.InterestAmount;
                	System.debug('***** InterestAmount - ' + responseRecord.InterestAmount + ' *****');
                	responseRecord.LateCharge = txn.LateCharge;
               		System.debug('***** LateCharge - ' + responseRecord.LateCharge + ' *****');
                	responseRecord.LeaseBranchNumber = txn.LeaseBranchNumber;
                	System.debug('***** LeaseBranchNumber - ' + responseRecord.LeaseBranchNumber + ' *****');
                	responseRecord.LoanBalanceAmount = txn.LoanBalanceAmount;
              		System.debug('***** LoanBalanceAmount - ' + responseRecord.LoanBalanceAmount + ' *****');
                	responseRecord.MiscellaneousPaymentAmount = txn.MiscellaneousPaymentAmount;
                	System.debug('***** MiscellaneousPaymentAmount - ' + responseRecord.MiscellaneousPaymentAmount + ' *****');
                	responseRecord.PaymentAmount = txn.PaymentAmount;
                	System.debug('***** PaymentAmount - ' + responseRecord.PaymentAmount + ' *****');
                	responseRecord.PaymentDescription = txn.PaymentDescription;
                	System.debug('***** PaymentDescription - ' + responseRecord.PaymentDescription + ' *****');
                	responseRecord.PaymentTypeCode = txn.PaymentTypeCode;
                	System.debug('***** PaymentTypeCode - ' + responseRecord.PaymentTypeCode + ' *****');               
                	responseRecord.PrincipleAmount = txn.PrincipleAmount; 
                	System.debug('***** PrincipleAmount - ' + responseRecord.PrincipleAmount + ' *****');
                	responseRecord.ProcessedDate = txn.ProcessedDate;
                	System.debug('***** ProcessedDate - ' + responseRecord.ProcessedDate + ' *****');
                	responseRecord.RegionNumber = txn.RegionNumber;
               		System.debug('***** RegionNumber - ' + responseRecord.RegionNumber + ' *****');
                	responseRecord.RetailBranchNumber = txn.RetailBranchNumber;
                	System.debug('***** RetailBranchNumber - ' + responseRecord.RetailBranchNumber + ' *****');
                	responseRecord.TransactionAmount = txn.TransactionAmount;
                	System.debug('***** TransactionAmount - ' + responseRecord.TransactionAmount + ' *****');
                	responseRecord.TransactionDescription = txn.TransactionDescription;
                	System.debug('***** TransactionDescriptionCode - ' + responseRecord.TransactionDescription + ' *****');
                	responseRecord.TransactionType = txn.TransactionType;
                	System.debug('***** TransactionType - ' + responseRecord.TransactionType + ' *****');
                	responseRecord.Type_x = txn.Type_x;
                	System.debug('***** Type_x - ' + responseRecord.Type_x + ' *****');
                
                	//Add to response list
                	responseRecordList.add(responseRecord);         
            	}
        	}
        
        }
        
        else {
        	responseParams.StatusParams.Status = 'FAIL';
        	responseParams.StatusParams.Error = responseDoc.ProcessService.ResultBOD.ResultCode + ': ' 
        										+ responseDoc.ProcessService.ResultBOD.ResultDesc + ' - '
        										+ responseDoc.ProcessService.ResultBOD.ResultString;
        }
        responseParams.ResponseRecordList = responseRecordList;
        return responseParams;
    }
	
	public static void invokeGetPaymentTransaction() {
		PaymentTransactionHistory_RequestParams requestParams = new PaymentTransactionHistory_RequestParams();
		requestParams.AccountNumber = '0016386098';
		requestParams.AccountType = 'R'; 
		requestParams.NoOfRecords = 2;
		PaymentTransactionHistory_ResponseParams responseParams = getPaymentTransactionHistory(requestParams);
		System.debug(responseParams);
	}
	
	

}