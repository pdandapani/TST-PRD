@isTest
private class RL_WS_UnitedRoad_TaxService_Test {
    
    @isTest static void test_method_one() {
        new RL_WS_UnitedRoadTransFeesCommon.ServiceApplicationAreaType();

        //new RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees.TransportFees();
        new RL_WS_UnitedRoadTransFeesReq.TransportFeesReqSync_element();
        new RL_WS_UnitedRoadTransFeesReq.TransportFeesReqBODType();
        RL_WS_UnitedRoadTransFeesReq.ProcessService_element processService = new RL_WS_UnitedRoadTransFeesReq.ProcessService_element();
        RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees receiveFees = new RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees();
        //receiveFees.transportFees(processService);
        new RL_WS_UnitedRoadTransFeesResp.GetVINInfoResponseType();
        new RL_WS_UnitedRoadTransFeesResp.TransportFeesResBODType();
        new RL_WS_UnitedRoadTransFeesResp.TransportFeesResSync_element();
        new RL_WS_UnitedRoadTransFeesResp.ProcessService_element();
        new RL_WS_UnitedRoadTransFeesResultBod.ResultBODType();
        new RL_WS_TaxService_ResultBod.ResultBODType();
        new RL_WS_TaxService_Resp.TaxServiceResSync_element();
        new RL_WS_TaxService_Resp.TaxServiceOResponseType();
        new RL_WS_TaxService_Resp.TaxServiceOReqBODType();
        new RL_WS_TaxService_Resp.ProcessService_element();
        RL_WS_GetUnitedRoadData.UR_RequestParams params = new RL_WS_GetUnitedRoadData.UR_RequestParams();
        RL_WS_GetUnitedRoadData.getURdata(params);
        RL_WS_GetUnitedRoadData.testInvocation();
        Test.setMock(HttpCalloutMock.class, new RL_MockHttpResponseGenerator());
        RL_WS_GenerateDocument.testHttpRequest();
        
    }
    
    
    
    @isTest 
    static void testDataHandler() {
		
		Test.startTest();
		
		RL_WS_UnitedRoadTransFeesResp.TransportFeesResSync_element responseDoc;
		
		RL_WS_UnitedRoadTransFeesResultBod.ResultBODType resBod;
		resBod = new RL_WS_UnitedRoadTransFeesResultBod.ResultBODType();
		resBod.ResultString = '';
		resBod.ResultDesc = '';
		resBod.ResultCode = 200;
		
		RL_WS_UnitedRoadTransFeesReq.TransportFeesReqBODType feesBod;
		feesBod = new RL_WS_UnitedRoadTransFeesReq.TransportFeesReqBODType();
		feesBod.VehicleIdentificationNumber = '123';
		
		RL_WS_UnitedRoadTransFeesResp.TransportFeesResBODType transportFeesResBOD;
		transportFeesResBOD = new RL_WS_UnitedRoadTransFeesResp.TransportFeesResBODType();
		transportFeesResBOD.GetVINInfoResponse = new RL_WS_UnitedRoadTransFeesResp.GetVINInfoResponseType();
		transportFeesResBOD.GetVINInfoResponse.LocationID = '';
		transportFeesResBOD.GetVINInfoResponse.LocationName = '';
		transportFeesResBOD.GetVINInfoResponse.LocationAdd1 = '';
		transportFeesResBOD.GetVINInfoResponse.LocationAdd2 = '';
		transportFeesResBOD.GetVINInfoResponse.LocationCity = '';
		transportFeesResBOD.GetVINInfoResponse.LocationState = '';
		transportFeesResBOD.GetVINInfoResponse.LocationZIP = '';
		transportFeesResBOD.GetVINInfoResponse.LocationPhone = '';
		transportFeesResBOD.GetVINInfoResponse.TransportFee = '';
		transportFeesResBOD.GetVINInfoResponse.CreatedDate = '';
		transportFeesResBOD.GetVINInfoResponse.OrderStatus = '';
		
		responseDoc = new RL_WS_UnitedRoadTransFeesResp.TransportFeesResSync_element();
		responseDoc.ProcessService = new RL_WS_UnitedRoadTransFeesResp.ProcessService_element();
		responseDoc.ProcessService.ResultBOD = resBod;
		responseDoc.ProcessService.TransportFeesResBOD = transportFeesResBOD;
		responseDoc.ProcessService.TransportFeesReqBOD = feesBod;
		
		RL_WS_GetUnitedRoadData.parseResponse(responseDoc);
		
		RL_WS_UnitedRoadTransFeesReq.ProcessService_element processService = new RL_WS_UnitedRoadTransFeesReq.ProcessService_element();
		RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees rtf = new RL_WS_UnitedRoadTransFeesImpl.ReceiveTransportFees();
		//rtf.TransportFees(processService);
		
		Test.stopTest();
		
    }
    
    
    
    
}