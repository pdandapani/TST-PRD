public with sharing class RL_VertexTaxRedirectController {
    
    public String errDisplayText{get;set;}
    
    public Decimal salesPrice{get;set;}
    public Date salesTaxDate{get;set;}
    public String stateAbbrev{get;set;}
    public String zipCode{get;set;}
    
    private Repossession__c contextRepo;
    
    public RL_VertexTaxRedirectController(ApexPages.StandardController stdController) {
        initData(stdController);
    }
    
    private void initData(ApexPages.StandardController stdController) {
        String[] repoFields = new String[] {'Case__r.Form_Rule__c', 'Case__c', 'iRepo_VIN__c', 
                                            'Recorded_Legal_Sale_Date__c', 'Proposed_Legal_Sale_Date__c',
                                            'State_of_jurisdiction__c', 'UnpaidGrossBalance__c', 'TotalRedemptionAmount__c',
                                            'Sales_Tax__c', 'Sales_Tax_Zip_Code__c', 'Title_Zip__c',
                                            'CLAH_Refund__c', 'CA_Insurance_Fee_Refund__c', 'GAP_Refund__c',
                                            'Excluded_Fee_Amount__c', 'Impound_Fee__c',
                                            'Personal_Property_Fee__c','Police_Agency_Fee__c','Redemption_Processing_Fee__c',
                                            'Third_Party_Other_Fees__c','United_Road_Transport_Fees__c',
                                            'Local_Repo_Date__c', 'Repossession_Costs__c', 'Other_Charges1__c', 'Other_Charges2__c' };
        if (!Test.isRunningTest()) {  
            stdController.addFields(repoFields);
            contextRepo = (Repossession__c) stdController.getRecord();
        } else {
            contextRepo = [SELECT Id, Case__r.Form_Rule__c, Case__c, iRepo_VIN__c, Recorded_Legal_Sale_Date__c, Proposed_Legal_Sale_Date__c, State_of_Jurisdiction__c, 
                UnpaidGrossBalance__c, TotalRedemptionAmount__c, Sales_Tax__c, Sales_Tax_Zip_Code__c, Title_Zip__c, CLAH_Refund__c, CA_Insurance_Fee_Refund__c, 
                GAP_Refund__c, Excluded_Fee_Amount__c, Impound_Fee__c, Personal_Property_Fee__c, Police_Agency_Fee__c, 
                Redemption_Processing_Fee__c, Third_Party_Other_Fees__c, United_Road_Transport_Fees__c, Local_Repo_Date__c, Repossession_Costs__c, 
                Other_Charges1__c, Other_Charges2__c 
                FROM Repossession__c WHERE Id =: stdController.getId()];
        }
        
        this.salesPrice = contextRepo.UnpaidGrossBalance__c + contextRepo.Repossession_Costs__c + contextRepo.United_Road_Transport_Fees__c + contextRepo.Impound_Fee__c + contextRepo.Other_Charges1__c + contextRepo.Other_Charges2__c;
        this.salesTaxDate = date.today();
        this.zipCode = contextRepo.Sales_Tax_Zip_Code__c;
        this.stateAbbrev = contextRepo.State_of_Jurisdiction__c;
    }
    
    
    private void checkIfDataValidAndSetError() {
        errDisplayText = '';
        
        if(zipCode == null || zipCode.length() != 10 || !zipCode.contains('-')) {
            appendErrorMessage('Please enter full 5+4 format into Sales Tax Zip Code.');
        }
        
        if(salesPrice == null || salesPrice <= 0) {
            appendErrorMessage('Sales Price must be greater than zero.');
        }
        
        if(stateAbbrev == null || stateAbbrev.length() != 2) {
            appendErrorMessage('State must be two characters long (e.g. "CA").');
        }
    }
    
    public PageReference executeTaxCallout() {
        
        checkIfDataValidAndSetError();
        
        if(errDisplayText == null || errDisplayText == '') {
            try {
                
                runCallout();
                
            }catch(Exception e){
                appendErrorMessage( 'Salesforce Response: ' + e.getMessage());
                return null;
            }
        }
            
        
        if(errDisplayText == null || errDisplayText == '') {
            appendInfoMessage('Data successfully retrieved. Sales Tax field updated.  Redirecting...');
        }
        
        return null;
    }
    
    
    //wrapped in a try-catch.
    private void runCallout() {
        
        RL_WS_TaxServiceExecution.TaxService_RequestParams request;
        request = new RL_WS_TaxServiceExecution.TaxService_RequestParams();
        
        request.RequestID = TFSC_Utils.getGUID();
        request.SalesPriceAmount = salesPrice;
        request.SalesTaxDate = salesTaxDate;
        request.StateCode = stateAbbrev;
        request.ZipCode = zipCode;
        /*
            public Decimal salesPrice;
            public Date salesTaxDate;
            public String stateAbbrev;
            public String zipCode;
        */
        
        RL_WS_TaxServiceExecution.TaxService_ResponseParams response;
        if (Test.isRunningTest()) {  
            response = new RL_WS_TaxServiceExecution.TaxService_ResponseParams();
            response.StatusParams = new RL_WS_TaxServiceExecution.TaxService_StatusParams();
            response.StatusParams.Status = 'SUCCESS';
            response.responseRecord = new RL_WS_TaxServiceExecution.TaxService_ResponseRecord();
            response.responseRecord.TotalTax = 123;
            response.responseRecord.TotalAmount = 123;
        } else {
            response = RL_WS_TaxServiceExecution.getTaxRateData(request);
        }

        if(response.StatusParams != null && response.StatusParams.Status != null && response.StatusParams.Status == 'FAIL') {
            errDisplayText = 'TIBCO Error: ' + response.StatusParams.Error;
            appendErrorMessage(errDisplayText);
        }else{
            //public Decimal TotalAmount;
            //public Decimal TotalTax;
            contextRepo.Sales_Tax__c = response.responseRecord.TotalTax;
            
            if(contextRepo.Sales_Tax__c > 0 && contextRepo.State_of_Jurisdiction__c != null && contextRepo.State_of_Jurisdiction__c.equalsIgnoreCase('IL')) {
                contextRepo.Sales_Tax__c = Math.round(contextRepo.Sales_Tax__c);
            }
            
            update contextRepo;
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