public with sharing class RL_ThirdPartyAttorneyRepController {
    private final Third_Party__c thirdParty;
    private String financialAccountId;
    
    public String representing {get;set;}
    
    // Fill picklist options with active FACs (borrowers) related to associated financial account - default is blank/Not an Attorney
    public List<SelectOption> getFACs() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Not an Attorney'));
        for (Financial_Account_Customer__c fac : [select Id, Name from Financial_Account_Customer__c where Financial_Account__c = :financialAccountId and Borrower_Status__c = 'Active' and RL_Bankruptcy_Status__c = 'Filing Party' order by Customer_Role_Type__c]){
            options.add(new SelectOption(fac.Id, fac.Name));
        }
        return options;
    }

    public RL_ThirdPartyAttorneyRepController(ApexPages.StandardController stdController){
        // Get context to set picklist to currently saved FAC value
        List<String> fieldsList = new List<String>();
        fieldsList.add('Financial_Account__c');
        fieldsList.add('Attorney_Representing_Borrower__r.Name');
        if (!Test.isRunningTest()) {
            stdController.addFields(fieldsList);
        }
        thirdParty = (Third_Party__c) stdController.getRecord();
        financialAccountId = thirdParty.Financial_Account__c;
        
        // Set picklist to currently saved FAC value or blank if not associated
        if (thirdParty.Attorney_Representing_Borrower__r.Name == null){
            representing = '';
        } else {
            representing = thirdParty.Attorney_Representing_Borrower__c;
        }
    }

    // Save any changes made in picklist to Attorney Representing Borrower lookup(FAC)
    public void saveRepresenting() {
        thirdParty.Attorney_Representing_Borrower__c = representing;
        update thirdParty;
    }
}