global with sharing class RL_InteractionEntryPanelController {
    
    
    public Case contextCase{get;set;}
    public Financial_Account__c contextFinancialAccount{get;set;}
    public Repossession__c contextRepo{get;set;}
    
    public String selectedActivityCodeFromJs{get;set;}
    public String selectedCodeCtiEnabled{get;set;}
    
    public String legalSaleDate {
        get{
            String strToReturn = '';
            if(contextRepo != null && contextRepo.Recorded_Legal_Sale_Date__c != null) {
                if(contextRepo.Recorded_Legal_Sale_Date__c.month() < 10) {
                    strToReturn += '0';
                }
                strToReturn += String.valueOf(contextRepo.Recorded_Legal_Sale_Date__c.month());
                strToReturn += '/';
                if(contextRepo.Recorded_Legal_Sale_Date__c.day() < 10) {
                    strToReturn += '0';
                }
                strToReturn += String.valueOf(contextRepo.Recorded_Legal_Sale_Date__c.day());
                strToReturn += '/';
                strToReturn += String.valueOf(contextRepo.Recorded_Legal_Sale_Date__c.year());
            }
            return strToReturn;
        }
    }
    
    @RemoteAction
    global static RL_WS_TaxServiceExecution.TaxService_ResponseParams tempURCallout() {
        RL_WS_TaxServiceExecution.TaxService_ResponseParams objToReturn;
        objToReturn = RL_WS_TaxServiceExecution.testService();
        return objToReturn;
    }
    
    
    public RL_InteractionEntryPanelController(ApexPages.StandardController stdController) {
        
        populateContextCase(stdController);
        
        initData();
    }
    
    
    private void initData() {
        
        if(contextCase != null) {
            
            if(contextCase.Financial_Account__c != null) {
                populateContextFA(contextCase.Financial_Account__c);
            }else if(contextCase.Parent.Financial_Account__c != null){
                populateContextFA(contextCase.Parent.Financial_Account__c);
            }else if(contextCase.Parent.Parent.Financial_Account__c != null){
                populateContextFA(contextCase.Parent.Parent.Financial_Account__c);
            }
            
            if(contextFinancialAccount != null) {
                populateCorrectTopAndBottomFACs();
            }
            
            populateContextRepo();
            
        }
    }
    
    
    private void populateContextCase(ApexPages.StandardController stdController) {
        
        try{
            Case caseObj = (Case)stdController.getRecord();
            if(caseObj != null) {
                contextCase = [select id, Financial_Account__c, ParentId, Parent.Financial_Account__c, Parent.Parent.Financial_Account__c
                                from Case 
                                where id = :caseObj.Id] ;
            }
        }catch(Exception e) {
            appendErrorMessage(e.getMessage());
        }
        
    }
    
    private void populateContextFA(Id financialAccountId) {
        try {
            contextFinancialAccount = [select id, Name, Past_Due_Charges__c, Payment_Amount_Past_Due__c, Charges_Late__c,
                                    RecordType.Name, Financial_Account_Number__c,
                                    Charges_Miscellaneous__c, Payment_Amount_Scheduled__c, Partial_Payment_Option__c,
                                    Coll_Num_Months_Past_Due__c,
                                    History_Counter_Fifteen_Days_Past_Due__c, History_Counter_Thirty_Days_PastDue__c,
                                    History_Counter_SixtyDaysPastDue__c, History_Counter_Days_Past_Due__c,
                                    Payment_Date_Past_Due__c, Total_Amount_Due__c, 
                                    History_Counter_Ninety_Days_Past_Due__c, Payment_Date_Last__c, Payment_Amount_Last__c,
                                    History_Counter_Non_Sufficient_Funds__c,
                                    Collateral__c, Collateral__r.Model_Year__c, Collateral__r.Make__c, Collateral__r.Model_Name__c,
                                    Collateral__r.Vehicle_Identification_Number__c
                                from Financial_Account__c
                                where id = :financialAccountId];
                                //(select Id, Model_Year__c, Make__c, Model_Name__c
                                    //from Assets)
        }
        catch (Exception e) {
            appendErrorMessage('Financial Account record not found.');
        }
    }
    
    
    private void populateCorrectTopAndBottomFACs() {
        
    }
    
    
    private void populateContextRepo() {
        Boolean errorHit = false;
        String errorMessage = '';
        try {
        	populateContextRepoNestedInTryCatch(contextCase.Id);
        }catch (Exception e) {
            errorHit = true;
            errorMessage = 'No repossession record related to this case.'; 
        }
        
        if(errorHit == true && contextCase.ParentId != null) {
             try {
				populateContextRepoNestedInTryCatch(contextCase.ParentId);
                errorHit = false;
            }catch (Exception e) {
                errorHit = true;
                errorMessage = 'No repossession record related to this case.'; 
            }
        }
        
        if(errorHit == true && contextCase.Parent.ParentId != null) {
             try {
                populateContextRepoNestedInTryCatch(contextCase.Parent.ParentId);
                errorHit = false;
            }catch (Exception e) {
                errorHit = true;
                errorMessage = 'No repossession record related to this case.'; 
            }
        }
        
        if(errorHit) {
            appendErrorMessage(errorMessage);
        }
        
    }
    
    private void populateContextRepoNestedInTryCatch(Id caseId) {
    	contextRepo = [select id, name, Local_Repo_Date__c, IRepo_VendorName__c, Proposed_Legal_Sale_Date__c,
                            Dealer_Guaranty__c, Service_Contracts__c, Modify_REPO_Note__c,
                            Recorded_Legal_Sale_Date__c
                        from Repossession__c
                        where Case__c = :caseId
                        limit 1];
    }
    
    
    
    
    private void appendErrorMessage(String errorMessage) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
    
    public PageReference updateModifyRepoNote() {
        try {
            update contextRepo;
        }catch(Exception e) {
            appendErrorMessage(e.getMessage());
        }
        
        return null;
    }
    
    public PageReference getLatestFormData() {
        initData();
        
        selectedCodeCtiEnabled = '';
        
        if(selectedActivityCodeFromJs != null && selectedActivityCodeFromJs != '' && selectedActivityCodeFromJs != 'None') {
            try{
                Activity_Code__c activityCode = [SELECT Id, Name, Description__c, Collection_Activity_Code__c, 
                                                           CTI_Reason__c, CTI_Result__c, CTI_Activity__c
                                                         From Activity_Code__c
                                                         WHERE Name = :selectedActivityCodeFromJs ];
                if(activityCode.CTI_Activity__c == true) {
                    selectedCodeCtiEnabled = 'Yes';
                }
            }catch(Exception e) {
            }
        }
        
        return null;
    }
    
    
}