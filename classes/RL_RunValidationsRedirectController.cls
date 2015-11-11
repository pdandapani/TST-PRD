public with sharing class RL_RunValidationsRedirectController {
    
    private Repossession__c contextRepo;
    
    public String errDisplayText{get;set;}
    
    public static final String[] repoFields = new String[] {'Case__r.Form_Rule__c', 'Case__c', 'iRepo_VIN__c', 
                                            'Financial_Account__r.Collateral__r.Vehicle_Identification_Number__c', 
                                            'iRepo_AccountNumber__c', 'Financial_Account__c', 'State_of_jurisdiction__c',
                                            'Title_Name__c', 'Title_Street1__c', 'Title_Street2__c', 
                                            'Title_State__c', 'Title_City__c', 'Title_Zip__c', 'United_Road_Transport_Fees__c',
                                            'Auction_Agency_Zip__c','Auction_Agency_State__c','Auction_Agency_City__c',
                                            'Auction_Agency_Street2__c','Auction_Agency_Street1__c','Auction_Agency_Name__c', 
                                            'United_Road_Order_Date__c', 'Local_Repo_Date__c', 'iRepo_AssignmentNumber__c',
                                            'Account_Terminated__c', 'Service_Contracts__c', 'Dealer_Guaranty__c',
                                            'Vehicle_Make__c', 'Vehicle_Model__c', 'Repossession_Costs__c',
                                            'Impound_Fee__c', 'Redemption_Processing_Fee__c', 'Personal_Property_Fee__c',
                                            'Vehicle_Storage_Daily_Rate__c', 'Miscellaneous_Charges__c', 'Reinstatement_Allowed__c',
                                            'Reinstatement_Denial_Reason__c', 'GAP__c', 'Sales_Tax__c', 'Conditional_Reinstatement__c',
                                            'CLAH__c', 'IRepo_AssignmentType__c', 'iRepo_RepoState__c',
                                            'Salvage__c', 'Modify_REPO_Note__c',
                                            'Validation_Issues__c',
                                            'BK_Active_or_Discharged__c' };
    
    public RL_RunValidationsRedirectController(ApexPages.StandardController stdController) {
    	
		if(!Test.isRunningTest()) {
			stdController.addFields(RL_RunValidationsRedirectController.repoFields);
		}
        contextRepo = (Repossession__c) stdController.getRecord();
    }
    
    
    
    public PageReference executeValidations() {
    	errDisplayText = '';
    	
    	RL_RepossessionValidateDynamically validator = new RL_RepossessionValidateDynamically();
    	
    	Set<Id> idSet = new Set<Id>();
    	idSet.add(contextRepo.Id); 
    	
    	try {
    		//the true at the end runs an sobject.addError()
    		validator.updateSObjectValidationErrorValues(idSet, 'Repossession__c', 'Case__r.Form_Rule__c', 'Validation_Issues__c', true);
    		runComplexRelationshipAndReturnErrorString();
    		appendInfoMessage('Validations executed successfully.');
    	}catch(Exception e) {
    		String errorMsg = e.getMessage();
    		errorMsg += '\n line: ' + String.valueOf(e.getLineNumber());
    		appendErrorMessage(errorMsg);
    	}
    	
    	
    	return null;
    }
    
    private String runComplexRelationshipAndReturnErrorString() {
    	//complex relationship validation.
        String strToReturn = '';
        String facErrorString = '';
        if(contextRepo.BK_Active_or_Discharged__c == true) {
        	for(Financial_Account_Customer__c validFac : [select id, RL_Bankruptcy_Status__c from Financial_Account_Customer__c
	        												where Financial_Account__c = :contextRepo.Financial_Account__c AND Borrower_Status__c = 'Active'])
			{
				if(validFac.RL_Bankruptcy_Status__c == null || validFac.RL_Bankruptcy_Status__c == '') {
					facErrorString = 'At least one Financial Account Customer has a blank BK Status.';
				}
			}
        }
	        
		
		if(facErrorString != '') {
        	Repossession__c latestRepo = [select id, Validation_Issues__c from Repossession__c where id = :contextRepo.Id];
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
        	strToReturn = facErrorString;
        	update latestRepo;
        }
        
        return strToReturn;
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