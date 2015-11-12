public with sharing class RL_TitleRequestAddressEditController {
    
    public SelectOption[] auctionAcctsSelectOptions{get;set;}
    public String selectedAuctionAcct{get;set;}
    public String formattedTitleAddress{get;set;}
    public String strPhoneNumber{get;set;}
    public boolean isCopy{get; set;}//Modified by Shashank Singhal for S-311648 on 6/1/2015 
    
    private Repossession__c contextRepo;
    
    public RL_TitleRequestAddressEditController(ApexPages.StandardController stdController) {
        isCopy = false;//Modified by Shashank Singhal for S-311648 on 6/1/2015 
        populateData(stdController);
    }
    
    private void populateData(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {   
            stdController.addFields(new String[] {'Case__r.Form_Rule__c', 'Case__c', 'iRepo_VIN__c', 'iRepo_AccountNumber__c', 
                                  'Financial_Account__c', 'State_of_jurisdiction__c', 'Title_Zip__c', 'Title_Street2__c', 
                                  'Title_Street1__c', 'Title_State__c', 'Title_Override__c', 'Title_Name__c', 'Title_City__c','Title_Phone__c',
                                  'Auction_Agency_Name__c', 'Auction_Agency_Street1__c', 'Auction_Agency_Street2__c', 'Auction_Agency_City__c', 
                                  'Auction_Agency_State__c', 'Auction_Agency_Zip__c'}); //Modified by Shashank Singhal for S-311648 on 6/1/2015 
        }
        contextRepo = (Repossession__c) stdController.getRecord();
        
        auctionAcctsSelectOptions = new SelectOption[]{};
        auctionAcctsSelectOptions.add(new SelectOption('', 'Select New Title Address'));
        selectedAuctionAcct = '';
        for(Account acct : [select id, Name
                            from Account
                            where RecordType.Name = 'Auction'
                            order by Name])
        {
            auctionAcctsSelectOptions.add( new SelectOption(acct.Id, acct.Name) );
        }
        strPhoneNumber = contextRepo.Title_Phone__c;
        formatTitleAddress();
    }
    
    private void formatTitleAddress() {
        String addy = '';
        
        //'', '', 
        //'', '', 'Title_Override__c', '', ''
        addy = appendAndReturnString(addy, contextRepo.Title_Name__c, false, false, false);
        addy = appendAndReturnString(addy, contextRepo.Title_Street1__c, true, false, false);
        addy = appendAndReturnString(addy, contextRepo.Title_Street2__c, true, false, false);
        if(contextRepo.Title_City__c != null || contextRepo.Title_State__c != null || contextRepo.Title_Zip__c != null) {
            addy += '<br />';
        }
        addy = appendAndReturnString(addy, contextRepo.Title_City__c, false, false, false);
        addy = appendAndReturnString(addy, contextRepo.Title_State__c, false, true, true);
        Boolean tmpPrependComma = false;
        if(contextRepo.Title_State__c == null && contextRepo.Title_Zip__c != null) {
            tmpPrependComma = true;
        }
        addy = appendAndReturnString(addy, contextRepo.Title_Zip__c, false, tmpPrependComma, true);
        
        formattedTitleAddress = addy;
    }
    
    private String appendAndReturnString(String strToReturn, String valToAppend, Boolean prependLineFeed, Boolean prependComma, Boolean prependSpace) {
        
        if(valToAppend != null && valToAppend != '') {
            if(prependLineFeed) {
                strToReturn += '<br />';
            }
            if(prependComma) {
                strToReturn += ',';
            }
            if(prependSpace) {
                strToReturn += ' ';
            }
            strToReturn += valToAppend;
        }
        
        return strToReturn;
    }
    
    public PageReference saveNewAccountValues() {
        
        if(selectedAuctionAcct != null && selectedAuctionAcct != '') {
            Account acct = [select id, Name, BillingPostalCode, BillingCity, BillingState, BillingStreet, Phone
                            from Account
                            where id = :selectedAuctionAcct];
            updateRepoValuesAfterValidationAndRevertIfFailure(acct);
        }else{
            appendErrorMessage('Select valid Auction Account');
        }
        
        return null;
    }
    
    private void updateRepoValuesAfterValidationAndRevertIfFailure(Account acct) {
        String parsedZip = contextRepo.Title_Zip__c;
        String parsedCity = contextRepo.Title_City__c;
        String parsedState = contextRepo.Title_State__c;
        String parsedStreet2 = contextRepo.Title_Street2__c;
        String parsedStreet1 = contextRepo.Title_Street1__c;
        String parsedName = contextRepo.Title_Name__c;
        String parsedPhone = contextRepo.Title_Phone__c;
        try {
            //clear all.
            contextRepo.Title_Zip__c = contextRepo.Title_City__c = contextRepo.Title_State__c = contextRepo.Title_Street2__c = contextRepo.Title_Street1__c = contextRepo.Title_Name__c = contextRepo.Title_Phone__c = '';
            
            String addy1 = '';
            String addy2 = '';
            
            if(acct.BillingStreet != null && acct.BillingStreet.length() > 0) {
                List<String> strList = acct.BillingStreet.split('\n');
                addy1 = strList[0];
                if(strList.size() > 1) {
                    addy2 = strList[1];
                }
            }
            
            contextRepo.Title_Zip__c = acct.BillingPostalCode; 
            contextRepo.Title_City__c = acct.BillingCity; 
            contextRepo.Title_State__c = acct.BillingState; 
            contextRepo.Title_Street2__c = addy2; 
            contextRepo.Title_Street1__c = addy1; 
            contextRepo.Title_Name__c = acct.Name;
            contextRepo.Title_Override__c = true;
            contextRepo.Title_Phone__c = acct.Phone;
            System.Debug('**Phone:' +contextRepo.Title_Phone__c);
            System.Debug('**City:' +contextRepo.Title_City__c);
            
            update contextRepo; 
            
            strPhoneNumber = contextRepo.Title_Phone__c;
            formatTitleAddress();
            
        }catch(Exception e) {
            contextRepo.Title_Zip__c = parsedZip;
            contextRepo.Title_City__c = parsedCity;
            contextRepo.Title_State__c = parsedState;
            contextRepo.Title_Street2__c = parsedStreet2;
            contextRepo.Title_Street1__c = parsedStreet1;
            contextRepo.Title_Name__c = parsedName;
            contextRepo.Title_Override__c = false;
            contextRepo.Title_Phone__c = parsedPhone;

            formatTitleAddress();
            
            appendErrorMessage(e.getMessage());
        }
    }
    
    private void appendErrorMessage(String errorMessage) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
    //Modified by Shashank Singhal for S-311648 on 6/1/2015 
    public void copyVendorInformation(){
        try{
            contextRepo.Auction_Agency_Name__c = contextRepo.Title_Name__c;
            contextRepo.Auction_Agency_Street1__c = contextRepo.Title_Street1__c;
            contextRepo.Auction_Agency_Street2__c = contextRepo.Title_Street2__c;
            contextRepo.Auction_Agency_City__c = contextRepo.Title_City__c;
            contextRepo.Auction_Agency_State__c = contextRepo.Title_State__c;
            contextRepo.Auction_Agency_Zip__c = contextRepo.Title_Zip__c;
            contextRepo.Auction_Agency_Phone__c = contextRepo.Title_Phone__c;
            update contextRepo;
            isCopy = true;
        }catch(exception e){
            appendErrorMessage(e.getMessage());
        }
    }
    //End of S-311648
}