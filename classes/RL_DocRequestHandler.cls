/*****
 * Salesforce.com Success Services
 * Name: RL_DocRequestHandler
 * Description: RL_DocRequestHandler used to generate document request record based on a repossession.
 */

public with sharing class RL_DocRequestHandler {
    private Repossession__c repo; 
    private Case aCase;
    private Financial_Account__c fAccount;
    private List<Financial_Account_Customer__c> fCustomersList;
    private Financial_Account_Customer__c primaryBorrower;
    private Collateral__c collateral;
    private Account dealership;
    private Form_Rule__c formRule;
    private Document_Request__c docRequest; 
    public List<Document_Request__c> docRequestList;
    private List<Document_Request_Line_Item__c> docRequestLiList;
    private List<List<Document_Request_Line_Item__c>> drLiNestedList;
    private Map<Form__c, List<Form_Field__c>> formToFieldsMap;    
    private List<Case> childCases;
    private Map<Financial_Account_Customer__c, Account> facAccountMap;
    private Case childCase;
    private Map<String, Schema.SObjectField> docRequestFieldMap;
    private String watermark;
    private Document_Request_Line_Item__c docLiCoCustomers;
    private Document_Request_Line_Item__c docLiCoverage1;
    private Document_Request_Line_Item__c docLiCoverage2;
    
    //Harendra Sain start for story #S-311647
    private final string RECTYPE_REPOSSESSION_CA_IN_STATE = 'RL Retail-CA In-State';
    private final string RECTYPE_REPOSSESSION_CA_OUT_STATE = 'RL Retail-CA Out-of-State';
    //End
    
    /**
     * Constructor for generating document requests
     */
    public RL_DocRequestHandler(Repossession__c repo) {
        this.repo = repo; 
        this.aCase = [SELECT Id, Financial_Account__c, Form_Rule__c, BusinessHoursId, RL_Repo_Date__c, RL_Required_Notice_Date_Time__c, RL_Required_Service_Level_Date__c,
            RL_State_of_Jurisdiction__c, RL_System_Required_Notice_Date_Time__c, RL_VIN__c, RL_Auction_Agency_Name__c FROM Case WHERE Id =: this.repo.Case__c];        
        this.formRule = [SELECT Id, Name, Form__c, Account_Type__c, Post_RL_Notice_of_Sale__c FROM Form_Rule__c WHERE Id =: this.aCase.Form_Rule__c LIMIT 1];

        if (this.repo.Salvage__c) {
            this.childCases = [SELECT Id, CreatedDate, RecordType.Name, Status FROM Case WHERE ParentId =: aCase.Id AND RecordType.Name =: RL_Constants.NOS_SALVAGE_RT];
        } else {
            this.childCases = [SELECT Id, CreatedDate, RecordType.Name, Status FROM Case WHERE ParentId =: aCase.Id AND RecordType.Name =: RL_Constants.NOS_RT];
        }
    }

    /**
     * Constructor for generating notice of sales
     */
    public RL_DocRequestHandler(Repossession__c repo, Case childCase) {
        this.repo = repo;
        this.aCase = [SELECT Id, Financial_Account__c, Form_Rule__c, BusinessHoursId, RL_Repo_Date__c, RL_Required_Notice_Date_Time__c, RL_Required_Service_Level_Date__c,
            RL_State_of_Jurisdiction__c, RL_System_Required_Notice_Date_Time__c, RL_VIN__c, RL_Auction_Agency_Name__c FROM Case WHERE Id =: this.repo.Case__c];        
        this.childCase = childCase;
        this.formRule = [SELECT Id, Name, Form__c, Account_Type__c, Post_RL_Notice_of_Sale__c FROM Form_Rule__c WHERE Id =: this.childCase.Form_Rule__c LIMIT 1];
    }

    /**
     * GenerateDocRequest
     * Creates a document request record for this repossession record
     * Creates a child MD case as needed
     * Creates document request line items as needed
     */
    public void generateDocRequest() {
        //Populate Forms map
        List<Form_Rule_Junction__c> formRuleJunction = [SELECT Form__r.Id, Form_Rule__c FROM Form_Rule_Junction__c WHERE Form_Rule__c =: formRule.Id];
        List<Id> formIdList = new List<Id>();
        for (Form_Rule_Junction__c frJunction : formRuleJunction) {
            formIdList.add(frJunction.Form__r.Id);
        }
        Map<Id, Form__c> formIdToObjMap = new Map<Id, Form__c>([SELECT Id, Name, Copy_per_FAC__c, Document_request_record_type__c, Document_Type__c FROM Form__c WHERE Id IN : formIdList]);
       
        List<Id> formFieldList = new List<Id>();
        for (Form_Field_Junction__c ffJunction : [SELECT Id, Form_Field__c, Form__c FROM Form_Field_Junction__c WHERE Form__c IN: formIdToObjMap.values()]) {
            formFieldList.add(ffJunction.Form_Field__c);
        }

        //Add cover letter FFs to FormFieldList
        Form__c coverLetterForm;
        try {
            coverLetterForm = [SELECT Id, Name, Copy_per_FAC__c, Document_request_record_type__c, Document_Type__c FROM Form__c WHERE Name =: RL_Constants.COVER_LETTER_FORM];
        } catch (QueryException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find form record name: ' + RL_Constants.COVER_LETTER_FORM));
            return;
        }

        for (Form_Field_Junction__c coverLetterFFJunction : [SELECT Id, Form_Field__c FROM Form_Field_Junction__c WHERE Form__c =: coverLetterForm.Id]) {
            formFieldList.add(coverLetterFFJunction.Form_Field__c);
        }

        //Populate Form-fields map
        Map<Id, Form_Field__c> ffIdToObjMap = new Map<Id, Form_Field__c>([SELECT Id, Name, Source_Field__c, Target_Field__c, Source_Object__c, Primary_FAC__c, Line_item_field__c, Line_Item_Type__c FROM Form_Field__c WHERE Id IN : formFieldList]);     
        
        //Get related data for this case and repossession
        String fAccountQuery = 'SELECT ';   
        String collateralQuery = 'SELECT ';  
        String fCustomersListQuery = 'SELECT ';  
        String accountQuery = 'SELECT ';
        String dealershipQuery = 'SELECT ';

        for (Form_Field__c ff : ffIdToObjMap.values()) {
            if (ff.Source_Object__c.equalsIgnoreCase('Financial_Account__c')) {
                fAccountQuery += fAccountQuery.contains(' ' + ff.Source_Field__c+',') ? '' : ff.Source_Field__c + ', ';
            } else if (ff.Source_Object__c.equalsIgnoreCase('Collateral__c')) {
                collateralQuery += collateralQuery.contains(' ' + ff.Source_Field__c+',') ? '' : ff.Source_Field__c + ', ';
            } else if (ff.Source_Object__c.equalsIgnoreCase('Financial_Account_Customer__c')) {
                fCustomersListQuery += fCustomersListQuery.contains(' ' + ff.Source_Field__c+',') ? '' : ff.Source_Field__c + ', ';
            } else if (ff.Source_Object__c.equalsIgnoreCase('FAC Account')) {
                accountQuery += accountQuery.contains(' ' + ff.Source_Field__c+',') ? '' : ff.Source_Field__c + ', ';
            } else if (ff.Source_Object__c.equalsIgnoreCase('Dealership')) {
                dealershipQuery += dealershipQuery.contains(' ' + ff.Source_Field__c+',') ? '' : ff.Source_Field__c + ', ';
            }
        }
        String faId = this.repo.Financial_Account__c;   
        this.fAccount = Database.Query(fAccountQuery + 'Id, Name, Collateral__c, Dealership__c FROM Financial_Account__c WHERE Id =: faId');
        String collateralId = fAccount.Collateral__c;
        String dealershipId = fAccount.Dealership__c;
        this.collateral = Database.Query(collateralQuery + 'Id, Name FROM Collateral__c WHERE Id =: collateralId');
        this.fCustomersList = Database.Query(fCustomersListQuery + 'Id, Name, Customer_Role_Type__c, RL_Bankruptcy_Status__c, Account__c FROM Financial_Account_Customer__c WHERE Financial_Account__c =: faId AND Borrower_Status__c = \'Active\'');
        try{
            this.dealership = Database.Query(dealershipQuery + 'Id FROM Account WHERE Id =: dealershipId');
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no valid Dealer on this Financial Account record.'));
            return;
        }
        
        List<Third_Party__c> thirdPartyList = [SELECT Id, First_Name__c, Last_Name__c, Address1__c, Address2__c, City_State_Zip_Code__c, Financial_Account__c, Attorney_Representing_Borrower__c FROM Third_Party__c WHERE Repossession__c =: this.repo.Id];

        //Construct FAC to Account obj Map and find Primary borrower
        Map<Id, Financial_Account_Customer__c> facAccountIdMap = new Map<Id, Financial_Account_Customer__c>();
        for (Financial_Account_Customer__c fac : fCustomersList) {
            if (fac.Customer_Role_Type__c.equalsIgnoreCase(RL_Constants.PRIMARY_BORROWER_ROLE_TYPE)) {
                this.primaryBorrower = fac;
            }
            facAccountIdMap.put(fac.Account__c, fac);
        }

        facAccountMap = new Map<Financial_Account_Customer__c, Account>();
        Set<Id> facAccountIdKeySet = facAccountIdMap.KeySet();
        accountQuery += 'Id, IsPersonAccount, Name FROM Account WHERE Id IN : facAccountIdKeySet';
        for (Account acc : Database.Query(accountQuery)) {
            facAccountMap.put(facAccountIdMap.get(acc.Id), acc);
        }

        //Construct Form to Form-Field obj Dictionary
        formToFieldsMap = new Map<Form__c, List<Form_Field__c>>();
        for (Form_Field_Junction__c ffJunction : [SELECT Id, Form_Field__c, Form__c FROM Form_Field_Junction__c WHERE Form__c IN: formIdToObjMap.keySet()]) {
            if (formToFieldsMap.containsKey(formIdToObjMap.get(ffJunction.Form__c))) {
                formToFieldsMap.get(formIdToObjMap.get(ffJunction.Form__c)).add(ffIdToObjMap.get(ffJunction.Form_Field__c));
            } else {
                formToFieldsMap.put(formIdToObjMap.get(ffJunction.Form__c), new List<Form_Field__c> {ffIdToObjMap.get(ffJunction.Form_Field__c)});
            }
        }        

        //Fetch relevant fields and populate the document request
        this.watermark = ApexPages.currentPage().getParameters().get('watermark');
        docRequestFieldMap = Schema.SObjectType.Document_Request__c.fields.getMap();
        docRequestList = new List<Document_Request__c>();
        drLiNestedList = new List<List<Document_Request_Line_Item__c>>();

        for (Form__c form : formToFieldsMap.keySet()) {
            if (form.Copy_per_FAC__c) { //A copy for each of the FACs
                for (Financial_Account_Customer__c fCustomer : fCustomersList) {
                    populateDocRequest(form, fCustomer, formToFieldsMap);
                }
            } else { //Only a single copy for Primary Borrower.
                populateDocRequest(form, primaryBorrower, formToFieldsMap);
            }
            for (Third_Party__c tp : thirdPartyList) { //A copy of the form for each third party on the repossession
                generateDocForThirdParty(form, tp);
            }
        }
        
        for (Third_Party__c tp : thirdPartyList) { //A single cover letter per attorney
            if (tp.Attorney_Representing_Borrower__c != null) {
                generateCoverLetterForAttorney(tp);
            }
        }
        
        insert docRequestList;

        List<Document_Request_Line_Item__c> liDmlList = new List<Document_Request_Line_Item__c>();
        for (Integer i=0; i<drLiNestedList.size(); i++) {
            if (drLiNestedList.get(i) != null && !drLiNestedList.get(i).isEmpty()) {
                for (Document_Request_Line_Item__c lineItem : drLiNestedList.get(i)) {
                    lineItem.Document_Request__c = docRequestList.get(i).Id;
                    liDmlList.add(lineItem);
                }
            } 
        }

        if (!liDmlList.isEmpty()) {
            insert liDmlList;
        }

        // Check for notice of sale cases
        Case newChildCase;
        if (formRule.Post_RL_Notice_of_Sale__c && this.childCases.isEmpty()) { // MD child case is needed
            Form_Rule__c nosRule = [SELECT Id, Case_Record_Type__c, Name FROM Form_Rule__c WHERE State_of_Jurisdiction__c =: repo.State_of_Jurisdiction__c AND Salvage__c =: repo.Salvage__c 
                AND RecordTypeId =: RL_GenerateTestData.getRecordType('Form_Rule__c', 'RL Notice of Sale') LIMIT 1];
            QueueSObject queue = [SELECT Id, Queue.Name, Queue.Id from QueueSObject WHERE Queue.Name = 'Rights Letters' AND SObjectType = 'Case'];
            String website = '';
            try {
                website = [SELECT Id, Name, Website FROM Account WHERE Name =: this.repo.Auction_Agency_Name__c AND RecordType.Name = 'Auction'].Website;
            } catch (QueryException ex) {}
            newChildCase = new Case(Subject=repo.Financial_Account__r.Financial_Account_Number__c + ' - ' + nosRule.Name, ParentId = aCase.Id, Form_Rule__c = nosRule.Id, 
                OwnerId = queue.Queue.Id, BusinessHoursId=aCase.BusinessHoursId, RecordTypeId=RL_GenerateTestData.getRecordType('Case', nosRule.Case_Record_Type__c), 
                Financial_Account__c = aCase.Financial_Account__c, RL_Repo_Date__c=aCase.RL_Repo_Date__c, RL_Required_Notice_Date_Time__c=aCase.RL_Required_Notice_Date_Time__c,
                RL_Required_Service_Level_Date__c = aCase.RL_Required_Service_Level_Date__c, RL_State_of_Jurisdiction__c = aCase.RL_State_of_Jurisdiction__c, 
                RL_System_Required_Notice_Date_Time__c = aCase.RL_System_Required_Notice_Date_Time__c, RL_VIN__c = this.collateral.Vehicle_Identification_Number__c, 
                RL_Auction_Agency_Name__c = repo.Auction_Agency_Name__c, RL_Auction_Agency_Street1__c = repo.Auction_Agency_Street1__c, RL_Auction_Agency_Street2__c = repo.Auction_Agency_Street2__c, 
                RL_Auction_Agency_City__c = repo.Auction_Agency_City__c, RL_Auction_Agency_State__c = repo.Auction_Agency_State__c, RL_Auction_Agency_Zip__c = repo.Auction_Agency_Zip__c, 
                RL_Auction_Agency_Phone__c = repo.Auction_Agency_Phone__c, RL_Auction_Agency_URL__c = website);
            insert newChildCase;
        } else if (formRule.Post_RL_Notice_of_Sale__c && !this.childCases.isEmpty()) {
            childCases[0].Status = 'New';
            update childCases[0];
        }
    }

    /**
     * Generate a document request for third party.
     * For third party documents - The recipient fields will be those of the third party record.
     * Customer fields will be those of the primary borrower and a line item will be generated for each of the co-borrowers.
     */
    
    private void generateDocForThirdParty(Form__c form, Third_Party__c tp) {
        if (tp.Attorney_Representing_Borrower__c != null) { // Generate a Cover letter for the attorney and a letter for the FAC whom he represents
            Financial_Account_Customer__c targetFAC = findFAC(tp.Attorney_Representing_Borrower__c);

            //Generate form
            populateDocRequest(form, targetFAC, formToFieldsMap);            

        } else {  // Generate the form addressed to the third party without a cover letter
            populateDocRequest(form, primaryBorrower, formToFieldsMap);
            
            //Override the recipient fields on the doc request with the third party address info
            docRequest.Recipient_Address1__c = tp.Address1__c;
            docRequest.Recipient_Address2__c = tp.Address2__c;
            docRequest.Recipient_CityStateZipCode__c = tp.City_State_Zip_Code__c;
            docRequest.Recipient_NameLine1__c = tp.First_Name__c + ' ' + tp.Last_Name__c;
            docRequest.RL_IsReinstatementAllowed__c = false;
        }
    }

    /**
     * Generate a cover letter for third party attorneys
     * @param  Third_Party__c tp
     */
    private void generateCoverLetterForAttorney(Third_Party__c tp) {
        //generate the form field map for the cover letter
        Financial_Account_Customer__c targetFAC = findFAC(tp.Attorney_Representing_Borrower__c);        
        Form__c coverLetterForm = [SELECT Id, Name, Copy_per_FAC__c, Document_request_record_type__c, Document_Type__c FROM Form__c WHERE Name =: RL_Constants.COVER_LETTER_FORM];
        List<Id> coverLetterFFIds = new List<Id>();
        for (Form_Field_Junction__c coverLetterFFJunction : [SELECT Id, Form_Field__c FROM Form_Field_Junction__c WHERE Form__c =: coverLetterForm.Id]) {
            coverLetterFFIds.add(coverLetterFFJunction.Form_Field__c);
        }
        List<Form_Field__c> coverLetterFFs = [SELECT Id, Name, Source_Field__c, Target_Field__c, Source_Object__c, Primary_FAC__c, Line_item_field__c, Line_Item_Type__c FROM Form_Field__c WHERE Id IN: coverLetterFFIds];
        Map<Form__c, List<Form_Field__c>> attorneyFFMap = new Map<Form__c, List<Form_Field__c>>();
        attorneyFFMap.put(coverLetterForm, coverLetterFFs);

        //Generate cover letter & override recipient fields to third party fields
        populateDocRequest(coverLetterForm, targetFAC, attorneyFFMap);
        docRequest.Recipient_Address1__c = tp.Address1__c;
        docRequest.Recipient_Address2__c = tp.Address2__c;
        docRequest.Recipient_CityStateZipCode__c = tp.City_State_Zip_Code__c;
        docRequest.Recipient_NameLine1__c = tp.First_Name__c + ' ' + tp.Last_Name__c;
    }
    
    /**
     * [populateDocRequest]: Populates the docRequest sObj based on FF input
     * @param  {[type]} Form__c                            form                 the form to generate the doc request for
     * @param  {[type]} Financial_Account_Customer__c      fac                  the contextual FAC
     * @param  {[type]} Map<Form__c,                       List<Form_Field__c>> ffMap         A map of form to form field sObjects
     * @param  {[type]} Map<Financial_Account_Customer__c, Account>             facAccountMap A map of FAC to relevant Account sObject (differs for forms vs Cover letter)
     */
    private void populateDocRequest(Form__c form, Financial_Account_Customer__c fac, Map<Form__c, List<Form_Field__c>> ffMap) {
        docRequest = new Document_Request__c();
        docLiCoCustomers = new Document_Request_Line_Item__c();
        docLiCoverage1 = new Document_Request_Line_Item__c();
        docLiCoverage2 = new Document_Request_Line_Item__c();
        docRequestLiList = new List<Document_Request_Line_Item__c>();


        docRequest.RecordTypeId = RL_GenerateTestData.getRecordType('Document_Request__c', form.Document_request_record_type__c);

        if (this.childCase == null) { //Document Request
            docRequest.Repossession__c = repo.Id;
            docRequest.Case__c = repo.Case__c;        
        } else {    //Notice of Sale
            docRequest.Case__c = this.childCase.Id;
        }
        if (this.watermark != null && Boolean.valueOf(this.watermark)) {
            docRequest.WaterMarkText__c = 'REVISED';
            docRequest.IsWaterMarkRequired__c = true;
        }

        for (Form_Field__c ff : ffMap.get(form)) {
            if (ff.Source_Object__c.equalsIgnoreCase('Repossession__c')) {
                if (ff.Line_Item_Field__c && ff.Line_item_type__c.equalsIgnoreCase('Other Charges')) {
                    generateChargesLineItems(ff);
                } else if (!ff.Line_item_field__c) {
                    docRequest.put(ff.Target_Field__c, repo.get(ff.Source_Field__c));
                }
            } else if (ff.Source_Object__c.equalsIgnoreCase('Financial_Account__c')) {
                docRequest.put(ff.Target_Field__c, fAccount.get(ff.Source_Field__c));

            } else if (ff.Source_Object__c.equalsIgnoreCase('Case')) {
                docRequest.put(ff.Target_Field__c, aCase.get(ff.Source_Field__c));
            }  else if (ff.Source_Object__c.equalsIgnoreCase('Financial_Account_Customer__c')) { 
                    if (ff.Line_Item_Field__c && ff.Line_item_type__c.equalsIgnoreCase('Co-Customers')) {
                        for (Financial_Account_Customer__c faCustomer : fCustomersList) {
                            if (faCustomer.Id != this.primaryBorrower.Id) { //Exclude the Primary Borrower
                                docLiCoCustomers.Name = faCustomer.Name;
                                docLiCoCustomers.Type__c=ff.Line_Item_Type__c;
                                docLiCoCustomers.put(ff.Target_Field__c, faCustomer.get(ff.Source_Field__c));
                                addToLiList(docLiCoCustomers);
                            }
                        }
                } else if (!ff.Line_Item_Field__c) { //If FF is not a line item - the target sObject is Document_Request__c
                    if (ff.Primary_FAC__c) {
                        docRequest.put(ff.Target_Field__c, primaryBorrower.get(ff.Source_Field__c));
                    } else {
                        docRequest.put(ff.Target_Field__c, fac.get(ff.Source_Field__c));    
                    }
                }
            } else if (ff.Source_Object__c.equalsIgnoreCase('Collateral__c')) {
                docRequest.put(ff.Target_Field__c, collateral.get(ff.Source_Field__c));
            } else if (ff.Source_Object__c.equalsIgnoreCase('FAC Account')) {
                if (ff.Line_Item_Field__c && ff.Line_item_type__c.equalsIgnoreCase('Co-Customers')) {
                    generateCoCustomerLineItems(fac, ff);
                } else if (!ff.Line_Item_Field__c) { //If FF is not a line item - the target sObject is Document_Request__c
                    if (ff.Primary_FAC__c) {
                        docRequest.put(ff.Target_Field__c, facAccountMap.get(primaryBorrower).get(ff.Source_Field__c));
                    } else {
                        docRequest.put(ff.Target_Field__c, facAccountMap.get(fac).get(ff.Source_Field__c));     
                    }
                }
            } else if (ff.Source_Object__c.equalsIgnoreCase('Form__c')) {
                docRequest.put(ff.Target_Field__c, form.get(ff.Source_Field__c));
            } else if (ff.Source_Object__c.equalsIgnoreCase('NoS Case')) {
                docRequest.put(ff.Target_Field__c, this.childCase.get(ff.Source_Field__c));
            } else if (ff.Source_Object__c.equalsIgnoreCase('Dealership')) {
                docRequest.put(ff.Target_Field__c, this.dealership.get(ff.Source_Field__c));
            }
        }
        
        
        //Harendra Sain start for story #S-311647
            if((this.repo.recordType.name.equalsIgnoreCase(RECTYPE_REPOSSESSION_CA_IN_STATE) || this.repo.recordType.name.equalsIgnoreCase(RECTYPE_REPOSSESSION_CA_OUT_STATE)) && this.repo.Reinstatement_Denial_Reason__c == 'Bankruptcy Discharge - Filing Parties Only' && fac != Null && fac.RL_Bankruptcy_Status__c == 'Non Filing Party'){
                docRequest.put('RL_IsReinstatementAllowed__c',true);
                docRequest.put('RL_OtherReasonForRepossession__c',Null);                                            
            }
        //End
        
        docRequestList.add(docRequest);
        drLiNestedList.add(docRequestLiList);
    }

    /**
     * Generates "Co-Customers" line item to the doc request
     */
    private void generateCoCustomerLineItems(Financial_Account_Customer__c fac, Form_Field__c ff) {
        for (Financial_Account_Customer__c faCustomer : fCustomersList) {
            if (faCustomer.Id != this.primaryBorrower.Id) { //Exclude the Primary Borrower
                docLiCoCustomers.Name = faCustomer.Name;
                docLiCoCustomers.Type__c=ff.Line_Item_Type__c;
                if (!facAccountMap.get(faCustomer).isPersonAccount) { //Business Account
                    if (ff.Source_Field__c.equalsIgnoreCase('FirstName') || ff.Source_Field__c.equalsIgnoreCase('LastName')) {
                        docLiCoCustomers.put('CoCustomer_FirstName__c', facAccountMap.get(faCustomer).get('Name'));
                    } else { //Non-name related fields
                        docLiCoCustomers.put(ff.Target_Field__c, facAccountMap.get(faCustomer).get(ff.Source_Field__c));
                    }
                } else { //Person account
                    docLiCoCustomers.put(ff.Target_Field__c, facAccountMap.get(faCustomer).get(ff.Source_Field__c));
                }
                addToLiList(docLiCoCustomers);
            }
        } 
    }

    /**
     * Generates "Other Charges" line item to the doc request
     */
    private void generateChargesLineItems(Form_Field__c ff) {
        if (this.repo.get(ff.Source_Field__c) != null) {
            if (ff.Source_Field__c.containsIgnoreCase('Charges1')) {
                docLiCoverage1.Name = 'Other Charges 1';
                docLiCoverage1.Type__c = ff.Line_item_type__c;
                docLiCoverage1.put(ff.Target_Field__c, this.repo.get(ff.Source_Field__c));
                addToLiList(docLiCoverage1);
            } else if (ff.Source_Field__c.containsIgnoreCase('Charges2')) {
                docLiCoverage2.Name = 'Other Charges 2';
                docLiCoverage2.Type__c = ff.Line_item_type__c;
                docLiCoverage2.put(ff.Target_Field__c, this.repo.get(ff.Source_Field__c));
                addToLiList(docLiCoverage2);
            }
        }
    }

    /**
     * Add unique line items to the Doc request line item list.
     */    
    private void addToLiList(Document_Request_Line_Item__c docLi) {
        Set<Document_Request_Line_Item__c> liSet = new Set<Document_Request_Line_Item__c>();
        liSet.addAll(docRequestLiList);
        if (!liSet.contains(docLi)) {
            docRequestLiList.add(docLi);                
        }
    }

    /**
     * Search for an FAC Id in a list of FAC sObjects.
     */  
    private Financial_Account_Customer__c findFAC(Id facId) {
        for (Financial_Account_Customer__c fac : this.fCustomersList) {
            if (fac.Id == facId) {
                return fac;
            }
        }
        return null;
    }    
}