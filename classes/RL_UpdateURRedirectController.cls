public with sharing class RL_UpdateURRedirectController {
    
    private Repossession__c contextRepo;
    
    public String referrerUrl{get;set;}
    public String errDisplayText{get;set;}
    
    public RL_UpdateURRedirectController(ApexPages.StandardController stdController) {
        
        String[] repoFields = new String[] {'Case__r.Form_Rule__c', 'Case__c', 'iRepo_VIN__c', 
                                            'Financial_Account__r.Collateral__r.Vehicle_Identification_Number__c', 
                                            'iRepo_AccountNumber__c', 'Financial_Account__c', 'State_of_jurisdiction__c',
                                            'Title_Name__c', 'Title_Street1__c', 'Title_Street2__c', 
                                            'Title_State__c', 'Title_City__c', 'Title_Zip__c', 'United_Road_Transport_Fees__c',
                                            'Auction_Agency_Zip__c','Auction_Agency_State__c','Auction_Agency_City__c',
                                            'Auction_Agency_Street2__c','Auction_Agency_Street1__c','Auction_Agency_Name__c', 
                                            'United_Road_Order_Date__c', 'Local_Repo_Date__c', 'iRepo_AssignmentNumber__c' };
        if (!Test.isRunningTest()) {   
            stdController.addFields(repoFields);
        }
        contextRepo = (Repossession__c) stdController.getRecord();
        referrerUrl = ApexPages.currentPage().getHeaders().get('Referer');
    }

    public PageReference updateURDetails() {
        PageReference pageRefToReturn = null;
        
        try {
            runUnitedRoadCallout();
            
        }catch(Exception e){
            appendErrorMessage( 'Salesforce Response: ' + e.getMessage());
        }
        return null;
    }
    
    
    public void runUnitedRoadCallout() {
        
        RL_WS_GetUnitedRoadData.UR_RequestParams requestParams;
        requestParams = new RL_WS_GetUnitedRoadData.UR_RequestParams();
        if(contextRepo.Financial_Account__r.Collateral__r.Vehicle_Identification_Number__c != null) {
            requestParams.VIN = contextRepo.Financial_Account__r.Collateral__r.Vehicle_Identification_Number__c;
        }else{
            requestParams.VIN = contextRepo.iRepo_VIN__c;
        }
        
        if(requestParams.VIN == null || requestParams.VIN.length() == 0) {
            appendErrorMessage('Invalid Salesforce data.  There is not a VIN number associated with this account.');
            return;
        }
        
        
        System.debug( '***** requestParams.VIN =' + requestParams.VIN );
        
        RL_WS_GetUnitedRoadData.UR_ResponseParams responseParams;
        RL_WS_GetUnitedRoadData.UR_ResponseRecord responseRecord;
        if (Test.isRunningTest()) {
            responseParams = new RL_WS_GetUnitedRoadData.UR_ResponseParams();
            responseRecord = new RL_WS_GetUnitedRoadData.UR_ResponseRecord();
            responseParams.StatusParams.Status = 'SUCCESS';
            responseRecord.LocationName = 'TEST NAME'; 
            responseRecord.TransportFee = '1234';
            responseRecord.LocationId = '1234';
            responseRecord.CreatedDate = '01-01-2015';
        } else {
            responseParams = RL_WS_GetUnitedRoadData.getURdata(requestParams);
            responseRecord = responseParams.responseRecord ;
        }
        
        System.debug( '***** responseParams =' + responseParams );
        
        
        
        if(responseParams.StatusParams != null && responseParams.StatusParams.Status != null && responseParams.StatusParams.Status == 'FAIL') {
            errDisplayText = 'TIBCO Error: ' + responseParams.StatusParams.Error;
            appendErrorMessage(errDisplayText);
        } else if(responseRecord != null && 
                (
                    (responseRecord.LocationName == null || responseRecord.LocationName == '')
                    && (responseRecord.TransportFee == null || responseRecord.TransportFee == '')
                    && (responseRecord.LocationID == null || responseRecord.LocationID == '')
                ) ) 
        {
            appendInfoMessage('No records found on United Road.  Redirecting...');
        } else if(responseRecord != null) { 
            System.debug( '***** responseRecord =' + responseRecord );
            
            String locationId = responseRecord.LocationID;
            String locationName = responseRecord.LocationName ;
            String locationAdd1 = responseRecord.LocationAdd1 ;
            String locationAdd2 = responseRecord.LocationAdd2 ;
            String locationCity = responseRecord.LocationCity ;
            String locationState = responseRecord.LocationState ;
            String locationZIP = responseRecord.LocationZIP ;
            String locationPhone = responseRecord.LocationPhone ;
            String transportFee = responseRecord.TransportFee ;
            String createdDate = responseRecord.CreatedDate ;
            String orderStatus = responseRecord.OrderStatus ;
            
            contextRepo.Auction_Agency_Zip__c = locationZIP; 
            contextRepo.Auction_Agency_City__c = locationCity; 
            contextRepo.Auction_Agency_State__c = locationState; 
            contextRepo.Auction_Agency_Street2__c = locationAdd2; 
            contextRepo.Auction_Agency_Street1__c = locationAdd1; 
            contextRepo.Auction_Agency_Name__c = locationName;
            contextRepo.Auction_Agency_Phone__c = locationPhone;
            
            System.debug( '***** locationPhone =' + locationPhone );
            System.debug( '***** locationZIP =' + locationZIP );
            
            if(transportFee == null || transportFee == '') {
                contextRepo.United_Road_Transport_Fees__c = null;
                System.debug( '***** transportFee null' );
            }else{
                try{
                    contextRepo.United_Road_Transport_Fees__c = Decimal.valueOf(transportFee) ;
                    System.debug( '***** contextRepo.United_Road_Transport_Fees__c = ' + contextRepo.United_Road_Transport_Fees__c );
                    System.debug( '***** transportFee = ' + transportFee );
                }catch(Exception e) {
                    System.debug( '***** e.error.transportFee = ' + e.getMessage() );
                    System.debug( '***** transportFee = ' + transportFee );
                }
            }
            
            Boolean dateError = false;
            if(createdDate == null || createdDate == '') {
                contextRepo.United_Road_Order_Date__c = null;
                System.debug( '***** createdDate null' );
            }else{
                try{
                    //2010-08-05 00:00:00.000
                    List<String> dateStringArray = createdDate.split('-'); 
                    String yyyy = dateStringArray[0];
                    String mm = dateStringArray[1];
                    String dd = dateStringArray[2].substring(0,2);
                    
                    Date date1 = Date.newInstance( Integer.valueOf(yyyy), Integer.valueOf(mm), Integer.valueOf(dd) );
                    Date date2 = Date.valueOf( createdDate );
                    contextRepo.United_Road_Order_Date__c = date1;
                    
                    System.debug('**** dateStringArray = ' + dateStringArray);
                    System.debug( '***** createdDate = ' + createdDate );
                    System.debug( '***** contextRepo.United_Road_Order_Date__c = ' + contextRepo.United_Road_Order_Date__c );
                }catch(Exception e) {
                    System.debug( '***** e.createdDate = ' + e.getMessage() );
                    System.debug( '***** createdDate = ' + createdDate );
                    appendErrorMessage(e.getMessage());
                    dateError = true;
                }
                    
            }
            
            if(contextRepo.Local_Repo_Date__c != null && contextRepo.United_Road_Order_Date__c != null) {
            	if(contextRepo.United_Road_Order_Date__c < contextRepo.Local_Repo_Date__c) {
            		
            		appendErrorMessage('United Road date is before this repossession date. \nUR Date = ' + String.valueOf(contextRepo.United_Road_Order_Date__c) + '. Repo date = ' + String.valueOf(contextRepo.Local_Repo_Date__c));
                    dateError = true;
            	}
            }else{
            	//iRepo_AssignmentNumber__c matches UR Order number.
            }
            
            System.debug( '***** contextRepo =' + contextRepo );
            
            if(!dateError) {
            	appendInfoMessage('Data successfully retrieved. Title fields updated.  Redirecting...');
            	update contextRepo;
            }
        }
    }
    
    
    private void appendInfoMessage(String infoMessage) {
        appendMessage(infoMessage, ApexPages.Severity.INFO);
    }
    
    private void appendErrorMessage(String errorMessage) {
        errDisplayText = errorMessage;
        appendMessage(errorMessage, ApexPages.Severity.ERROR);
    }
    
    private void appendMessage(String errorMessage, ApexPages.severity severity) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(severity, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
}