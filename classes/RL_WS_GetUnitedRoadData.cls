global with sharing class RL_WS_GetUnitedRoadData {
	
    public class UR_RequestParams{
        public String VIN;   
    }

    global class UR_ResponseParams{
        
        public UR_ResponseParams() {
            this.StatusParams = new UR_StatusParams(); 
            this.responseRecord = new UR_ResponseRecord();
        }
        
        public UR_ResponseRecord responseRecord {get;set;}
        public UR_StatusParams StatusParams {get;set;}
    }
    
    // Response structure for the web service wrapper
    public class UR_ResponseRecord{
        public String LocationID{get;set;}
        public String LocationName{get;set;}
        public String LocationAdd1{get;set;}
        public String LocationAdd2{get;set;}
        public String LocationCity{get;set;}
        public String LocationState{get;set;}
        public String LocationZIP{get;set;}
        public String LocationPhone{get;set;}
        public String TransportFee{get;set;}
        public String CreatedDate{get;set;}
        public String OrderStatus{get;set;}
    }
    
    public class UR_StatusParams{
        public String Status{get;set;} // SUCCESS or FAIL
        public String Error{get;set;} // Populated only if Status = FAIL
    }

    // Web service invocation
    public static UR_ResponseParams getURdata(UR_RequestParams requestParams)  {
        // Construct Request
        RL_WS_UnitedRoadTransFeesReq.TransportFeesReqSync_element requestDoc =  constructRequest(requestParams);
        
        //Prepare Stub
        RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees stub = getStub();
        stub = setEndPointURL(stub);
        stub = setAuthDetails(stub);
        System.debug('***** Prepared Stub *****');
        
        // Initialize Response
        UR_ResponseParams responseParams;
        RL_WS_UnitedRoadTransFeesResp.TransportFeesResSync_element responseDoc = new RL_WS_UnitedRoadTransFeesResp.TransportFeesResSync_element();
        
        try {
            //Invoke service
            if (!Test.isRunningTest()) {
                responseDoc.ProcessService = stub.TransportFees(requestDoc.ProcessService);
            } 
            System.debug('***** Web Service Invoked Successfully *****');
            System.debug('***** Response - ' + responseDoc + ' *****');
        
            //Parse Response
            responseParams = parseResponse(responseDoc);
            System.debug('***** Parsed Response Successfully *****');
        }
        catch(Exception e) {
            responseParams = new UR_ResponseParams();
            responseParams.StatusParams.Status = 'FAIL';
            System.debug('***** Exception Occured - ' + e + ' *****');
            responseParams.StatusParams.Error = e.getTypeName() + ': ' + e.getMessage();
        }
        
        return responseParams;
    }
    
    private static RL_WS_UnitedRoadTransFeesReq.TransportFeesReqSync_element constructRequest(UR_RequestParams requestParams) {            
        
        RL_WS_UnitedRoadTransFeesReq.TransportFeesReqSync_element requestDoc = new RL_WS_UnitedRoadTransFeesReq.TransportFeesReqSync_element();        
        requestDoc.ProcessService = new RL_WS_UnitedRoadTransFeesReq.ProcessService_element();
        
        requestDoc.ProcessService.TransportFeesReqBOD = new RL_WS_UnitedRoadTransFeesReq.TransportFeesReqBODType();         
        requestDoc.ProcessService.TransportFeesReqBOD.VehicleIdentificationNumber = requestParams.VIN;
        
        requestDoc.ProcessService.ServiceApplicationArea = new RL_WS_UnitedRoadTransFeesCommon.ServiceApplicationAreaType();
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
    
    private static RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees setEndPointURL(
    RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees stub){
        //stub.endpoint_x = 'https://intsvcs-tst.services.toyotafinancial.com/TFS/Services/TransportFees' ;
        stub.endpoint_x = Label.United_Road_Endpoint;
        //to-do... custom label for prod/dev
        return stub;
    }
    
    private static RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees getStub() {
        RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees stub = 
            new RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees();
        return stub;    
    }
    
    private static RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees setAuthDetails(
    RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees stub) {              
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
    
    public static UR_ResponseParams parseResponse(RL_WS_UnitedRoadTransFeesResp.TransportFeesResSync_element responseDoc) {
        
        //Initialize response params
        UR_ResponseParams responseToReturn = new UR_ResponseParams();
        responseToReturn.StatusParams = new UR_StatusParams();
        responseToReturn.StatusParams.Status = 'SUCCESS';
        
        RL_WS_UnitedRoadTransFeesResp.GetVINInfoResponseType vinInfoResponse;
        
        System.debug('***** Result Code - ' + responseDoc.ProcessService.ResultBOD.ResultCode + ' *****');
        
        
        if(responseDoc.ProcessService.ResultBOD.ResultCode != -101) {
            
        
            if(responseDoc.ProcessService.TransportFeesResBOD != null && responseDoc.ProcessService.TransportFeesResBOD.GetVINInfoResponse != null) {
                vinInfoResponse = responseDoc.ProcessService.TransportFeesResBOD.GetVINInfoResponse;
                System.debug('***** xx vin info set *****');
                System.debug('***** vinInfoResponse = ' + vinInfoResponse);
            }else{
                System.debug('***** xx TransportFees - empty *****');
            }
        
        
            if(vinInfoResponse != null) {
                responseToReturn.responseRecord.LocationID = vinInfoResponse.LocationID;
                System.debug('***** vinInfoResponse locationId ' + vinInfoResponse.LocationID + '*****');
                responseToReturn.responseRecord.LocationName = vinInfoResponse.LocationName;
                System.debug('***** vinInfoResponse locationName ' + vinInfoResponse.LocationName + '*****');
                responseToReturn.responseRecord.LocationAdd1 = vinInfoResponse.LocationAdd1;
                System.debug('***** vinInfoResponse locationAdd1' + vinInfoResponse.LocationAdd1 + '*****');
                responseToReturn.responseRecord.LocationAdd2 = vinInfoResponse.LocationAdd2;
                responseToReturn.responseRecord.LocationCity = vinInfoResponse.LocationCity;
                responseToReturn.responseRecord.LocationState = vinInfoResponse.LocationState;
                responseToReturn.responseRecord.LocationZIP = vinInfoResponse.LocationZIP;
                responseToReturn.responseRecord.LocationPhone = vinInfoResponse.LocationPhone;
                responseToReturn.responseRecord.TransportFee = vinInfoResponse.TransportFee;
                responseToReturn.responseRecord.CreatedDate = vinInfoResponse.CreatedDate;
                responseToReturn.responseRecord.OrderStatus = vinInfoResponse.OrderStatus;
            }
        
        }
        
        else {
            responseToReturn.StatusParams.Status = 'FAIL';
            responseToReturn.StatusParams.Error = responseDoc.ProcessService.ResultBOD.ResultCode + ': ' 
                                                + responseDoc.ProcessService.ResultBOD.ResultDesc + ' - '
                                                + responseDoc.ProcessService.ResultBOD.ResultString;
        }
        
        
        return responseToReturn;
    }
    
    public static void testInvocation() {
        UR_RequestParams requestParams = new UR_RequestParams();
        requestParams.VIN = 'JT3HN86R629072882';
        UR_ResponseParams responseParams = getURdata(requestParams);
        System.debug(responseParams);
    }
    

}