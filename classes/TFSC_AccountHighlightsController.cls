public with sharing class TFSC_AccountHighlightsController {
    
    public String borrowerPhoneFromJS{get;set;}
    public String coBorrowerWasPoppedBooleanStringFromJS{get;set;}
    public String borrowersFinancialAccountsUnderCollectionsCommaDelimited{get;set;}
    
    public Boolean enableTopSectionRelatedFALink{get;set;}
    public Boolean enableBottomSectionRelatedFALink{get;set;}
    public List<FaWrapperSmall> listOfSectionRelatedFAs{get;set;}
    
    private List<FaWrapperSmall> listOfTopSectionRelatedFAs{get;set;}
    
    private List<FaWrapperSmall> listOfBottomSectionRelatedFAs{get;set;}
    
    public Financial_Account__c contextFinancialAccount{get;set;}
    public Map<String,String> mapOfPhoneNumberToCoBorrowerFACs{get;set;}
    public Map<String,String> mapOfPhoneNumberToPrimaryFAC{get;set;}
    private Financial_Account_Customer__c primaryBorrowerFAC;
    
    public Financial_Account_Customer__c topSectionFAC{get;set;}
    public List<Boolean> listDisplayTopSectionFACNumbers{get; set;}
    public Financial_Account_Customer__c bottomSectionFAC{get;set;}
    
    public TimeZoneDetails timeZoneMapping{get;set;}
    
    public Integer topSectionOpenOtherAccountCount{get;set;}
    public Integer topSectionClosedOtherAccountCount{get;set;}
    public Integer bottomSectionOpenOtherAccountCount{get;set;}
    public Integer bottomSectionClosedOtherAccountCount{get;set;}
    public Boolean displayRelatedFAsPopup {get;set;}
    
    
    public PageReference showTopPopup(){
        listOfSectionRelatedFAs = listOfTopSectionRelatedFAs;
        displayRelatedFAsPopup = true;
        return null;
    }
    
    public PageReference showBottomPopup(){
        listOfSectionRelatedFAs = listOfBottomSectionRelatedFAs;
        displayRelatedFAsPopup = true;
        return null;
    }
    
    public PageReference closePopup(){
        displayRelatedFAsPopup = false;
        return null;
    }
    
    private String contextRecordId {
        get {
            return ApexPages.currentPage().getParameters().get('Id');
        }
    }
    
    
    
    public TFSC_AccountHighlightsController() {
        initDisplayRelatedFAsPopup();
        populateData();
    }
    
    private Boolean canExecuteGetters() {
        if(contextRecordId == null || contextRecordId.length() < 15) {
            appendErrorMessage('Invalid Context Record ID.');
            return false;
        }
        
        return true;
    }
    
    private void appendErrorMessage(String errorMessage) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
    private void appendErrorMessage(Exception e) {
        appendErrorMessage( e.getMessage() );
    }
    
    private void initDisplayRelatedFAsPopup(){
        enableTopSectionRelatedFALink = false;
        enableBottomSectionRelatedFALink = false;
        displayRelatedFAsPopup = false;
    }
    
    
    /**
    *  @This method is also called on "screen-pop" when number dialed (see updateTopFac())
    */
    private void populateData() {
        
        borrowersFinancialAccountsUnderCollectionsCommaDelimited = '';
        
        if(canExecuteGetters()) {
            populateContextFA();
            
            populateMapOfPhoneNumberToFAC();
            populatePrimaryBorrowerFAC();
            populateCorrectTopAndBottomFACust();
            
            populateOtherAccountRecordCounts();
            
            populateFAsInCollectionForContactedBorrower();
            
            populateTimeZoneMappings();
        }
    }
    
    /**
    *  @This method only appends coborrower numbers because, 
    *  @  there is no need to do anything differently when a primary is in context (on the phone). 
    *
    */
    private void populateMapOfPhoneNumberToFAC() {
    	if(contextFinancialAccount == null)
    		return;
    	
    	
        mapOfPhoneNumberToCoBorrowerFACs = new Map<String,String>();
        mapOfPhoneNumberToPrimaryFAC = new Map<String,String>();
        for(Financial_Account_Customer__c fac : [select id, Work_Phone_Garage__c, Mobile_Phone__c, Home_Phone_Garage__c, HomePhone_BillTo__c, Work_Phone_Bill_To__c 
                                                   from Financial_Account_Customer__c
                                                   where Financial_Account__c = :contextFinancialAccount.id
                                                   and Borrower_Position__c <> 'Primary'
                                                   and (not Financial_Account_Customer__c like '%Inactive%')]) 

        {
            if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Garage__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( fac.Work_Phone_Garage__c.replaceAll('[^0-9]',''), fac.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(fac.Mobile_Phone__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( fac.Mobile_Phone__c.replaceAll('[^0-9]',''), fac.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(fac.Home_Phone_Garage__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( fac.Home_Phone_Garage__c.replaceAll('[^0-9]',''), fac.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Bill_To__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( fac.Work_Phone_Bill_To__c.replaceAll('[^0-9]',''), fac.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(fac.HomePhone_BillTo__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( fac.HomePhone_BillTo__c.replaceAll('[^0-9]',''), fac.Id );
            }
        }
        
        for(Financial_Account_Customer__c facP : [select id, Work_Phone_Garage__c, Mobile_Phone__c, Home_Phone_Garage__c, Work_Phone_Bill_To__c, HomePhone_BillTo__c
                                                   from Financial_Account_Customer__c
                                                   where Financial_Account__c = :contextFinancialAccount.id
                                                   and Borrower_Position__c = 'Primary'
                                                   and (not Financial_Account_Customer__c like '%Inactive%')]) 

        {
            if( !TFSC_Utils.isNullOrEmpty(facP.Work_Phone_Garage__c) ){
                mapOfPhoneNumberToPrimaryFAC.put( facP.Work_Phone_Garage__c.replaceAll('[^0-9]',''), facP.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(facP.Mobile_Phone__c) ){
                mapOfPhoneNumberToPrimaryFAC.put( facP.Mobile_Phone__c.replaceAll('[^0-9]',''), facP.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(facP.Home_Phone_Garage__c) ){
                mapOfPhoneNumberToPrimaryFAC.put( facP.Home_Phone_Garage__c.replaceAll('[^0-9]',''), facP.Id );
            }
            
            if( !TFSC_Utils.isNullOrEmpty(facP.Work_Phone_Bill_To__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( facP.Work_Phone_Bill_To__c.replaceAll('[^0-9]',''), facP.Id );
            }
            if( !TFSC_Utils.isNullOrEmpty(facP.HomePhone_BillTo__c) ){
                mapOfPhoneNumberToCoBorrowerFACs.put( facP.HomePhone_BillTo__c.replaceAll('[^0-9]',''), facP.Id );
            }
        }
    }
    
    private void populateFAsInCollectionForContactedBorrower() {
        borrowersFinancialAccountsUnderCollectionsCommaDelimited = '';
        
        //borrowerPhoneFromJS
        if(topSectionFAC != null) {
            
            Map<Id,Financial_Account_Customer__c> facMapByFaId = new Map<Id,Financial_Account_Customer__c>();
            for(Financial_Account_Customer__c fac : [select id, Financial_Account__c, 
                                                          Financial_Account__r.Financial_Account_Number__c
                                                      from Financial_Account_Customer__c
                                                      where Account__c = :topSectionFAC.Account__c 
                                                      and id <> :topSectionFAC.Id
                                                      and (not Financial_Account_Customer__c like '%Inactive%')
                                                      and Financial_Account__r.Collection_List_Status_1__c != 'C'
                                                      ])
            {
                facMapByFaId.put(fac.Financial_Account__c, fac);
            }
            
            if( !facMapByFaId.isEmpty() ) {
                //IsClosed = False //Financial_Account__r.Finance_Account_Status__c == 'Close'
                for(Case caseRecord : [select id, Financial_Account__c from Case
                                       where Financial_Account__c in :facMapByFaId.keySet()
                                       and Case.RecordType.Name = 'Collection'
                                       and IsClosed = false
                                       ]) 
                {
                    Financial_Account_Customer__c facTemp = facMapByFaId.get(caseRecord.Financial_Account__c);
                    if(facTemp != null) {
                        if(borrowersFinancialAccountsUnderCollectionsCommaDelimited.length() > 0) {
                            borrowersFinancialAccountsUnderCollectionsCommaDelimited += ',';
                        }
                        borrowersFinancialAccountsUnderCollectionsCommaDelimited += facTemp.Financial_Account__c ;
                        borrowersFinancialAccountsUnderCollectionsCommaDelimited += '|';
                        borrowersFinancialAccountsUnderCollectionsCommaDelimited += facTemp.Financial_Account__r.Financial_Account_Number__c ;
                    }
                }
                
            }
        }
    }
    
    private void populateOtherAccountRecordCounts() {
        bottomSectionClosedOtherAccountCount = 0;
        bottomSectionOpenOtherAccountCount = 0;
        topSectionClosedOtherAccountCount = 0;
        topSectionOpenOtherAccountCount = 0;
        List<Id> topSectionOtherAccountIds = new List<Id>();
        List<Id> bottomSectionOtherAccountIds = new List<Id>();
        
        String bottomSectionSSN = '';
        String bottomSectionTIN = '';
        if(bottomSectionFAC != null) {
        	if(bottomSectionFAC.Account__r.Social_Security_Number__pc != null) {
        		bottomSectionSSN = bottomSectionFAC.Account__r.Social_Security_Number__pc;
        	}
        	if(bottomSectionFAC.Account__r.Tax_Identification_Number__c != null) {
        		bottomSectionTIN = bottomSectionFAC.Account__r.Tax_Identification_Number__c;
        	}
        }
        bottomSectionSSN = cleanOutBadSSNs(bottomSectionSSN);
        bottomSectionTIN = cleanOutBadSSNs(bottomSectionTIN);
        
        
        if(bottomSectionFAC != null && (bottomSectionSSN != '' || bottomSectionTIN != '')) {
            for(Financial_Account_Customer__c fac : [select id, Financial_Account__r.Finance_Account_Status__c, Financial_Account__c
                                                        from Financial_Account_Customer__c
                                                        where (
                                                            (Account__r.Social_Security_Number__pc <> '' and Account__r.Social_Security_Number__pc = :bottomSectionSSN)
                                                            or 
                                                            (Account__r.Tax_Identification_Number__c  <> '' and Account__r.Tax_Identification_Number__c = :bottomSectionTIN)
                                                        )
                                                        and id <> :bottomSectionFAC.Id
                                                        and (not Financial_Account_Customer__c like '%Inactive%')
                                                        limit 100])
            {
                System.debug('**************** fac: '+fac);
                bottomSectionOtherAccountIds.add(fac.Financial_Account__c);
                if(fac.Financial_Account__r.Finance_Account_Status__c == 'Open') {
                    bottomSectionOpenOtherAccountCount++;
                }else if(fac.Financial_Account__r.Finance_Account_Status__c == 'Close') {
                    bottomSectionClosedOtherAccountCount++;
                }
            }
            if(bottomSectionOpenOtherAccountCount > 0 || bottomSectionClosedOtherAccountCount > 0){
                enableBottomSectionRelatedFALink = true;
            }
            setRelatedFAsAndCollaterals(bottomSectionOtherAccountIds, 'BOTTOM');
        }
        
        String topSectionSSN = '';
        String topSectionTIN = '';
        if(topSectionFAC != null) {
        	if(topSectionFAC.Account__r.Social_Security_Number__pc != null) {
        		topSectionSSN = topSectionFAC.Account__r.Social_Security_Number__pc;
        	}
        	if(topSectionFAC.Account__r.Tax_Identification_Number__c != null) {
        		topSectionTIN = topSectionFAC.Account__r.Tax_Identification_Number__c;
        	}
        }
        topSectionSSN = cleanOutBadSSNs(topSectionSSN);
        topSectionTIN = cleanOutBadSSNs(topSectionTIN);
        
        if(topSectionFAC != null && (topSectionSSN != '' || topSectionTIN != '')) {
            for(Financial_Account_Customer__c fac : [select id, Financial_Account__r.Finance_Account_Status__c, Financial_Account__c
                                                        from Financial_Account_Customer__c
                                                        where (
                                                            (Account__r.Social_Security_Number__pc <> '' and Account__r.Social_Security_Number__pc = :topSectionFAC.Account__r.Social_Security_Number__pc)
                                                            or 
                                                            (Account__r.Tax_Identification_Number__c  <> '' and Account__r.Tax_Identification_Number__c = :topSectionFAC.Account__r.Tax_Identification_Number__c)
                                                            )
                                                        and id <> :topSectionFAC.Id
                                                        and (not Financial_Account_Customer__c like '%Inactive%')
                                                        limit 100])
            {
                topSectionOtherAccountIds.add(fac.Financial_Account__c);
                if(fac.Financial_Account__r.Finance_Account_Status__c == 'Open') {
                    topSectionOpenOtherAccountCount++;
                }else if(fac.Financial_Account__r.Finance_Account_Status__c == 'Close') {
                    topSectionClosedOtherAccountCount++;
                }
            }
            
            if(topSectionOpenOtherAccountCount > 0 || topSectionClosedOtherAccountCount > 0){
                enableTopSectionRelatedFALink = true;
            }
            setRelatedFAsAndCollaterals(topSectionOtherAccountIds, 'TOP');
        }
    }
    
    private String cleanOutBadSSNs(String ssn) {
    	//if(ssn == '999999999') {
        if(Pattern.matches('(0{9}|1{9}|2{9}|3{9}|4{9}|5{9}|6{9}|7{9}|8{9}|9{9})',ssn)){
    		ssn = '';
    	}
    	return ssn;
    }
    
    private void populateTimeZoneMappings() {
    	TimeZone_Indicator__c tmpTZIndicator;
    	timeZoneMapping = new TimeZoneDetails();
    	Integer shortZipCode;
    	String zipCode;
    	
    	if(bottomSectionFAC != null && bottomSectionFAC.Mailing_Postal_Code_Garage__c != null && bottomSectionFAC.Mailing_Postal_Code_Garage__c.length() > 0) {
    		zipCode = bottomSectionFAC.Mailing_Postal_Code_Garage__c;
    		shortZipCode = null;
    		if(zipCode.length() <= 5) {
    			shortZipCode = Integer.valueOf(zipCode);
    		}else{
    			shortZipCode = Integer.valueOf(zipCode.substring(0, 5));
    		}
    		
    		if(shortZipCode != null && shortZipCode > 0) {
    			tmpTZIndicator = TFSC_Utils.getTimeZoneIndicatorForTimeZone(shortZipCode);
	    		timeZoneMapping.bottomFacTimeZone = (tmpTZIndicator == null || tmpTZIndicator.Standard_Abbreviation__c == null) ? '' : tmpTZIndicator.Standard_Abbreviation__c ;
    		}
    	}
    	
    	if(topSectionFAC != null && topSectionFAC.Mailing_Postal_Code_Garage__c != null && topSectionFAC.Mailing_Postal_Code_Garage__c.length() > 0) {
    		zipCode = topSectionFAC.Mailing_Postal_Code_Garage__c;
    		shortZipCode = null;
    		if(zipCode.length() <= 5) {
    			shortZipCode = Integer.valueOf(zipCode);
    		}else{
    			shortZipCode = Integer.valueOf(zipCode.substring(0, 5));
    		}
    		
    		if(shortZipCode != null && shortZipCode > 0) {
    			tmpTZIndicator = TFSC_Utils.getTimeZoneIndicatorForTimeZone(shortZipCode);
	    		timeZoneMapping.topFacTimeZone = (tmpTZIndicator == null || tmpTZIndicator.Standard_Abbreviation__c == null) ? '' : tmpTZIndicator.Standard_Abbreviation__c ;
    		}
    	}
    	
    }
    
    public void setRelatedFAsAndCollaterals(List<Id> relatedAccountIds, String sectionPosition){
        
        List<FaWrapperSmall> tempList = new List<FaWrapperSmall>();
        
        for(Financial_Account__c fa : [ SELECT Id, Finance_Account_Status__c, Financial_Account_Number__c,
        								Collateral__c, Collateral__r.Model_Year__c, Collateral__r.Make__c, Collateral__r.Model_Name__c
        								FROM Financial_Account__c
        								WHERE Id in :relatedAccountIds
        								ORDER BY Finance_Account_Status__c desc NULLS LAST ])
		{
			tempList.add( new FaWrapperSmall(fa) );
		}
        
        
        if(sectionPosition.equals('TOP')){
            listOfTopSectionRelatedFAs = tempList;
        }else if(sectionPosition.equals('BOTTOM')){
            listOfBottomSectionRelatedFAs = tempList;
        }
    }
    
    
    private void populateCorrectTopAndBottomFACust() {
        try {
            Financial_Account_Customer__c[] facList;
            facList = [select id, Borrower_Position__c, Account__c, 
                        Account__r.Name, Account__r.IsPersonAccount, Account__r.Tax_Identification_Number__c, 
                        Account__r.Social_Security_Number__pc, Account__r.RecordType.Name,
                        Financial_Account__r.RecordType.Name, 
                        Account__r.AKA__c,
                        Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                        Flag_Home_Phone_IsMobile_BillTo__c, Flag_Work_Phone_Is_Mobile_BillTo__c,
                        Flag_Home_Phone_IsMobile_Garage__c, 
                        Election_Language_Preference__c, HomePhone_BillTo__c,
                        Home_Phone_Garage__c, Home_Phone_No_Call_Reason_Code_Garage__c,
                        Home_Phone_No_Call_Reason_Code_BillTo__c, Mobile_Phone__c,
                        Mobile_Phone_No_Call_Reason_Code__c, Work_Phone_Bill_To__c,
                        Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c, 
                        Work_Phone_No_Call_Reason_Code_Bill_To__c, Mailing_Street_BillTo__c, Mailing_City_BillTo__c,
                        Mailing_State_BillTo__c, Mailing_PostalCode_BillTo__c,
                        Mailing_City_Garage__c, Mailing_Street_Garage__c, Mailing_State_Garage__c,
                        Mailing_Postal_Code_Garage__c
                       from Financial_Account_Customer__c
                       where Borrower_Position__c = 'Co-X'
                       and Financial_Account__c = :contextFinancialAccount.Id
                       and (not Financial_Account_Customer__c like '%Inactive%') ];
            
            Financial_Account_Customer__c facCoXFromDialedPhoneNumber = getFacCoXFromDialedPhoneNumber(facList);
            Financial_Account_Customer__c facPRIFromDialedPhoneNumber;
            
            Boolean coBorrowerTrueFromScreenPop = false;
            if(coBorrowerWasPoppedBooleanStringFromJS != null && coBorrowerWasPoppedBooleanStringFromJS == 'true') {
                coBorrowerTrueFromScreenPop = true;
            }
            
            if(primaryBorrowerFAC != null && borrowerPhoneFromJS != null && borrowerPhoneFromJS.length() > 0) {
                 String tmpFaid = mapOfPhoneNumberToPrimaryFAC.get(borrowerPhoneFromJS);
                 if(tmpFaid != null) {
                    facPRIFromDialedPhoneNumber = primaryBorrowerFAC;
                 }
            }
            
            
            //this is saying, IF there was a match on phone for primary FAC or there wasn't a match on coX, then set topFAC to primaryFAC.
            if(coBorrowerTrueFromScreenPop == false && (facPRIFromDialedPhoneNumber != null || facCoXFromDialedPhoneNumber == null) ){
                topSectionFAC = primaryBorrowerFAC; //default fac for multiple FAC match on phone number.
                
                if(facList != null && facList.size() > 0) {
                    bottomSectionFAC = facList[0];
                }
            }else {
                bottomSectionFAC = primaryBorrowerFAC;
                
                if(facCoXFromDialedPhoneNumber != null) {
                    topSectionFAC = facCoXFromDialedPhoneNumber;
                }else if(facList.size() > 0){
                    topSectionFAC = facList[0];
                }
            }
            
            listDisplayTopSectionFACNumbers = TFSC_Utils.getListDisplayFACNumbers(topSectionFAC);
        }
        catch (Exception e) {
            appendErrorMessage(e);
        }
    }
    
    private Financial_Account_Customer__c getFacCoXFromDialedPhoneNumber(Financial_Account_Customer__c[] facList) {
        Financial_Account_Customer__c facToReturn;
        if(facList != null && facList.size() > 0 && borrowerPhoneFromJS != null && borrowerPhoneFromJS.length() > 0) {
            for(Financial_Account_Customer__c fac : facList) {
                if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Garage__c) ){
                    if(fac.Work_Phone_Garage__c.replaceAll('[^0-9]','').contains(borrowerPhoneFromJS)) {
                        facToReturn = fac;
                    }
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Mobile_Phone__c) ){
                    if(fac.Mobile_Phone__c.replaceAll('[^0-9]','').contains(borrowerPhoneFromJS)) {
                        facToReturn = fac;
                    }
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Home_Phone_Garage__c) ){
                    if(fac.Home_Phone_Garage__c.replaceAll('[^0-9]','').contains(borrowerPhoneFromJS)) {
                        facToReturn = fac;
                    }
                }
                if(facToReturn != null) {
                    break;
                }
            }
        }
        return facToReturn;
    }
    
    private void populateContextFA() {
        
        try {
            contextFinancialAccount = [select id, Past_Due_Charges__c, Payment_Amount_Past_Due__c, Charges_Late__c,
                                    RecordType.Name, Financial_Account_Number__c,
                                    Charges_Miscellaneous__c, Payment_Amount_Scheduled__c, Partial_Payment_Option__c,
                                    Coll_Num_Months_Past_Due__c,
                                    History_Counter_Fifteen_Days_Past_Due__c, History_Counter_Thirty_Days_PastDue__c,
                                    History_Counter_SixtyDaysPastDue__c, History_Counter_Days_Past_Due__c,
                                    Payment_Date_Past_Due__c, Total_Amount_Due__c, 
                                    History_Counter_Ninety_Days_Past_Due__c, Payment_Date_Last__c, Payment_Amount_Last__c,
                                    History_Counter_Non_Sufficient_Funds__c,
                                    Collateral__c, Collateral__r.Model_Year__c, Collateral__r.Make__c, Collateral__r.Model_Name__c
                                from Financial_Account__c
                                where id = :contextRecordId];
                                //(select Id, Model_Year__c, Make__c, Model_Name__c
                                    //from Assets)
        }
        catch (Exception e) {
            appendErrorMessage('Financial Account record not found.');
        }
        
            
    }
    
    private void populatePrimaryBorrowerFAC() {
        
        try {
            primaryBorrowerFAC = [select id, Borrower_Position__c, Account__c, 
                                    Account__r.Name, Account__r.IsPersonAccount, Account__r.Tax_Identification_Number__c, 
                                    Account__r.Social_Security_Number__pc, Account__r.RecordType.Name, 
                                    Financial_Account__r.RecordType.Name,
                                    Account__r.AKA__c,
                                    Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                                    Flag_Home_Phone_IsMobile_BillTo__c, Flag_Work_Phone_Is_Mobile_BillTo__c,
                                    Flag_Home_Phone_IsMobile_Garage__c, 
                                    Election_Language_Preference__c, HomePhone_BillTo__c,
                                    Home_Phone_Garage__c, Home_Phone_No_Call_Reason_Code_Garage__c,
                                    Home_Phone_No_Call_Reason_Code_BillTo__c, Mobile_Phone__c,
                                    Mobile_Phone_No_Call_Reason_Code__c, Work_Phone_Bill_To__c,
                                    Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                                    Work_Phone_No_Call_Reason_Code_Bill_To__c, Mailing_Street_BillTo__c, Mailing_City_BillTo__c,
                                    Mailing_State_BillTo__c, Mailing_PostalCode_BillTo__c,
                                    Mailing_City_Garage__c, Mailing_Street_Garage__c, Mailing_State_Garage__c,
                                    Mailing_Postal_Code_Garage__c
                                   from Financial_Account_Customer__c
                                   where Borrower_Position__c = 'Primary'
                                   and Financial_Account__c = :contextFinancialAccount.Id
                                   and (not Financial_Account_Customer__c like '%Inactive%')
                                   limit 1]; 
        }
        catch (Exception e) {
            appendErrorMessage('There is no Primary Borrower');
        }
            
        
    }
    
    
    
    public PageReference updateTopFac() {
        
        populateData();
        
        
        return null;
    }
    
    
    
    public class TimeZoneDetails {
        
        public String topFacTimeZone{get;set;}
        public String bottomFacTimeZone{get;set;}
    	
    	public TimeZoneDetails() {
    		
    	}
    
    }
    
    
    public class FaWrapperSmall {
        
        public String recordId{get;set;}
        public String Finance_Account_Status{get;set;}
        public String Financial_Account_Number{get;set;}
        public String Collateral{get;set;}
        public String Collateral_Model_Year{get;set;}
        public String Collateral_Make{get;set;}
        public String Collateral_Model_Name{get;set;}
        
    	
    	public FaWrapperSmall(Financial_Account__c fa) {
    		recordId 				= fa.Id;
	        Finance_Account_Status 	= fa.Finance_Account_Status__c; 
	        Financial_Account_Number = fa.Financial_Account_Number__c;
			Collateral 				= fa.Collateral__c;
			Collateral_Model_Year 	= fa.Collateral__r.Model_Year__c;
			Collateral_Make 		= fa.Collateral__r.Make__c;
			Collateral_Model_Name 	= fa.Collateral__r.Model_Name__c;
    	}
    
    }
    
    
}