public with sharing class RL_AuctionLocationAddressController {
    
    public SelectOption[] auctionAcctsSelectOptions{get;set;}
    public String selectedAuctionAcct{get;set;}
    public String formattedAuctionLocationAddy{get;set;}
    
    public Case contextCase;
    
    
    public RL_AuctionLocationAddressController(ApexPages.StandardController stdController) {
        populateData(stdController);
    }
    
    
    private void populateData(ApexPages.StandardController stdController) {
    	if(!Test.isRunningTest()) {
    		stdController.addFields(new String[]{'RL_Auction_Agency_Name__c', 'RL_Auction_Agency_City__c', 'RL_Auction_Agency_State__c',
										'RL_Auction_Agency_Street1__c', 'RL_Auction_Agency_Street2__c', 'RL_Auction_Agency_Zip__c',
										'RL_Auction_Agency_Phone__c', 'RL_Auction_Agency_URL__c'});
    	}
        
        this.contextCase = (Case) stdController.getRecord();
        
        auctionAcctsSelectOptions = new SelectOption[]{};
        auctionAcctsSelectOptions.add(new SelectOption('', 'Select New Auction Location'));
        selectedAuctionAcct = '';
        for(Account acct : [select id, Name
                            from Account
                            where RecordType.Name = 'Auction'
                            order by Name])
        {
        	auctionAcctsSelectOptions.add( new SelectOption(acct.Id, acct.Name) );
        }
        
        formatAuctionLocationAddy();
    }
    
    
    
    private void formatAuctionLocationAddy() {
    	String addy = '';
    	
    	addy = appendAndReturnString(addy, contextCase.RL_Auction_Agency_Name__c, false, false, false);
    	addy = appendAndReturnString(addy, contextCase.RL_Auction_Agency_Street1__c, true, false, false);
    	addy = appendAndReturnString(addy, contextCase.RL_Auction_Agency_Street2__c, true, false, false);
    	if(contextCase.RL_Auction_Agency_City__c != null || contextCase.RL_Auction_Agency_State__c != null || contextCase.RL_Auction_Agency_Zip__c != null) {
    		addy += '<br />';
    	}
    	addy = appendAndReturnString(addy, contextCase.RL_Auction_Agency_City__c, false, false, false);
    	addy = appendAndReturnString(addy, contextCase.RL_Auction_Agency_State__c, false, true, true);
    	Boolean tmpPrependComma = false;
    	if(contextCase.RL_Auction_Agency_State__c == null && contextCase.RL_Auction_Agency_Zip__c != null) {
    		tmpPrependComma = true;
    	}
    	addy = appendAndReturnString(addy, contextCase.RL_Auction_Agency_Zip__c, false, tmpPrependComma, true);
    	
    	if(contextCase.RL_Auction_Agency_URL__c != null && contextCase.RL_Auction_Agency_URL__c != '') {
    		addy += '<br/>' + contextCase.RL_Auction_Agency_URL__c;  
    	}
    	
    	formattedAuctionLocationAddy = addy;
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
    
    
    
    public PageReference saveNewAuctionLocationAddress() {
    	
    	if(selectedAuctionAcct != null && selectedAuctionAcct != '') {
    		Account acct = [select id, Name, BillingPostalCode, BillingCity, BillingState, BillingStreet2__c, BillingStreet1__c, phone, Website
                            from Account
                            where id = :selectedAuctionAcct];
    		updateRepoValuesAfterValidationAndRevertIfFailure(acct);
    	}else{
    		appendErrorMessage('Select valid Auction Account');
    	}
    	
    	return null;
    }
    
    private void updateRepoValuesAfterValidationAndRevertIfFailure(Account acct) {
    	String parsedZip 		= contextCase.RL_Auction_Agency_Zip__c;
        String parsedCity		= contextCase.RL_Auction_Agency_City__c;
        String parsedState		= contextCase.RL_Auction_Agency_State__c;
        String parsedStreet2	= contextCase.RL_Auction_Agency_Street2__c;
        String parsedStreet1	= contextCase.RL_Auction_Agency_Street1__c;
        String parsedName 		= contextCase.RL_Auction_Agency_Name__c;
        String parsedPhone 		= contextCase.RL_Auction_Agency_Phone__c;
        String parsedUrl		= contextCase.RL_Auction_Agency_URL__c;
        try {
            //clear all.
            contextCase.RL_Auction_Agency_URL__c = contextCase.RL_Auction_Agency_Zip__c = contextCase.RL_Auction_Agency_City__c = contextCase.RL_Auction_Agency_State__c = contextCase.RL_Auction_Agency_Street2__c = contextCase.RL_Auction_Agency_Street1__c = contextCase.RL_Auction_Agency_Name__c = contextCase.RL_Auction_Agency_Phone__c = ''; 
            
            contextCase.RL_Auction_Agency_Zip__c = acct.BillingPostalCode;
        	contextCase.RL_Auction_Agency_City__c = acct.BillingCity;
        	contextCase.RL_Auction_Agency_State__c = acct.BillingState;
        	contextCase.RL_Auction_Agency_Street2__c = acct.BillingStreet2__c;
        	contextCase.RL_Auction_Agency_Street1__c = acct.BillingStreet1__c;
        	contextCase.RL_Auction_Agency_Name__c = acct.Name;
        	contextCase.RL_Auction_Agency_Phone__c = acct.Phone;
        	contextCase.RL_Auction_Agency_URL__c = acct.Website;
        	
        
            update contextCase; 
            
            formatAuctionLocationAddy();
            
        }catch(Exception e) {
            contextCase.RL_Auction_Agency_Zip__c = parsedZip;
        	contextCase.RL_Auction_Agency_City__c = parsedCity;
        	contextCase.RL_Auction_Agency_State__c = parsedState;
        	contextCase.RL_Auction_Agency_Street2__c = parsedStreet2;
        	contextCase.RL_Auction_Agency_Street1__c = parsedStreet1;
        	contextCase.RL_Auction_Agency_Name__c = parsedName;
        	contextCase.RL_Auction_Agency_Phone__c = parsedPhone;
        	contextCase.RL_Auction_Agency_URL__c = parsedUrl;
	        
	        formatAuctionLocationAddy();
	        
	        appendErrorMessage(e.getMessage());
        }
    }
    
    
    private void appendErrorMessage(String errorMessage) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
    
    
    
}