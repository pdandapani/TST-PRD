/*****
 * Salesforce.com Success Services
 * Name: RL_GenerateDocRequestController
 * Description: Controller for RL_GenerateDocRequestPage.page
 */

public with sharing class RL_GenerateDocRequestController {
    private final Repossession__c repo; 
    private List<Schema.FieldSetMember> repoFields;
    private Flow.Interview.RL_Quality_Review_Selection qualityReviewFlow {get; set;}    
    private Case RLParentCase {get; set;}
    private Boolean isQualityReviewRequired = false;
    public String errDisplayText{get;set;} //if populated, the page will not redirect to /{!repo.Id}

    public RL_GenerateDocRequestController(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(RL_Utility.getListOfRepoFields());
            repo = (Repossession__c) stdController.getRecord(); 
        } else {
            Id repoId = stdController.getId();
            String repoQuery = 'SELECT ';
            for (String str : RL_Utility.getListOfRepoFields()) {
                repoQuery += repoQuery.contains(' ' + str+',') ? '' : str + ', ';
            }
            repoQuery += 'Modify_REPO_Note__c, State_of_Jurisdiction__c, Auction_Agency_Name__c, Auction_Agency_Street1__c, Auction_Agency_Street2__c, Auction_Agency_Phone__c, Auction_Agency_City__c, Auction_Agency_State__c, Auction_Agency_Zip__c FROM Repossession__c where Id =: repoId';
            repo = Database.Query(repoQuery);
        }
    }

    public PageReference generateDocRequest() {
        PageReference pageRefToReturn;
        
        try{
            pageRefToReturn = genDocRequestAndReturnPageRef();
        }catch(Exception e) {
            String errorMsg = e.getMessage();
            errorMsg += '\n line: ' + String.valueOf(e.getLineNumber());
            addErrorMessage(ApexPages.Severity.ERROR, errorMsg);
            return null;
        }
        
        return pageRefToReturn;
    }
    
    private String runValidationsAndReturnErrorString() {
    	String strToReturn = '';
    	
    	Id formRuleId = [SELECT Form_Rule__c FROM Case WHERE Id =: repo.Case__c].Form_Rule__c; //Needed for unit tests. 
        RL_RepossessionValidateDynamically validator = new RL_RepossessionValidateDynamically('Repossession__c', formRuleId);
    	validator.updateSObjectValidationErrorValues(repo.Id, 'Repossession__c', 'Case__r.Form_Rule__c', 'Validation_Issues__c', true);
    	
    	RL_RepossessionValidateDynamically.ValidationErrorMessages errorMessage = validator.errorMessagesMap.get(repo.Id);
        //If an error exists and there is no validation comment, then stop.
        if(errorMessage != null && errorMessage.hasHardErrors) {
            strToReturn = 'There are validation failures.  Fix them to generate document: ' + '\n ' + errorMessage.hardErrors;
        }else if(errorMessage != null && errorMessage.hasSoftErrors && (repo.Validation_Comments__c == null || repo.Validation_Comments__c.length() == 0) ) {
            strToReturn = 'There are soft validation failures.  Please add a validation comment to generate document.';
        }
        
        //complex relationship validation.
        String facErrorString = '';
        if(repo.BK_Active_or_Discharged__c == true) {
        	for(Financial_Account_Customer__c validFac : [select id, RL_Bankruptcy_Status__c from Financial_Account_Customer__c
	        												where Financial_Account__c = :repo.Financial_Account__c AND Borrower_Status__c = 'Active'])
			{
				if(validFac.RL_Bankruptcy_Status__c == null || validFac.RL_Bankruptcy_Status__c == '') {
					facErrorString = 'At least one Financial Account Customer has a blank BK Status.';
				}
			}
        }
	        
		
		if(facErrorString != '') {
        	Repossession__c latestRepo = [select id, Validation_Issues__c from Repossession__c where id = :repo.Id];
        	if(latestRepo.Validation_Issues__c == null || latestRepo.Validation_Issues__c == '') {
        		latestRepo.Validation_Issues__c = RL_Constants.HARD_VALIDATION_MESSAGE + '\n' + facErrorString;
        	}else{
        		String tmpErrString = RL_Constants.HARD_VALIDATION_MESSAGE + '\n' + facErrorString ;
        		if(!latestRepo.Validation_Issues__c.contains(RL_Constants.HARD_VALIDATION_MESSAGE)) {
        			latestRepo.Validation_Issues__c += tmpErrString; 
        		}else{
        			latestRepo.Validation_Issues__c = latestRepo.Validation_Issues__c.replaceFirst(RL_Constants.HARD_VALIDATION_MESSAGE, tmpErrString );
        		}
        	}
        	
        	if(strToReturn == '') {
        		strToReturn = 'There are validation failures.  Fix them to generate document';
        	}
        	
        	update latestRepo;
        }
    	
    	return strToReturn;
    }
    
    private PageReference genDocRequestAndReturnPageRef() {
        RL_DocRequestHandler requestHandler;
        Set<Id> docRequestIds = new Set<Id>(); 
        
        
        String validatorString = runValidationsAndReturnErrorString();
        if(validatorString != null && validatorString != '') {
        	addErrorMessage(ApexPages.Severity.ERROR, validatorString);
        	return null;
        }
        
        
        if (repo.Recorded_Legal_Sale_Date__c == null) { // Initial Document generation
            //Check if parent case requires QA by invoking the flow
            RLParentCase = [SELECT Id, Status, RecordTypeId, RL_System_Required_Notice_Date_Time__c, Form_Rule__c FROM Case WHERE Id = :repo.Case__c limit 1];
            String UserRole = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId() limit 1].Name;
            Case_Skills__c cs = Case_Skills__c.getInstance();

            // Call the flow with the variables
            Map<String, Object> params = new Map<String, Object>();
            params.put('sRLParentCase', RLParentCase);
            params.put('vUserRole', UserRole);
            params.put('vNewHire', cs.RL_New_Hire__c);
            params.put('vBandwidth', cs.RL_Daily_Case_Bandwidth__c);
            params.put('vDailySelection', cs.RL_Daily_Cases_for_Quality_Review__c);

            Flow.Interview.RL_Quality_Review_Selection qualityReviewFlow = new Flow.Interview.RL_Quality_Review_Selection(params);
            
            qualityReviewFlow.start();
            this.isQualityReviewRequired = (Boolean)qualityReviewFlow.getVariableValue('vQualityReviewRequired');

            if (!this.isQualityReviewRequired) {
                //Generate document
                requestHandler = new RL_DocRequestHandler(this.repo);
                requestHandler.generateDocRequest();
                
                for(Document_Request__c docReq : requestHandler.docRequestList) {
	    			docRequestIds.add(docReq.Id);
	    		}
	            RL_GenerateDocRequestController.generateLivecycleDocuments(docRequestIds);
                                
                this.repo.Recorded_Legal_Sale_Date__c = this.repo.Proposed_Legal_Sale_Date__c;
                update this.repo;   

            } else { //Quality review is required for the case
                addErrorMessage(ApexPages.Severity.CONFIRM, 'Case has been selected for quality review, queued for processing, and status updated.');
                return null;
            }
        } else { //Not the first generation of a document
            requestHandler = new RL_DocRequestHandler(this.repo);
            requestHandler.generateDocRequest();
            for(Document_Request__c docReq : requestHandler.docRequestList) {
    			docRequestIds.add(docReq.Id);
    		}
            RL_GenerateDocRequestController.generateLivecycleDocuments(docRequestIds);
            
            Date oldRLSD = repo.Recorded_Legal_Sale_Date__c;
            this.repo.Modify_REPO_Note__c = true;               
            this.repo.Recorded_Legal_Sale_Date__c = this.repo.Proposed_Legal_Sale_Date__c;
            update this.repo;
            

            if (oldRLSD != repo.Recorded_Legal_Sale_Date__c) {
                DateTime recordedDateTime = DateTime.newInstance(this.repo.Recorded_Legal_Sale_Date__c.year(), this.repo.Recorded_Legal_Sale_Date__c.month(), this.repo.Recorded_Legal_Sale_Date__c.day());
                addErrorMessage(ApexPages.Severity.CONFIRM, 'Please update LSD in AutoIMS to ' + recordedDateTime.format('MM/dd/yyyy'));
                return null; 
            }            
        }  
        
        
        if(ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
        	return null;
        }
        

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Document Generation Successful'));
        PageReference pageRef = new PageReference('/' + this.repo.Id);    
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    private static String printingEnabledCached;
    public static String printingEnabled {
    	get {
    		if(printingEnabledCached == null) {
		        if (!Test.isRunningTest()) {
		            printingEnabledCached = Label.RL_Enable_Printing_and_Document_Generation;
		        } else {
		            printingEnabledCached = 'TRUE';
		        }
		    	printingEnabledCached = printingEnabledCached.toUpperCase();
    		}
    		
    		return printingEnabledCached;
    	}
    	set {
    		printingEnabledCached = value;
    	}
    }
    
    @future (callout=true)
    public static void generateLivecycleDocuments(Set<Id> docRequestIds) {
    	
    	String printingIsEnabled = RL_GenerateDocRequestController.printingEnabled;
    	
    	if(docRequestIds != null) {
    		List<Document_Request__c> docsToUpdate = new List<Document_Request__c>();
    		List<System_Message__c> messagesToSend = new List<System_Message__c>();
    		
	    	for(Document_Request__c documntRequest : [select id, SourceFormIdentifier1__c, Sync_Callout_Error_Response__c, Sync_Callout_Response_Status__c,
	    												Repossession__r.Case__r.CaseNumber
	    												from Document_Request__c
	    												where id in :docRequestIds]) {
	    		
	    		String caseNumberString = ''; 
    			if(documntRequest.Repossession__r != null && documntRequest.Repossession__r.Case__r != null && documntRequest.Repossession__r.Case__r.CaseNumber != null) {
    				caseNumberString = String.valueOf(documntRequest.Repossession__r.Case__r.CaseNumber) ;
    			}
	    		
	    		try {
	    			
	    			if(printingIsEnabled != 'TRUE') {
	    				documntRequest.Sync_Callout_Response_Status__c = 'PRINTING DISABLED';
	    				documntRequest.Status__c = 'PRINTING DISABLED';
	    				documntRequest.Sync_Callout_Error_Response__c = 'To enable printing, contact the salesforce system administrator.' ;
	    				docsToUpdate.add(documntRequest);
			    		messagesToSend.add(buildSystemMessage( 'Document Generation and Printing Disabled by Salesforce System Administrator.', documntRequest.Id, 'Doc Gen Disabled', 'SFDC', caseNumberString ));
	    			}else{
	    				RL_WS_GenerateDocument.ResponseRecord responseRecord = RL_WS_GenerateDocument.callDocGenerationWebService(documntRequest.SourceFormIdentifier1__c, documntRequest.Id);
			    		documntRequest.Sync_Callout_Response_Status__c = responseRecord.ResultDesc;
			    		
			    		if(responseRecord.ResultCode == -101 || responseRecord.ResultCode == -225) {
			    			documntRequest.Sync_Callout_Error_Response__c = responseRecord.ResultString ; 
			    		}
			    		
		    			documntRequest.Sync_Callout_Error_Response__c = cleanString(documntRequest.Sync_Callout_Error_Response__c, 32767);
		    			documntRequest.Sync_Callout_XML_Request__c = cleanString(responseRecord.RequestString, 32767);
			    		docsToUpdate.add(documntRequest);
			    		if(documntRequest.Sync_Callout_Response_Status__c != null && documntRequest.Sync_Callout_Error_Response__c != null && documntRequest.Sync_Callout_Response_Status__c != 'SUCCESS') {
			    			String syncErr = 'Issue submitting form and communication between Salesforce and TIBCO.  Reference: ' + documntRequest.Id + '. ';
			    			syncErr += documntRequest.Sync_Callout_Error_Response__c ;
			    			messagesToSend.add(buildSystemMessage(syncErr, documntRequest.Id, 'Document Generation Error', 'TIBCO', caseNumberString));
			    		}
	    			}
	    		}catch(Exception e) {
	    			documntRequest.Sync_Callout_Response_Status__c = 'CAUGHT ERROR';
	    			documntRequest.Sync_Callout_Error_Response__c = e.getMessage() + ' line: ' + String.valueOf(e.getLineNumber()) + ' -- ' + e.getStackTraceString();
	    			docsToUpdate.add(documntRequest);
		    		messagesToSend.add(buildSystemMessage( 'Salesforce Error in Document Generation - ' + documntRequest.Sync_Callout_Error_Response__c, documntRequest.Id, 'Document Generation Error', 'TIBCO', caseNumberString ));
	    		}
		    		
	    	}
	    	
	    	if(messagesToSend.size() > 0) {
	    		insert messagesToSend;
	    	}
	    	
	    	update docsToUpdate;
	    }
    }
    
    public static System_Message__c buildSystemMessage(String description, Id docReqId, String messageTitle, String source, String caseNumber) {
    	System_Message__c msgToInsert = new System_Message__c();
    	
		msgToInsert.OwnerId = UserInfo.getUserId();
		msgToInsert.Notify_User__c = true ;
		msgToInsert.Source__c = source;
		msgToInsert.Title__c = messageTitle;
		if(caseNumber != null && caseNumber.length() > 0) {
			msgToInsert.Title__c += caseNumber;
		}
		msgToInsert.Type__c = 'Handled Error';
		msgToInsert.Description__c = description;
		
		return msgToInsert;
    }
    
    private static String cleanString(String str, Integer maxLength) {
    	if(str == null)
    		str = '';
    	
    	str = str.replaceAll('&amp;','&');
		str = str.replaceAll('&lt;','<');
		str = str.replaceAll('&gt;','>');
		if(str.length() > maxLength) {
			str = str.substring(0,maxLength);
		}
		return str;
    }
    
    public void addErrorMessage(ApexPages.Severity severity, String errorMessage) {
        errDisplayText = errorMessage;
        ApexPages.addMessage(new ApexPages.Message(severity, errorMessage));
    }
    
    
}