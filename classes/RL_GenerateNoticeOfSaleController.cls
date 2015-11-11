/*****
 * Salesforce.com Success Services
 * Name: RL_GenerateNoticeOfSaleController
 * Description: Controller for RL_GenerateNoticeOfSalePage.page
 */
public with sharing class RL_GenerateNoticeOfSaleController {
    private final Case childCase; 
    private Repossession__c repo;
    private Repossession__c repoId;
    private List<Schema.FieldSetMember> repoFields;
    private Boolean isQualityReviewRequired = false;

    public RL_GenerateNoticeOfSaleController(ApexPages.StandardController stdController) { 
        List<Form_Field__c> caseFormFields = [SELECT Id, Name, Source_Field__c, Source_Object__c FROM Form_Field__c WHERE Source_Object__c =: 'NoS Case'];
        List<String> fieldsList = new List<String>();
        for (Form_Field__c ff : caseFormFields) {
            fieldsList.add(ff.Source_Field__c);
        }
        fieldsList.addAll(new String[] {'ParentId', 'Financial_Account__c', 'Form_Rule__c', 'RL_Salvage_Sale_Time_1__c', 'RL_Salvage_Sale_Time_2__c',
                                                'RL_Salvage_Sale_Time_3__c', 'RL_Salvage_Sale_Time_4__c', 'RL_Salvage_Sale_Date_1__c', 'RL_Salvage_Sale_Date_2__c', 'RL_Salvage_Sale_Date_3__c', 
                                                'RL_Salvage_Sale_Date_4__c', 'RL_Online_Sale_1_To__c', 'RL_Online_Sale_1_From__c',
                                                'RL_Online_Sale_2_From__c', 'RL_Online_Sale_2_To__c', 'RL_Physical_Sale_Time_1__c', 'RL_Physical_Sale_Time_2__c', 'RL_Physical_Sale_Date_1__c', 
                                                'RL_Physical_Sale_Date_2__c', 'RecordType.Name', 'RL_Auto_IMS_Hold_Placed__c', 'RL_Auction_Agency_Zip__c', 'RL_Auction_Agency_Street1__c', 
                                                'RL_Auction_Agency_Street2__c', 'RL_Auction_Agency_City__c', 'RL_Auction_Agency_State__c', 'RL_Auction_Agency_Name__c', 'RecordTypeId', 'Status', 'RL_System_Required_Notice_Date_Time__c'});
        Set<String> caseFormFieldsSet = new Set<String>(fieldsList); //Remove duplicate fields.
        
        if (!Test.isRunningTest()) {            
            stdController.addFields(new List<String>(caseFormFieldsSet));
        }
        childCase = (Case) stdController.getRecord(); 
    }

    public PageReference generateNoticeOfSale() {
        //Get repo related records
        this.repoId = [SELECT Id FROM Repossession__c WHERE Case__c =: this.childCase.ParentId ORDER BY CreatedDate DESC];
        this.repo = RL_Utility.executeRepoQuery(RL_Utility.getListOfRepoFields(), this.repoId.Id);

        List<Schema.FieldSetMember> saleTimeFields;
        List<Schema.FieldSetMember> saleDateFields;
                
        if (this.childCase.RL_Auto_IMS_Hold_Placed__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'AutoIMS Hold has not been released. Verify hold is released and uncheck AutoIMS Hold Placed field.'));
            return null;            
        }

        if (this.childCase.RL_Auction_Agency_URL__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Auction agency URL is required for notice of sale generation'));
            return null;                
        }        

        //Notice of Sale validation - if current date is less than at least 11 days prior to earliest sale date or greater than 60 days then prevent generation of notice of sale
        if (this.childCase != null) {    
            String recordTypeName = [SELECT Name FROM RecordType WHERE SObjectType =: 'Case' AND Id =: this.childCase.RecordTypeId].Name;
            if (recordTypeName.equalsIgnoreCase('RL Notice of Sale-Salvage')) { //4820
                saleTimeFields = SObjectType.Case.FieldSets.Salvage_Sale_Time_Fields.getFields();
                saleDateFields = SObjectType.Case.FieldSets.Salvage_Sale_Date_Fields.getFields();
            } else if (recordTypeName.equalsIgnoreCase('RL Notice of Sale')) { //4028MD
                saleTimeFields = SObjectType.Case.FieldSets.Non_Salvage_Sale_Time_Fields.getFields();
                saleDateFields = SObjectType.Case.FieldSets.Non_Salvage_Sale_Date_Fields.getFields();
            }
            
            for (Schema.FieldSetMember timeField : saleTimeFields) {
                if (this.childCase.get(timeField.getFieldPath()) == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sale time fields are required for notice of sale generation'));
                    return null;                    
                }
            }
            for (Schema.FieldSetMember dateField : saleDateFields) {
                if (this.childCase.get(dateField.getFieldPath()) == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sale date fields are required for notice of sale generation'));
                    return null;
                }
                if (Date.today().daysBetween(Date.ValueOf(this.childCase.get(dateField.getFieldPath()))) <= 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sale date: <' + dateField.getLabel() + ' - ' + Date.ValueOf(this.childCase.get(dateField.getFieldPath())).format() + '> needs to be greater than 10 days from Notice Date'));
                    return null;
                }
                if (Date.today().daysBetween(Date.ValueOf(this.childCase.get(dateField.getFieldPath()))) > 60) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sale date: <' + dateField.getLabel() + ' - ' + Date.ValueOf(this.childCase.get(dateField.getFieldPath())).format() + '> cannot be more than 60 days from Notice Date'));
                    return null;                        
                }
            }
        }

        // Check if this case requires Quality Review
        String UserRole = [select Name from UserRole where Id = :UserInfo.getUserRoleId() limit 1].Name;  
        if (!UserRole.equalsIgnoreCase('Associates')) {
            RL_DocRequestHandler requestHandler = new RL_DocRequestHandler(this.repo, this.childCase);
            requestHandler.generateDocRequest();
            
            Set<Id> docRequestIds = new Set<Id>();
            for(Document_Request__c docReq : requestHandler.docRequestList) {
                 docRequestIds.add(docReq.Id);
            }
            RL_GenerateDocRequestController.generateLivecycleDocuments(docRequestIds);
            
        } else {
            this.childCase.Status = 'Quality Review';
            update this.childCase;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Case has been selected for quality review, queued for processing, and status updated.'));
            return null;
        }
        
        return null;

    } 
}