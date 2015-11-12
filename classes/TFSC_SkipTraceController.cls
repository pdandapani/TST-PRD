/**
 *  The bigest thing to note with this controller is that in order to optimize the rendering speed,
 *  some variables were populated post load w/ a public PageReference method
 *   (see initializeNewSkipTraceRecordAndPopulateData both in TFSC_SkipTrace.page, and in this controller).
 *  
 *  Also, phone number records and address history records are actually fields on the skip trace.
 *  This was done to save the client $.
 *  So, on a save of address records, for example, see updateAndSaveAddressValuesFromAddyList() to view how this works.
 *  The same is true for PhoneNumber objects -- see updateAndOrderPhoneList().
 *  
 * 
 */


global with sharing class TFSC_SkipTraceController {
    
    public List<SelectOption> passStrategySelectOptions{get;set;}
    public String passStratLabel{get;set;}
    public Financial_Account_Customer__c contextFac{get;set;}
    public Financial_Account_Customer__c primaryFac{get;set;}
    public List<Boolean> listDisplayContextFACNumbers{get; set;}
    public Financial_Account__c contextFinancialAccount{get;set;}
    public Skip_Trace__c contextSkipTrace{get;set;}
    
    public Boolean isCallingWindowOpen = true;
    
    public List<SelectOption> accuintSelectOptions{get;set;}
    public List<SelectOption> fastDataSearchSelectOptions{get;set;}
    
    public List<SelectOption> addressSourceSelectOptions{get;set;}
    public List<SelectOption> phoneSourceSelectOptions{get;set;}
    public List<SelectOption> phoneTypeSelectOptions{get;set;}
    public List<SelectOption> phoneStatusSelectOptions{get;set;}
    
    public String borrowerPhoneFromJS{get;set;}
    public String coBorrowerWasPoppedBooleanStringFromJS{get;set;}
    public String saveResponse{get;set;}
    public String saveJsonRequest{get;set;}
    public string fAccType{get; set;}//Modified by Shashank Singhal for S-330388 on 06/29/2015
    public integer previousPass{get; set;}//Modified by Shashank Singhal for S-330388
    /**
    *  responseCount is a mechanism put in place to evaluate an issue where session state seems to change in the console.
    *  The purpose is three-fold
    *   1) to evaluate whether or not the VF re-render has occurred (and has successfully incremented the responseCount).
    *   2) to evaluate if a timeout or network failure has occurred on the actionFunction call.
    *   3) to evaluate if, for some reason, some variables were reset/refreshed for an unknown reason (controller re-initialization [re-hitting the constructor] that has been seen in the console).
    *  For more details, search for 'parsedResponseCount' on the vf page.
    */
    public Integer responseCount{get;set;}
    public String selectedPassStrategy{get;set;}
    public String knowledgeArticleText{get;set;}
    public String saveAddyResponse{get;set;}
    public String saveAddyJsonRequest{get;set;}
    public String selectedPassStratJsoneResponse{get;set;}
    public String skipNoteDetailsToAppendAboutDates{get;set;}
    
    /**
    *  phoneNumList and addressHistory
    *  To give balance to rendering times between the 4+ VF pages in the console, these 2 properties were, at one point, initialized on document ready from an actionFunction.
    *  However, some defects have been arising that are showing that these two properties are getting out-of-sync between
    *  the vf page and this controller.  (the list is, on some actionFunction calls, null -- which means that the list wasn't initialized and the controller + session state was some how re-set)
    *  Changing these to getters with a psuedo-singleton design pattern will fix a major defect, but
    *    1) see responseCount management to see how one of these is managed. 
    */
    private List<PhoneNumberObject> cachedPhoneList;
    public List<PhoneNumberObject> phoneNumList {
        get {
            if(cachedPhoneList == null && contextSkipTrace != null) {
                cachedPhoneList = new List<PhoneNumberObject>();
                addPhoneNumbersToPhoneListIfPhoneNotEmpty();
            }
            return cachedPhoneList;
        }
    }
    private List<AddressHistory> cachedAddressList;
    public List<AddressHistory> addressHistory{ 
        get {
            if(cachedAddressList == null && contextSkipTrace != null) {
                cachedAddressList = new List<AddressHistory>();
                populateAddresses();
            }
            return cachedAddressList;
        }
    }
    
    
    
    private List<String> cachedVendorPhoneList;
    private List<String> vendorPhoneList {
        get {
            if(cachedVendorPhoneList == null) {
                cachedVendorPhoneList =  new List<String>();
                for(Toyota_Vendor_Phone_Number__c vendorPhone : [select Name from Toyota_Vendor_Phone_Number__c]) {
                    String cleanedPhone = vendorPhone.Name.replaceAll('[^0-9]','');
                    if(cleanedPhone.length() > 0) {
                        cachedVendorPhoneList.add(cleanedPhone);
                    }
                }
            }
            return cachedVendorPhoneList;
        }
    }
    
    
    public TFSC_SkipTraceController(ApexPages.StandardController stdController) {
        responseCount = 0;
        this.contextFinancialAccount = (Financial_Account__c)stdController.getRecord();
        if(contextFinancialAccount != null) {
            populateContextFacAfterFinancialAccountSet();
            primaryFac = TFSC_Utils.getPrimaryFinancialAccountCustomer(contextFinancialAccount.Id);
            //Modified by Shashank Singhal for S-330388 on 06/29/2015
            fAccType = 'General';
            if((contextFinancialAccount.Collection_List_Number_1__c == '1704'
            || contextFinancialAccount.Collection_List_Number_1__c == '1705'
            || contextFinancialAccount.Collection_List_Number_1__c == '1800')
            && (contextFinancialAccount.Collection_List_Status_1__c == 'A'
            || contextFinancialAccount.Collection_List_Status_1__c == 'P')){
                fAccType = 'FPD-EPD';
            }else if((contextFinancialAccount.Collection_List_Status_1__c == 'A'
                  || contextFinancialAccount.Collection_List_Status_1__c == 'P')
                  && ((contextFinancialAccount.Collection_List_Number_1__c == '1860' //Modified by Shashank Singhal for I-172097
                  || contextFinancialAccount.Collection_List_Number_1__c == '1861') //Modified by Shashank Singhal for I-172097
                  || primaryFac.Mailing_State_Garage__c == 'MA')){
                    fAccType = 'MA';
                  }
           //End of S-330388    
            populateSkipTraceAndGenerateSkipTraceRelatedData();
            populatePhoneSourceSelectOptions();
        }
            
    }
    
    
    
    private void populatePhoneSourceSelectOptions() {
        phoneSourceSelectOptions = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Skip_Trace__c.Phone1_Source__c.getDescribe();
        
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
        {
           phoneSourceSelectOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        
        
        phoneStatusSelectOptions = new List<SelectOption>();
        fieldResult = Skip_Trace__c.Phone1_Status__c.getDescribe();
        for( Schema.PicklistEntry f1 : fieldResult.getPicklistValues())
        {
           phoneStatusSelectOptions.add(new SelectOption(f1.getLabel(), f1.getValue()));
        }
        
        
        phoneTypeSelectOptions = new List<SelectOption>();
        fieldResult = Skip_Trace__c.Phone1_Type__c.getDescribe();
        for( Schema.PicklistEntry f2 : fieldResult.getPicklistValues())
        {
           phoneTypeSelectOptions.add(new SelectOption(f2.getLabel(), f2.getValue()));
        }
        
        
        addressSourceSelectOptions = new List<SelectOption>();
        fieldResult = Skip_Trace__c.Address1_Source__c.getDescribe();
        for( Schema.PicklistEntry f3 : fieldResult.getPicklistValues())
        {
           addressSourceSelectOptions.add(new SelectOption(f3.getLabel(), f3.getValue()));
        }
    }
    
    
    private void populateContextFacAfterFinancialAccountSet() {
        
        
        List<Financial_Account_Customer__c> facList = [select Work_Phone_No_Call_Reason_Code_Bill_To__c, 
                                                       Mobile_Phone_No_Call_Reason_Code__c, Home_Phone_No_Call_Reason_Code_BillTo__c,
                                                       Home_Phone_No_Call_Reason_Code_Garage__c, 
                                                       Flag_Work_Phone_Is_Mobile_BillTo__c, Work_Phone_Bill_To__c, Mobile_Phone__c,
                                                       Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                                                       Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                                                       Flag_Home_Phone_IsMobile_Garage__c,
                                                       Flag_Home_Phone_IsMobile_BillTo__c, HomePhone_BillTo__c, Financial_Account__c,
                                                       Home_Phone_Garage__c,
                                                       Mailing_Postal_Code_Garage__c
                                                       from Financial_Account_Customer__c
                                                       where Borrower_Position__c = 'Co-X'
                                                       and Financial_Account__c = :contextFinancialAccount.Id
                                                       and (not Financial_Account_Customer__c like '%Inactive%') ];
        
        
        if(facList != null && !facList.isEmpty()) {
            
            contextFac = facList[0];
            
            //reset contextFac to Primary if coborrower was dialed on screenPop.
            Financial_Account_Customer__c facCoXFromDialedPhoneNumber = getFacCoXFromDialedPhoneNumber(facList);
            if(coBorrowerWasPoppedBooleanStringFromJS != null && 
                    coBorrowerWasPoppedBooleanStringFromJS == 'true' && 
                    facCoXFromDialedPhoneNumber != null) 
            {
                contextFac = TFSC_Utils.getPrimaryFinancialAccountCustomer(contextFinancialAccount.Id);
            }
            
            // Set enable/disable contextFAC numbers values
            listDisplayContextFACNumbers = TFSC_Utils.getListDisplayFACNumbers(contextFAC);
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
                
                if( !TFSC_Utils.isNullOrEmpty(fac.HomePhone_BillTo__c) ){
                    if(fac.HomePhone_BillTo__c.replaceAll('[^0-9]','').contains(borrowerPhoneFromJS)) {
                        facToReturn = fac;
                    }
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Bill_To__c) ){
                    if(fac.Work_Phone_Bill_To__c.replaceAll('[^0-9]','').contains(borrowerPhoneFromJS)) {
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
    
    
    
    private void populateSkipTraceAndGenerateSkipTraceRelatedData() {
        selectOrGenerateSkipTrace(); 
        if(contextSkipTrace != null) {
            populateSkipTraceRelatedDataAfterValidatingThatSkipTraceExists();
        }
            
    }
    private void populateSkipTraceRelatedDataAfterValidatingThatSkipTraceExists() {
        populatePassTrategySelectOptions();
        
        oldValsFromSkipTrace = new DateValuesForEditAndDisplay(contextSkipTrace); 
        populateAccuintSelectOptions();
        populateFastSearchSelectOptions();
        
        updateHelpText();
        
        // Set if calling window is opened
        if(primaryFac != null && primaryFac.Mailing_Postal_Code_Garage__c != null) {
            populateIsCallingWindowOpen(primaryFac.Mailing_Postal_Code_Garage__c);
        }
    }
    
    
    private void populateAddresses() {
        for(Integer i=1; i<11; i++){
            String strIteration = String.valueOf(i); 
            String addressFieldPrefix = 'Address' + strIteration + '_';
            
            String addy = (String)contextSkipTrace.get(addressFieldPrefix + '_c');
            String src = (String)contextSkipTrace.get(addressFieldPrefix + 'Source__c');
            String dateRange = (String)contextSkipTrace.get(addressFieldPrefix + 'Date_Range__c');
            
            if( !TFSC_Utils.isNullOrEmpty(addy) ) {
                addressHistory.add( new AddressHistory(addy, src, dateRange) );
            }
        }
    }
    
    
    private void populateAccuintSelectOptions() {
        accuintSelectOptions = new List<SelectOption>();
                
        Schema.DescribeFieldResult fieldResult = Skip_Trace__c.Accurint_Search_Method__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntryObjList = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : pickListEntryObjList)  
        {
            accuintSelectOptions.add( new SelectOption(ple.getLabel(), ple.getValue()) );
        }       
    }
    
    private void populateFastSearchSelectOptions() {
        fastDataSearchSelectOptions = new List<SelectOption>();
                
        Schema.DescribeFieldResult fieldResult = Skip_Trace__c.Fast_Data_Search_Method__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntryObjList = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry ple : pickListEntryObjList)  
        {
            fastDataSearchSelectOptions.add( new SelectOption(ple.getLabel(), ple.getValue()) );
        } 
        
    }
    
    
    
    public void populateIsCallingWindowOpen(String zipCode){
        isCallingWindowOpen = TFSC_Utils.getEnablePhoneNumberDependingOnTimeZone(zipCode, Date.today()); 
    }
    
    private void addPhoneNumbersToPhoneListIfPhoneNotEmpty() {
        
        // Set if calling window is opened
        if(primaryFac != null && primaryFac.Mailing_Postal_Code_Garage__c != null) {
            populateIsCallingWindowOpen(primaryFac.Mailing_Postal_Code_Garage__c);
        }
        //Phone40__c, Phone40_CS_CX__c, Phone40_Date__c, Phone40_Source__c, Phone40_Status__c, Phone40_Type__c
        for(Integer i=1; i<51; i++){
            String strIteration = String.valueOf(i); 
            String phoneFieldPrefix = 'Phone' + strIteration + '_';
            
            String phoneNum = (String)contextSkipTrace.get(phoneFieldPrefix + '_c');
            String phoneStatus = (String)contextSkipTrace.get(phoneFieldPrefix + 'Status__c');
            String phoneType = (String)contextSkipTrace.get(phoneFieldPrefix + 'Type__c');
            String phoneSource = (String)contextSkipTrace.get(phoneFieldPrefix + 'Source__c');
            Date phoneDate = (Date)contextSkipTrace.get(phoneFieldPrefix + 'Date__c');
            Datetime lastCalled = (Datetime)contextSkipTrace.get(phoneFieldPrefix + 'Last_Called_Timestamp__c');
            String acctNum = (String)contextFinancialAccount.Id;
            Boolean enableClickToDial = false; //DEFAULT?
            if(isCallingWindowOpen) {

                enableClickToDial = TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(phoneStatus);
            }else{
                enableClickToDial = isCallingWindowOpen;
            }

            if( !TFSC_Utils.isNullOrEmpty(phoneNum) ) {
                phoneNum = phoneNum.replaceAll('\'', '&apos;');
                PhoneNumberObject phoneNumber = new PhoneNumberObject(phoneNum, phoneStatus, phoneType, phoneSource, phoneDate);
                phoneNumber.enableClickToDial = enableClickToDial;
                
                if(phoneNumber.enableClickToDial) {
                    updatePhoneObjIfIsVendorPhone(phoneNumber);
                }
                
                if(phoneNumber.enableClickToDial) {
                    //US872 -- don't enable click-to-dial if is system number (MOBILE, HOME, GARAGE, ETC.)
                    setEnabledToFalseIfIsSystemPhone(phoneNumber);
                }
                
                phoneNumber.lastCalled = lastCalled;
                //System.debug('phoneNumberphoneNum = ' + phoneNum + ';phoneNumber.enableClickToDial = ' + phoneNumber.enableClickToDial);
                phoneNumList.add(phoneNumber);
            }
        }
        
    }
    
    //US872 -- don't enable click-to-dial if is system number (MOBILE, HOME, GARAGE, ETC.)
    private void setEnabledToFalseIfIsSystemPhone(PhoneNumberObject phoneNumber) {
        String enteredPhone = phoneNumber.phoneNumber;
        enteredPhone = enteredPhone.replaceAll('[^0-9]','') ;
        
        List<String> phonesToValidateAgainst = new List<String>();
        List<Financial_Account_Customer__c> facList = TFSC_Utils.getAllFACsForFinancialAccount(contextFinancialAccount.Id);
        Boolean matchFound = false;
        
        if(facList != null) {
            for(Financial_Account_Customer__c fac : facList) {
                if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Garage__c) && fac.Work_Phone_Garage__c.replaceAll('[^0-9]','').contains(enteredPhone) ){
                    matchFound = true;
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Mobile_Phone__c) && fac.Mobile_Phone__c.replaceAll('[^0-9]','').contains(enteredPhone) ){
                    matchFound = true;
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Home_Phone_Garage__c) && fac.Home_Phone_Garage__c.replaceAll('[^0-9]','').contains(enteredPhone) ){
                    matchFound = true;
                }
                
                if( !TFSC_Utils.isNullOrEmpty(fac.HomePhone_BillTo__c) && fac.HomePhone_BillTo__c.replaceAll('[^0-9]','').contains(enteredPhone) ){
                    matchFound = true;
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Bill_To__c) && fac.Work_Phone_Bill_To__c.replaceAll('[^0-9]','').contains(enteredPhone) ){
                    matchFound = true;
                }
            }
        }
        
        
        if(matchFound) {
            phoneNumber.enableClickToDial = false;
        }
        
    }
    
    
    
    
    
    
    private void selectOrGenerateSkipTrace() {
        List<Skip_Trace__c> skipTraceList = [select Id, Accurint_Checkbox__c, Accurint_Date__c, Accurint_Search_Method__c, Address1__c, 
                    Address1_Date_Range__c, Address1_Source__c, Address10__c, Address10_Date_Range__c, Address10_Source__c, 
                    Address2__c, Address2_Date_Range__c, Address2_Source__c, Address3__c, Address3_Date_Range__c, 
                    Address3_Source__c, Address4__c, Address4_Date_Range__c, Address4_Source__c, Address5__c, Address5_Date_Range__c, 
                    Address5_Source__c, Address6__c, Address6_Date_Range__c, Address6_Source__c, Address7__c, Address7_Date_Range__c, 
                    Address7_Source__c, Address8__c, Address8_Date_Range__c, Address8_Source__c, Address9__c, Address9_Date_Range__c, 
                    Address9_Source__c, DMS_Credit_App_Checkbox__c, DMS_Credit_App_Date__c, 
                    Fast_Data_Checkbox__c, Fast_Data_Date__c, Fast_Data_Search_Method__c, Financial_Account__c, 
                    Innovis_Checkbox__c, Innovis_Date__c, Miscellaneous_Notes__c, 
                    Multiple_Accounts_Checkbox__c, Multiple_Accounts_Date__c, Name, Notes_Reviewed_Back_To_Date__c, Payment_Review_Checkbox__c, 
                    Payment_Review_Date__c, Phone1__c, Phone1_CS_CX__c, Phone1_Date__c, Phone1_Source__c, Phone1_Status__c,
                    Phone1_Type__c, Phone10__c, Phone10_CS_CX__c, Phone10_Date__c, Phone10_Source__c, Phone10_Status__c, Phone10_Type__c, 
                    Phone11__c, Phone11_CS_CX__c, Phone11_Date__c, Phone11_Source__c, Phone11_Status__c, Phone11_Type__c, Phone12__c, 
                    Phone12_CS_CX__c, Phone12_Date__c, Phone12_Source__c, Phone12_Status__c, Phone12_Type__c, Phone13__c, Phone13_CS_CX__c, 
                    Phone13_Date__c, Phone13_Source__c, Phone13_Status__c, Phone13_Type__c, Phone14__c, Phone14_CS_CX__c, Phone14_Date__c, 
                    Phone14_Source__c, Phone14_Status__c, Phone14_Type__c, Phone15__c, Phone15_CS_CX__c, Phone15_Date__c, 
                    Phone15_Source__c, Phone15_Status__c, Phone15_Type__c, Phone16__c, Phone16_CS_CX__c, Phone16_Date__c, 
                    Phone16_Source__c, Phone16_Status__c, Phone16_Type__c, Phone17__c, Phone17_CS_CX__c, Phone17_Date__c, 
                    Phone17_Source__c, Phone17_Status__c, Phone17_Type__c, Phone18__c, Phone18_CS_CX__c, Phone18_Date__c, 
                    Phone18_Source__c, Phone18_Status__c, Phone18_Type__c, Phone19__c, Phone19_CS_CX__c, Phone19_Date__c, 
                    Phone19_Source__c, Phone19_Status__c, Phone19_Type__c, Phone2__c, Phone2_CS_CX__c, Phone2_Date__c, Phone2_Source__c, 
                    Phone2_Status__c, Phone2_Type__c, Phone20__c, Phone20_CS_CX__c, Phone20_Date__c, Phone20_Source__c, Phone20_Status__c, 
                    Phone20_Type__c, Phone21__c, Phone21_CS_CX__c, Phone21_Date__c, Phone21_Source__c, Phone21_Status__c, Phone21_Type__c, 
                    Phone22__c, Phone22_CS_CX__c, Phone22_Date__c, Phone22_Source__c, Phone22_Status__c, Phone22_Type__c, Phone23__c, 
                    Phone23_CS_CX__c, Phone23_Date__c, Phone23_Source__c, Phone23_Status__c, Phone23_Type__c, Phone24__c, Phone24_CS_CX__c, 
                    Phone24_Date__c, Phone24_Source__c, Phone24_Status__c, Phone24_Type__c, Phone25__c, Phone25_CS_CX__c, Phone25_Date__c, 
                    Phone25_Source__c, Phone25_Status__c, Phone25_Type__c, Phone26__c, Phone26_CS_CX__c, Phone26_Date__c, Phone26_Source__c, 
                    Phone26_Status__c, Phone26_Type__c, Phone27__c, Phone27_CS_CX__c, Phone27_Date__c, Phone27_Source__c, Phone27_Status__c, 
                    Phone27_Type__c, Phone28__c, Phone28_CS_CX__c, Phone28_Date__c, Phone28_Source__c, Phone28_Status__c, Phone28_Type__c, 
                    Phone29__c, Phone29_CS_CX__c, Phone29_Date__c, Phone29_Source__c, Phone29_Status__c, Phone29_Type__c, Phone3__c, 
                    Phone3_CS_CX__c, Phone3_Date__c, Phone3_Source__c, Phone3_Status__c, Phone3_Type__c, Phone30__c, Phone30_CS_CX__c, 
                    Phone30_Date__c, Phone30_Source__c, Phone30_Status__c, Phone30_Type__c, Phone31__c, Phone31_CS_CX__c, Phone31_Date__c, 
                    Phone31_Source__c, Phone31_Status__c, Phone31_Type__c, Phone32__c, Phone32_CS_CX__c, Phone32_Date__c, 
                    Phone32_Source__c, Phone32_Status__c, Phone32_Type__c, Phone33__c, Phone33_CS_CX__c, Phone33_Date__c, 
                    Phone33_Source__c, Phone33_Status__c, Phone33_Type__c, Phone34__c, Phone34_CS_CX__c, Phone34_Date__c, 
                    Phone34_Source__c, Phone34_Status__c, Phone34_Type__c, Phone35__c, Phone35_CS_CX__c, Phone35_Date__c, 
                    Phone35_Source__c, Phone35_Status__c, Phone35_Type__c, Phone36__c, Phone36_CS_CX__c, Phone36_Date__c, 
                    Phone36_Source__c, Phone36_Status__c, Phone36_Type__c, Phone37__c, Phone37_CS_CX__c, Phone37_Date__c, 
                    Phone37_Source__c, Phone37_Status__c, Phone37_Type__c, Phone38__c, Phone38_CS_CX__c, Phone38_Date__c, 
                    Phone38_Source__c, Phone38_Status__c, Phone38_Type__c, Phone39__c, Phone39_CS_CX__c, Phone39_Date__c, 
                    Phone39_Source__c, Phone39_Status__c, Phone39_Type__c, Phone4__c, Phone4_CS_CX__c, Phone4_Date__c, 
                    Phone4_Source__c, Phone4_Status__c, Phone4_Type__c, Phone40__c, Phone40_CS_CX__c, Phone40_Date__c, 
                    Phone40_Source__c, Phone40_Status__c, Phone40_Type__c, Phone41__c, Phone41_CS_CX__c, Phone41_Date__c, 
                    Phone41_Source__c, Phone41_Status__c, Phone41_Type__c, Phone42__c, Phone42_CS_CX__c, Phone42_Date__c, 
                    Phone42_Source__c, Phone42_Status__c, Phone42_Type__c, Phone43__c, Phone43_CS_CX__c, Phone43_Date__c, 
                    Phone43_Source__c, Phone43_Status__c, Phone43_Type__c, Phone44__c, Phone44_CS_CX__c, Phone44_Date__c, 
                    Phone44_Source__c, Phone44_Status__c, Phone44_Type__c, Phone45__c, Phone45_CS_CX__c, Phone45_Date__c, 
                    Phone45_Source__c, Phone45_Status__c, Phone45_Type__c, Phone46__c, Phone46_CS_CX__c, Phone46_Date__c, 
                    Phone46_Source__c, Phone46_Status__c, Phone46_Type__c, Phone47__c, Phone47_CS_CX__c, Phone47_Date__c, 
                    Phone47_Source__c, Phone47_Status__c, Phone47_Type__c, Phone48__c, Phone48_CS_CX__c, Phone48_Date__c, 
                    Phone48_Source__c, Phone48_Status__c, Phone48_Type__c, Phone49__c, Phone49_CS_CX__c, Phone49_Date__c, 
                    Phone49_Source__c, Phone49_Status__c, Phone49_Type__c, Phone5__c, Phone5_CS_CX__c, Phone5_Date__c, 
                    Phone5_Source__c, Phone5_Status__c, Phone5_Type__c, Phone50__c, Phone50_CS_CX__c, Phone50_Date__c, 
                    Phone50_Source__c, Phone50_Status__c, Phone50_Type__c, Phone6__c, Phone6_CS_CX__c, Phone6_Date__c, 
                    Phone6_Source__c, Phone6_Status__c, Phone6_Type__c, Phone7__c, Phone7_CS_CX__c, Phone7_Date__c, 
                    Phone7_Source__c, Phone7_Status__c, Phone7_Type__c, Phone8__c, Phone8_CS_CX__c, Phone8_Date__c, 
                    Phone8_Source__c, Phone8_Status__c, Phone8_Type__c, Phone9__c, Phone9_CS_CX__c, Phone9_Date__c, 
                    Phone9_Source__c, Phone9_Status__c, Phone9_Type__c, Phone1_Last_Called_Timestamp__c, Phone2_Last_Called_Timestamp__c, Phone3_Last_Called_Timestamp__c,
                    Phone4_Last_Called_Timestamp__c, Phone5_Last_Called_Timestamp__c, Phone6_Last_Called_Timestamp__c,
                    Phone7_Last_Called_Timestamp__c, Phone8_Last_Called_Timestamp__c, Phone9_Last_Called_Timestamp__c,
                    Phone10_Last_Called_Timestamp__c, Phone11_Last_Called_Timestamp__c, Phone12_Last_Called_Timestamp__c,
                    Phone13_Last_Called_Timestamp__c, Phone14_Last_Called_Timestamp__c, Phone15_Last_Called_Timestamp__c,
                    Phone16_Last_Called_Timestamp__c, Phone17_Last_Called_Timestamp__c, Phone18_Last_Called_Timestamp__c,
                    Phone19_Last_Called_Timestamp__c, Phone20_Last_Called_Timestamp__c, Phone21_Last_Called_Timestamp__c,
                    Phone22_Last_Called_Timestamp__c, Phone23_Last_Called_Timestamp__c, Phone24_Last_Called_Timestamp__c,
                    Phone25_Last_Called_Timestamp__c, Phone26_Last_Called_Timestamp__c, Phone27_Last_Called_Timestamp__c,
                    Phone28_Last_Called_Timestamp__c, Phone29_Last_Called_Timestamp__c, Phone30_Last_Called_Timestamp__c,
                    Phone31_Last_Called_Timestamp__c, Phone32_Last_Called_Timestamp__c, Phone33_Last_Called_Timestamp__c,
                    Phone34_Last_Called_Timestamp__c, Phone35_Last_Called_Timestamp__c, Phone36_Last_Called_Timestamp__c,
                    Phone37_Last_Called_Timestamp__c, Phone38_Last_Called_Timestamp__c, Phone39_Last_Called_Timestamp__c,
                    Phone40_Last_Called_Timestamp__c, Phone41_Last_Called_Timestamp__c, Phone42_Last_Called_Timestamp__c,
                    Phone43_Last_Called_Timestamp__c, Phone44_Last_Called_Timestamp__c, Phone45_Last_Called_Timestamp__c,
                    Phone46_Last_Called_Timestamp__c, Phone47_Last_Called_Timestamp__c, Phone48_Last_Called_Timestamp__c,
                    Phone49_Last_Called_Timestamp__c, Phone50_Last_Called_Timestamp__c, DMS_Checkbox__c, DMS_Date__c //Modified by Shashank Singhal for S-321636 on 06/29/2015
                    
                    
                                               from Skip_Trace__c
                                               where Financial_Account__c = :contextFinancialAccount.Id
                                               limit 1] ;
                                               
        if(skipTraceList != null && !skipTraceList.isEmpty()) {
            contextSkipTrace = skipTraceList[0];
            /*Modified by Shashank Singhal for S-321636 on 06/29/2015
            if(contextSkipTrace.DMS_Checkbox__c == true && contextSkipTrace.DMS_Date__c < (system.Today() - 30)){
                contextSkipTrace.DMS_Checkbox__c = false;
                contextSkipTrace.DMS_Date__c = null;
            }
            //End of S-321636*/
        }
        //else{
            //contextSkipTrace = generateNewSkipTraceRecord(contextFac.Financial_Account__c);
        //}
    }
    
    private Skip_Trace__c generateNewSkipTraceRecord(id faId) {
        Skip_Trace__c skipTrace = new Skip_Trace__c(Financial_Account__c = faId);
        
        return skipTrace;
    }
    
    
    private Map<Integer,Collections_Pass_Strategy__c> mapOfPassStrategyNumberToPassStrat = new Map<Integer,Collections_Pass_Strategy__c>();
    private Map<String,Collections_Pass_Strategy__c> mapOfArticleNumStringToPassStrat = new Map<String,Collections_Pass_Strategy__c>();
    private void populatePassTrategySelectOptions() {
        passStrategySelectOptions = new List<SelectOption>();
        String recommendedLabel = '';
        Integer recCount = 0;
        for(Collections_Pass_Strategy__c passStrat : [select name, Sort__c, RES__c, Account_Type__c, Article_Number__c, Standard_Note__c
                                                        from Collections_Pass_Strategy__c where Account_Type__c = :fAccType 
                                                        order by Sort__c]) //Modified by Shashank Singhal for S-330388 on 06/29/2015
        {
            mapOfPassStrategyNumberToPassStrat.put( Integer.valueOf(passStrat.Sort__c), passStrat);
            mapOfArticleNumStringToPassStrat.put( passStrat.Article_Number__c, passStrat);
            
            if(recCount == 0) {
                recommendedLabel = passStrat.RES__c + ' Recommended';//Modified by Shashank Singhal for S-330388 on 06/29/2015
                selectedPassStrategy = passStrat.Article_Number__c ;
            }
            String soValue = passStrat.Article_Number__c;
            if(soValue == null) {
                soValue = '';
            }
            passStrategySelectOptions.add( new SelectOption(soValue, passStrat.RES__c) );
            recCount++ ;
        }
        passStratLabel = recommendedLabel ; //selectedPassStrat defaulted to 1st;
        
        
        for(Case collectionCase : [select id, status, Previous_Pass__c
                                    from case
                                    where Financial_Account__c = :contextFinancialAccount.Id 
                                    and RecordType.Name = 'Collection'
                                    and (status <> null and (status <> 'Closed' or (status like 'RES%' OR status = 'MANL')))
                                    limit 1]) //Modified by Shashank Singhal for S-330388 on 06/29/2015
        {
            updateCaseStatusAndIncrimentSelectedPassStrategy(collectionCase);
        }
        
    }
    
    private void updateCaseStatusAndIncrimentSelectedPassStrategy(Case collectionCase) {
        String newCaseStatus = '';
        Integer currentIntValuePassStrat = 1;
        Integer daysPastDue = 0;
        Collections_Pass_Strategy__c tempPassStrategy;
        
        if(contextFinancialAccount.History_Counter_Days_Past_Due__c != null && contextFinancialAccount.History_Counter_Days_Past_Due__c.length() > 0) {
            daysPastDue = Integer.valueOf(contextFinancialAccount.History_Counter_Days_Past_Due__c);
        }
        //Modified by Shashank Singhal for S-330388 on 06/29/2015
        /*if(collectionCase.status.length() > 3 && collectionCase.status.substring(0,4) == 'PASS') {
            String tmpPassStratNumString = collectionCase.status.substring(4,6).replaceAll('[^0-9]','');
            currentIntValuePassStrat = Integer.valueOf( tmpPassStratNumString );
            currentIntValuePassStrat++; //INCREMENT
            if(currentIntValuePassStrat > 11) {
                currentIntValuePassStrat = 11;
            }
            tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(currentIntValuePassStrat) ;
        }else{
            tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(1) ;
            currentIntValuePassStrat = 1;
        }
        
        //first payment default
        if(contextFinancialAccount.Collection_List_Number_1__c != null
            && currentIntValuePassStrat < 4
            && contextFinancialAccount.Collection_List_Number_1__c != '1706'
            && contextFinancialAccount.Collection_List_Status_1__c != 'C'
            && contextFinancialAccount.Finance_Account_Status__c != 'Close'
            && contextFinancialAccount.History_Counter_Days_Past_Due__c != null
            && Integer.valueOf(contextFinancialAccount.History_Counter_Days_Past_Due__c) > 0
            && (
                 (contextFinancialAccount.RecordType.Name == 'Retail'
                 && contextFinancialAccount.History_Counter_Payments_Made__c == 0 )
                 ||
                 (contextFinancialAccount.RecordType.Name == 'Lease'
                 && contextFinancialAccount.History_Counter_Payments_Made__c <= 1 )
                )
            )
        {
            
            tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(4) ;
            currentIntValuePassStrat = 4;
        }
        
        //removing 'elses' until logic is clarified.
        if(daysPastDue >= 60 && currentIntValuePassStrat < 3) {
             tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(3) ;
             currentIntValuePassStrat = 3;
        }
        
        if(daysPastDue < 45 && currentIntValuePassStrat > 6 ) {
            tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(6) ;
            currentIntValuePassStrat = 6;
        }
        
        if(daysPastDue < 55 && currentIntValuePassStrat > 8) {
            tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(8) ;
            currentIntValuePassStrat = 8;
        }
        
        if(currentIntValuePassStrat > 10) {
            Integer tmpDaysPastDueAccountingForMonday = daysPastDue;
            if( DateTime.now().format('E') == 'Mon') {
                tmpDaysPastDueAccountingForMonday += 2 ;
            }
            
            if(
                   //75 DPD (73 on Monday)
                   tmpDaysPastDueAccountingForMonday < 75 &&
                   (
                       contextFinancialAccount.Risk_Strategy_Code_3__c == null
                       || contextFinancialAccount.Risk_Strategy_Code_3__c == ''
                       || contextFinancialAccount.Risk_Strategy_Code_3__c == 'XXX'
                       || contextFinancialAccount.Risk_Strategy_Code_3__c == 'RPO'
                       || contextFinancialAccount.Risk_Strategy_Code_3__c == 'CND'

                   )
               )
            {
                tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(10) ;
                currentIntValuePassStrat = 10;
            }
            
            if(
                   //83 DPD (81 on Monday)
                   tmpDaysPastDueAccountingForMonday < 83
                   && contextFinancialAccount.Risk_Strategy_Code_3__c != null 
                   && contextFinancialAccount.Risk_Strategy_Code_3__c == 'NOR'
              )
            {
                tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(10) ;
                currentIntValuePassStrat = 10;
            }
        }
        
        //DE1696 -- If DPD > 45, do not present Pass6 - go to Pass7
        if( daysPastDue > 45 && currentIntValuePassStrat == 6 ) {
            tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7) ;
            currentIntValuePassStrat = 7;
        }*/
        
        tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(1) ;
        if(collectionCase.Previous_pass__c == null){
            collectionCase.Previous_pass__c = 0;
        }
        previousPass = 0;
        if(fAccType == 'General'){
            if(daysPastDue < 45){
                if(collectionCase.Previous_pass__c == 0){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(1);
                    previousPass = 1;
                }else if(collectionCase.Previous_pass__c == 1 || collectionCase.Status == 'RES1'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(2);
                    previousPass = 2;
                }else if(collectionCase.Previous_pass__c == 2 || collectionCase.Previous_pass__c == 3 || collectionCase.Status == 'RES2'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 3;
                }
            }else if(daysPastDue >= 45 && daysPastDue < 55){
                if(collectionCase.Previous_pass__c <= 3){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(3);
                    previousPass = 4;
                }else if(collectionCase.Previous_pass__c == 4 || collectionCase.Previous_pass__c == 5  || collectionCase.Status == 'RES3'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 5;
                }
            }else if(daysPastDue >= 55 && daysPastDue < 65){
                if(collectionCase.Previous_pass__c <= 5){ 
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(4);
                    previousPass = 6;
                }else if(collectionCase.Previous_pass__c == 6 || collectionCase.Previous_pass__c == 7 || collectionCase.Status == 'RES4'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 7;
                }
            }else if(daysPastDue >= 65 && daysPastDue < 90){
                if(collectionCase.Previous_pass__c <= 7){ 
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(5);
                    previousPass = 8;
                }else if(collectionCase.Previous_pass__c == 8 || collectionCase.Status == 'RES5'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(6);
                    previousPass = 9;
                }else if(collectionCase.Previous_pass__c == 9 || collectionCase.Status == 'MANL/RCVR'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 9;
                }
            }           
        }else if(fAccType == 'FPD-EPD'){
            if(daysPastDue < 45){
                if(collectionCase.Previous_pass__c == 0){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(1);
                    previousPass = 1;
                }else if(collectionCase.Previous_pass__c == 1 || collectionCase.Status == 'RES1'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(2);
                    previousPass = 2;
                }else if(collectionCase.Previous_pass__c == 2 || collectionCase.Status == 'RES2'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(3);
                    previousPass = 3;
                }else if(collectionCase.Previous_pass__c == 3 || collectionCase.Previous_pass__c == 4  || collectionCase.Status == 'RES3'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 4;
                }
            }else if(daysPastDue >= 45 && daysPastDue < 90){
                if(collectionCase.Previous_pass__c <= 4){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(4);
                    previousPass = 5;
                }else if(collectionCase.Previous_pass__c == 5 || collectionCase.Status == 'RES4'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(5);
                    previousPass = 6;
                }else if(collectionCase.Previous_pass__c == 6 || collectionCase.Status == 'RES5'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(6);
                    previousPass = 7;
                }else if(collectionCase.Previous_pass__c == 7 || collectionCase.Status == 'MANL/RCVR'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 7;
                }
            }
        }else if(fAcctype == 'MA'){
            if(daysPastDue < 30){
                if(collectionCase.Previous_pass__c == 0){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(1);
                    previousPass = 1;
                }else if(collectionCase.Previous_pass__c == 1 || collectionCase.Status == 'RES1'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(2);
                    previousPass = 2;
                }else if(collectionCase.Previous_pass__c == 2 || collectionCase.Previous_Pass__c == 3 || collectionCase.Status == 'RES2'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 3;
                }
            }else if(daysPastDue >=30 && daysPastDue < 45){
                if(collectionCase.Previous_pass__c <= 3){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(3);
                    previousPass = 4;
                }else if(collectionCase.Previous_pass__c == 4 || collectionCase.Previous_Pass__c == 5  || collectionCase.Status == 'RES3'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 5;
                }
            }else if(daysPastDue >= 45 && daysPastDue < 60){
                if(collectionCase.Previous_pass__c <= 5){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(4);
                    previousPass = 6;
                }else if(collectionCase.Previous_pass__c == 6 || collectionCase.Previous_Pass__c == 7 || collectionCase.Status == 'RES4'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 7;
                }
            }else if(daysPastDue >= 60 && daysPastDue < 90){
                if(collectionCase.Previous_pass__c <= 7){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(5);
                    previousPass = 8;
                }else if(collectionCase.Previous_pass__c == 8 || collectionCase.Status == 'RES5'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(6);
                    previousPass = 9;
                }else if(collectionCase.Previous_pass__c == 9 || collectionCase.Status == 'MANL/RCVR'){
                    tempPassStrategy = mapOfPassStrategyNumberToPassStrat.get(7);
                    previousPass = 9;
                }
            }
        }
        //End of S-330388
        
        if( tempPassStrategy != null ) {
            caseToUpdate = collectionCase;
            
            caseToUpdate.status = tempPassStrategy.RES__c;//Modified by Shashank Singhal for S-330388
            caseToUpdate.Previous_Pass__c = previousPass;//Modified by Shashank Singhal for S-330388
            passStratLabel = caseToUpdate.status + ' Recommended';
            selectedPassStrategy = tempPassStrategy.Article_Number__c ;
           
        }
        system.debug('%%%'+selectedPassStrategy);
    }
    
    private Case caseToUpdate;
    //Modified by Shashank Singhal for S-330388
    public string skipTracePhoneJSONResponse{get; set;}
    public void saveCaseStatus() {
        
        selectedPassStratJsoneResponse = '';
        
        //if(caseToUpdate != null) {
            //try {
                system.debug('%%%'+selectedPassStrategy);
                if(selectedPassStrategy != null) {
                	system.debug('%%%'+mapOfArticleNumStringToPassStrat);
                	system.debug('%%%'+mapOfArticleNumStringToPassStrat.get(selectedPassStrategy));
                	
                	Collections_Pass_Strategy__c obj = mapOfArticleNumStringToPassStrat.get(selectedPassStrategy);
                    system.debug('%%%'+contextSkipTrace+'%%%'+obj);
                    obj.NotesReviewedTo__c = contextSkipTrace.Notes_Reviewed_Back_To_Date__c;
                    selectedPassStratJsoneResponse = JSON.serialize(obj);
                    
                   if(obj.RES__c == 'RES3' || obj.RES__c == 'RES4'){
                       Skip_Trace__c tempSkipTrace = new Skip_Trace__c();
                       string source = '';
                       if(obj.RES__c == 'RES3')
                            source = 'Innovis';
                        else
                            source = 'Accurint';
                       integer phoneCounter = 1;
                       integer addCounter = 1;
                       integer foundPhoneData = 0;
                       integer foundAdddata = 0;
                       if(contextSkipTrace != null){
                            Skip_Trace__c sTrace = contextSkipTrace;
                            while(phoneCounter <= 50 && foundPhoneData < 2){
                                if((string)sTrace.get('Phone'+string.valueOf(phoneCounter)+'_Source__c') == source){
                                    string Phone = (string)sTrace.get('Phone'+string.valueOf(phoneCounter)+'__c');
                                    foundPhoneData++;
                                    tempSkipTrace.put('Phone'+string.valueOf(foundPhoneData)+'__c', Phone);
                                }
                                phoneCounter++;
                            }
                            while(addCounter <= 10 && foundAdddata < 2){
                                if((string)sTrace.get('Address'+string.valueOf(addCounter)+'_Source__c') == source){
                                    string add = (string)sTrace.get('Address'+string.valueOf(addCounter)+'__c');
                                    foundAdddata++;
                                    tempSkipTrace.put('Address'+string.valueOf(foundAdddata)+'__c', add);
                                }
                                addCounter++;
                            }
                       }
                       skipTracePhoneJSONResponse = JSON.serialize(tempSkipTrace);      
                   }
                                
                    //End of S-330388
                }

            //    update caseToUpdate;
            //}
            //catch (Exception e) {
           // }
        //}
        
    }
    
    
    private void updateHelpText() {
        knowledgeArticleText = TFSC_SkipTraceController.generateArticleText(selectedPassStrategy);
    }
    
    @RemoteAction
    global static String generateArticleText(String articleNum) {
        String strToReturn = '';
        
        if( !TFSC_Utils.isNullOrEmpty(articleNum) ) {
            for(CollectionsPassStrategy__kav article : [ SELECT Id, Details__c
                                                          FROM CollectionsPassStrategy__kav
                                                          WHERE Language = 'en_US' 
                                                          and PublishStatus = 'Online' 
                                                          and ArticleNumber = :articleNum ])
            {
                strToReturn = article.Details__c;
            }
        }
        
        return strToReturn;
    }
    
    
    public PageReference deleteAddress() {
        AddyJsonResponseAndRequest response = new AddyJsonResponseAndRequest();
        AddyJsonResponseAndRequest request;
        String errorString;
        
        try {
            request = (AddyJsonResponseAndRequest)JSON.deserialize(saveAddyJsonRequest, AddyJsonResponseAndRequest.class);
        }
        catch (Exception e) {
            errorString = 'serializationTFSC - ';
            errorString += String.valueOf(e.getMessage());
        }
        
        
        if(errorString != null) {
            response = new AddyJsonResponseAndRequest();
            response.saveErrorMessage = errorString;
            response.saveSuccess = 'false';
        }else if(request == null){
            response = new AddyJsonResponseAndRequest();
            response.saveErrorMessage = 'TFSC Error 14065 - contact support.';
            response.saveSuccess = 'false';
        }else{
            //response = saveAddressFromRequest(request);
            AddressHistory contextPhoneObj = getAddyObjFromRandomId(request.randomId);
            
            if(contextPhoneObj == null) {
                response.saveErrorMessage = 'TFSC Error 14067 - contact support.';
                response.saveSuccess = 'false';
            }else{
                try {
                    removeAddyObjByRandomId(contextPhoneObj.randomId);
                    updateAndSaveAddressValuesFromAddyList();
                    response.saveSuccess = 'true';
                }
                catch (Exception e) {
                    response = new AddyJsonResponseAndRequest();
                    response.saveErrorMessage = e.getMessage();
                    response.saveSuccess = 'false';
                }
            }
        }
        
        saveAddyResponse = JSON.serialize(response);
        
        responseCount++;
        return null;
    }
    
    public PageReference saveAddress() {
        AddyJsonResponseAndRequest response = new AddyJsonResponseAndRequest();
        AddyJsonResponseAndRequest request;
        String errorString;
        
        try {
            request = (AddyJsonResponseAndRequest)JSON.deserialize(saveAddyJsonRequest, AddyJsonResponseAndRequest.class);
        }
        catch (Exception e) {
            errorString = 'serializationTFSC - ';
            errorString = e.getMessage();
        }
        
        response = new AddyJsonResponseAndRequest();
        if(errorString != null) {
            response.saveErrorMessage = errorString;
            response.saveSuccess = 'false';
        }else if(request == null){
            response.saveErrorMessage = 'TFSC Error 11065 - contact support.';
            response.saveSuccess = 'false';
        }else if(request.dateRange != null && request.dateRange.length() > 20) {
            response.saveErrorMessage = 'Date Range cannot exceed 20 characters.';
            response.saveSuccess = 'false';
        }else if(request.address != null && request.address.length() > 255) {
            response.saveErrorMessage = 'Address cannot 255 characters.';
            response.saveSuccess = 'false';
        }else{
            response = saveAddressFromRequest(request);
        }
        
        saveAddyResponse = JSON.serialize(response);
        
        responseCount++;
        return null;
    }
    
    private AddyJsonResponseAndRequest saveAddressFromRequest(AddyJsonResponseAndRequest request) {
        AddyJsonResponseAndRequest response = new AddyJsonResponseAndRequest();
        
        if( TFSC_Utils.isNullOrEmpty(request.randomId) ) {
            
            //insert row
            if(addressHistory.size() == 10) {
                response.saveErrorMessage = 'Only 10 address records are allowed.';
                response.saveSuccess = 'false';
            }else{
                try {
                    AddressHistory newInsertPhoneObj = new AddressHistory(request);
                    addressHistory.add(newInsertPhoneObj);
                    updateAndSaveAddressValuesFromAddyList();
                    response.updateValuesFromAddyObj(newInsertPhoneObj);
                    response.saveSuccess = 'true';
                }
                catch (Exception e) {
                    response = new AddyJsonResponseAndRequest();
                    response.saveErrorMessage = e.getMessage();
                    response.saveSuccess = 'false';
                }
            }
            
        }else{
            //row update
            AddressHistory contextPhoneObj = getAddyObjFromRandomId(request.randomId);
            
            if(contextPhoneObj == null) {
                //response.saveErrorMessage = 'TFSC Error 11067 - contact support.';
                response.saveErrorMessage = 'Record removed, but not reflected on the screen because of an error.  Refresh tab or browser window now to verify deletion.  If you can remember the steps to reproduce this including sequence of saves and deletes, please note them and contact support.';
                response.saveSuccess = 'false';
            }else{
                try {
                    contextPhoneObj.updateValuesFromRequest(request);
                    updateAndSaveAddressValuesFromAddyList();
                    response.updateValuesFromAddyObj(contextPhoneObj);
                    response.saveSuccess = 'true';
                }
                catch (Exception e) {
                    response = new AddyJsonResponseAndRequest();
                    response.saveErrorMessage = e.getMessage();
                    response.saveSuccess = 'false';
                }
            }
        }
        
        responseCount++;
        return response;
    }
    private void updateAndSaveAddressValuesFromAddyList() {
        String addressFieldPrefix;
        String strIteration;
        for(Integer i=1; i<11; i++){
            strIteration = String.valueOf(i); 
            addressFieldPrefix = 'Address' + strIteration + '_';
            
            contextSkipTrace.put(addressFieldPrefix + '_c', '');
            contextSkipTrace.put(addressFieldPrefix + 'Source__c', '');
            contextSkipTrace.put(addressFieldPrefix + 'Date_Range__c', '');
        }
        
        Integer ct = 1;
        for(AddressHistory addyObj : addressHistory) {
            strIteration = String.valueOf(ct); 
            addressFieldPrefix = 'Address' + strIteration + '_';
            
            contextSkipTrace.put(addressFieldPrefix + '_c', addyObj.address);
            contextSkipTrace.put(addressFieldPrefix + 'Source__c', addyObj.source);
            contextSkipTrace.put(addressFieldPrefix + 'Date_Range__c', addyObj.dateRange);
            
            ct++;
        }
        
        update contextSkipTrace;
        
    }
    
    
    public PageReference deletePhoneLineItem() {
        PhoneNumberSaveResponseAndRequest response = new PhoneNumberSaveResponseAndRequest();
        PhoneNumberSaveResponseAndRequest request;
        String errorString;
        
        /** putting this here becuase we've seen multiple instances of a delete phone line item 
             removing all the phone numbers.
            This code is written in the event that sfdc's session state is failing (and phoneNumList gets emptied for some reason).
        */ 
        if(phoneNumList == null || phoneNumList.size() == 0) {
            errorString = 'There was an error deleting.  Press Cancel, refresh the account, and try again.';
        }
        
        
        try {
            request = (PhoneNumberSaveResponseAndRequest)JSON.deserialize(saveJsonRequest, PhoneNumberSaveResponseAndRequest.class);
        }
        catch (Exception e) {
            errorString = e.getMessage();
        }
        
        
        
        if(errorString != null) {
            response = new PhoneNumberSaveResponseAndRequest();
            response.saveErrorMessage = errorString;
            response.saveSuccess = 'false';
        }else if(request == null){
            response = new PhoneNumberSaveResponseAndRequest();
            response.saveErrorMessage = 'TFSC Error 10065 - contact support.';
            response.saveSuccess = 'false';
        }else{
            response = deletePhoneFromRequest(request);
        }
        
        saveResponse = JSON.serialize(response);
        
        responseCount++;
        return null;
    }
    
    private PhoneNumberSaveResponseAndRequest deletePhoneFromRequest(PhoneNumberSaveResponseAndRequest request) {
        
        PhoneNumberSaveResponseAndRequest response = new PhoneNumberSaveResponseAndRequest();
        
        if( TFSC_Utils.isNullOrEmpty(request.randomId) ) {
            response.saveErrorMessage = 'TFSC Error 10066 - contact support.';
            response.saveSuccess = 'false';
        }else{
            
            PhoneNumberObject contextPhoneObj = getPhoneNumObjByRandomId(request.randomId);
            Skip_Trace__c tmpST = contextSkipTrace.clone(true, true);
            
            if(contextPhoneObj == null) {
                //then already deleted but errored out somewhere.
                
                response = new PhoneNumberSaveResponseAndRequest();
                response.saveErrorMessage = 'Record removed, but not reflected in the UI because of an error.  Refresh tab or browser window when complete.  If you can remember the steps to reproduce this or any odd issues (like slow network speeds, etc.), please note them and contact support.';
                response.saveSuccess = 'false';
                
            }else{
                String phoneNumToDelete;
                String cleanedPhone;
                if(contextPhoneObj.phoneNumber != null) {
                    //phoneNumToDelete = contextPhoneObj.phoneNumber.replaceAll('[^0-9]','');
                    phoneNumToDelete = contextPhoneObj.phoneNumber;
                    cleanedPhone = contextPhoneObj.phoneNumber.replaceAll('[^0-9]','');
                }
                
                if( !TFSC_Utils.isNullOrEmpty(phoneNumToDelete) ) {
                    
                    try {
                        removePhoneNumbObjByRandomId(contextPhoneObj.randomId);
                        updateAndOrderPhoneList();
                        response.saveSuccess = 'true';
                    }
                    catch (Exception e) {
                        contextSkipTrace = tmpST; //in case the issue is in updateAndOrderPhoneList(); going to save values.
                        response = new PhoneNumberSaveResponseAndRequest();
                        response.saveErrorMessage = 'TFSC Error 10011 - contact support.';
                        response.saveSuccess = 'false';
                    }
                    
                }
            }
        }
        
        
        return response;
    }
    
    
    public PageReference savePhoneLineItem() {
        
        PhoneNumberSaveResponseAndRequest response;
        PhoneNumberSaveResponseAndRequest request;
        String errorString;
        
        try {
            request = (PhoneNumberSaveResponseAndRequest)JSON.deserialize(saveJsonRequest, PhoneNumberSaveResponseAndRequest.class);
        }
        catch (Exception e) {
            errorString = e.getMessage();
        }
        
        if(errorString != null) {
            response = new PhoneNumberSaveResponseAndRequest();
            response.saveErrorMessage = errorString;
            response.saveSuccess = 'false';
        }else if(request == null){
            response = new PhoneNumberSaveResponseAndRequest();
            response.saveErrorMessage = 'TFSC Error 10054 - contact support.';
            response.saveSuccess = 'false';
        }else{
            
            response = updatePhoneRecordAndReturnResponse(request);
            
        }
        
        
        saveResponse = JSON.serialize(response);
        
        responseCount++;
        return null;
    }
    
    //request should already have been null-checked
    private PhoneNumberSaveResponseAndRequest updatePhoneRecordAndReturnResponse(PhoneNumberSaveResponseAndRequest request) {
        PhoneNumberSaveResponseAndRequest response = new PhoneNumberSaveResponseAndRequest();
        Boolean changedTypeToVendor = false;
        String acctNum = (String)contextFinancialAccount.Id;
        System.debug('********************* Skip Trace Controller ~ acctNum: ' + acctNum);
        
        if( TFSC_Utils.isNullOrEmpty(request.randomId) || request.randomId == 'undefined' || request.randomId == 'null' ) {
            //new 'record' INSERT
            
            String tempPhoneNum = request.phoneNumber; //defect hunting.
            String errorString = '';
            if (!(request.errorStringShownFlag == 'true')) {
                errorString = validateInsertAndReturnErrorString(tempPhoneNum);
            }
            
            
            if( !TFSC_Utils.isNullOrEmpty(errorString) ) {
                response.saveErrorMessage = errorString;
                response.saveSuccess = 'false';
            }else{
                //do insert
                try {
                    PhoneNumberObject newPhoneObj = new PhoneNumberObject(request.phoneNumber, request.phoneStatus, request.phoneType, request.phoneSource, Date.today());
                    newPhoneObj.enableClickToDial = false; //DEFAULT?
                    newPhoneObj.lastCalled = null;
                    
                    // Set if calling window is opened
                    if(primaryFac != null && primaryFac.Mailing_Postal_Code_Garage__c != null) {
                        populateIsCallingWindowOpen(primaryFac.Mailing_Postal_Code_Garage__c);
                    }
                    
                    if(isCallingWindowOpen && request.phoneStatus != null) {
                        newPhoneObj.enableClickToDial = TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(request.phoneStatus);
                    }else{
                        newPhoneObj.enableClickToDial = isCallingWindowOpen;
                    }
                    changedTypeToVendor = updatePhoneObjIfIsVendorPhone(newPhoneObj);
                    
                    setEnabledToFalseIfIsSystemPhone(newPhoneObj);

                    phoneNumList.add(newPhoneObj);
                    updateAndOrderPhoneList();
                    
                    response = new PhoneNumberSaveResponseAndRequest(newPhoneObj);
                    response.saveSuccess = 'true';
                }
                catch (Exception e) {
                    response = new PhoneNumberSaveResponseAndRequest();
                    response.saveSuccess = 'false';
                    response.saveErrorMessage = e.getMessage();
                }
            }
            
        }else{
            //record UPDATE
            
            //request.randomID is null-checked in the top IF block
            PhoneNumberObject contextPhoneObj = getPhoneNumObjByRandomId(request.randomId);
            
            if(contextPhoneObj != null) {
                PhoneNumberObject tempContextObj = contextPhoneObj.clone(); //so mem ref isn't updated, even after UI 'cancel'.
                tempContextObj.updateValsFromRequest(request);
                
                //RUN VALIDATIONS ON TMP OBJECT (so that we can rollback on invalid record)
                String updateErrMessage = '';
                if (!(request.errorStringShownFlag == 'true')) {
                    updateErrMessage = validateUpdateAndReturnErrorString(tempContextObj);
                }
                
                if( !TFSC_Utils.isNullOrEmpty(updateErrMessage) ) {
                    response.saveErrorMessage = updateErrMessage;
                    response.saveSuccess = 'false';
                }else{
                    try {
                        contextPhoneObj.updateValsFromRequest(request);
                        changedTypeToVendor = updatePhoneObjIfIsVendorPhone(contextPhoneObj);
                        updateAndOrderPhoneList();
                        
                        // Set if calling window is opened
                        if(primaryFac != null && primaryFac.Mailing_Postal_Code_Garage__c != null) {
                            populateIsCallingWindowOpen(primaryFac.Mailing_Postal_Code_Garage__c);
                        }
                        if(isCallingWindowOpen && contextPhoneObj.phoneStatus != null) {
                            contextPhoneObj.enableClickToDial = TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(contextPhoneObj.phoneStatus);
                        }else{
                            contextPhoneObj.enableClickToDial = isCallingWindowOpen;
                        }
                        
                        setEnabledToFalseIfIsSystemPhone(contextPhoneObj);
                        
                        response = new PhoneNumberSaveResponseAndRequest(contextPhoneObj);
                        response.saveSuccess = 'true';
                    }
                    catch (Exception e) {
                        response = new PhoneNumberSaveResponseAndRequest();
                        response.saveSuccess = 'false';
                        response.saveErrorMessage = e.getMessage();
                    }
                }
            }else{
                //contextPhoneObj is null
                response = new PhoneNumberSaveResponseAndRequest();
                response.saveErrorMessage = 'There was an error processing this request.  Refresh the console and try again.';
                response.saveSuccess = 'false';
            }
            
            
        }
        
        if(changedTypeToVendor) {
            response.alertMessage = 'This phone number is a Toyota Vendor number.  Phone_Type updated.';
        }
        return response;
    }
    
    private Boolean updatePhoneObjIfIsVendorPhone(PhoneNumberObject phoneObj) {
        
        if( phoneObj == null || TFSC_Utils.isNullOrEmpty(phoneObj.phoneNumber) ) {
            return true;
        }
        
        String enteredPhone = phoneObj.phoneNumber;
        enteredPhone = enteredPhone.replaceAll('[^0-9]','') ;
        
        if(enteredPhone.length() > 0) {
            for(String vendorPhone : vendorPhoneList) {
                if(enteredPhone.contains(vendorPhone) || vendorPhone.contains(enteredPhone)) {
                    if(phoneObj.phoneStatus == null || phoneObj.phoneStatus != 'T - Toyota Financial/Vendor')
                    phoneObj.phoneStatus = 'T - Toyota Financial/Vendor';
                    return true;
                }
            }
        }
        
        
        return false;
    }
    
    
    private void updateAndOrderPhoneList() {
        
        Integer i;
        String strIteration;
        String phoneFieldPrefix;
        for(i=1; i<51; i++){
            strIteration = String.valueOf(i); 
            phoneFieldPrefix = 'Phone' + strIteration + '_';
            
            contextSkipTrace.put(phoneFieldPrefix + '_c', '');
            contextSkipTrace.put(phoneFieldPrefix + 'Status__c', '');
            contextSkipTrace.put(phoneFieldPrefix + 'Type__c', '');
            contextSkipTrace.put(phoneFieldPrefix + 'Source__c', '');
            contextSkipTrace.put(phoneFieldPrefix + 'Date__c', null);
            contextSkipTrace.put(phoneFieldPrefix + 'Last_Called_Timestamp__c', null);
        }
        
        i = 1;
        for(PhoneNumberObject phoneObj : phoneNumList) {
            strIteration = String.valueOf(i); 
            phoneFieldPrefix = 'Phone' + strIteration + '_';
            
            
            String tmpPhoneNum      = '';
            String tmpPhoneStatus   = '';
            String tmpPhoneType     = '';
            String tmpPhoneSource   = '';
            Date tempDate           = null;
            Datetime tempLastCalledDate = null;
            
            if(phoneObj.phoneDate != null) {
                tempDate = phoneObj.phoneDate;
            }
            if(phoneObj.phoneNumber != null) {
                tmpPhoneNum = phoneObj.phoneNumber; 
            }
            if(phoneObj.phoneStatus != null) {
                tmpPhoneStatus = phoneObj.phoneStatus;
            }
            if(phoneObj.phoneType != null) {
                tmpPhoneType = phoneObj.phoneType;
            }
            if(phoneObj.phoneSource != null) {
                tmpPhoneSource = phoneObj.phoneSource;
            }
            if(phoneObj.lastCalled != null) {
                tempLastCalledDate = phoneObj.lastCalled;
            }
            
            
            contextSkipTrace.put(phoneFieldPrefix + '_c', tmpPhoneNum);
            contextSkipTrace.put(phoneFieldPrefix + 'Status__c', tmpPhoneStatus);
            contextSkipTrace.put(phoneFieldPrefix + 'Type__c', tmpPhoneType);
            contextSkipTrace.put(phoneFieldPrefix + 'Source__c', tmpPhoneSource);
            contextSkipTrace.put(phoneFieldPrefix + 'Date__c', tempDate);
            contextSkipTrace.put(phoneFieldPrefix + 'Last_Called_Timestamp__c', tempLastCalledDate);
            i++;
        }
        
        update contextSkipTrace; 
    }
    
    
    
    private PhoneNumberObject getPhoneNumObjByRandomId(String randomId) {
        String debugString = '****getPhoneNumObjByRandomId randomId = ' + randomId ;
        PhoneNumberObject objToReturn;
        for(PhoneNumberObject phoneNumObj : phoneNumList) {
            debugString += '; ' + phoneNumObj.randomId;
            if(phoneNumObj.randomId == randomId) {
                objToReturn = phoneNumObj;
            }
        }
        System.debug(debugString);
        return objToReturn;
    }
    private void removePhoneNumbObjByRandomId(String randomId) {
        for(Integer i=0; i < phoneNumList.size(); i++){
            PhoneNumberObject phoneNumObj = phoneNumList[i];
            if(randomId != null && phoneNumObj.randomId != null && phoneNumObj.randomId == randomId) {
                phoneNumList.remove(i);
                break;
            }
        }
    }
    private PhoneNumberObject getPhoneNumObjByPhoneNum(String phoneNumber) {
        PhoneNumberObject objToReturn;
        for (PhoneNumberObject phoneNumObj : phoneNumList) {
            if (phoneNumObj.phoneNumber == phoneNumber) {
                objToReturn = phoneNumObj;
            }
        }
        return objToReturn;
    }
    private AddressHistory getAddyObjFromRandomId(String randomId) {
        AddressHistory objToReturn;
        
        for(AddressHistory addyObj : addressHistory) {
            if(randomId != null && addyObj.randomId != null && addyObj.randomId == randomId) {
                objToReturn = addyObj;
            }
        }
        
        return objToReturn;
    }
    private void removeAddyObjByRandomId(String randomId) {
        for(Integer i=0; i < addressHistory.size(); i++){
            AddressHistory addyObj = addressHistory[i];
            if(addyObj.randomId == randomId) {
                addressHistory.remove(i);
                break;
            }
        }
    }
    
    private String validateUpdateAndReturnErrorString(PhoneNumberObject phoneNumObj) {
        
        String errorString = '';
        
        if( !validateThatPhoneIsUnique(phoneNumObj) ) {
            errorString += 'Phone number is already in the skip trace list.';
        } else {
            String cleanedNewPhoneNumber = phoneNumObj.phoneNumber.replaceAll('[^0-9]','');
            TFSC_Utils.ValidatePhoneNumber phoneValidator = new TFSC_Utils.ValidatePhoneNumber();
            errorString += phoneValidator.isValid(cleanedNewPhoneNumber);
        }
        return errorString;
    }
    
    private Boolean validateThatPhoneIsUnique(PhoneNumberObject phoneNumObj) {
        String cleanedNewPhoneNumber = phoneNumObj.phoneNumber;
        cleanedNewPhoneNumber = cleanedNewPhoneNumber.replaceAll('[^0-9]','');
        
        for(PhoneNumberObject phoneObj2 : phoneNumList) {
            if(phoneObj2.randomId != phoneNumObj.randomId) {
                String listCleanedNum = phoneObj2.phoneNumber;
                listCleanedNum = listCleanedNum.replaceAll('[^0-9]','');
                if(listCleanedNum.contains(cleanedNewPhoneNumber)) {
                    return false;
                }
            }
        }
        return true;
    }
    
    
    public String validateInsertAndReturnErrorString(String newPhone) {
        Set<String> tempCurPhoneNumbers = new Set<String>();
        if( newPhone == null ) {
            return 'Phone number cannot be empty.';
        }
        
        if(phoneNumList == null) {
            return 'Phone List is Empty -- error 19981.  Contact support or refresh browser window to try again.';
        }
        
        if(phoneNumList.size() >= 50) { //50 already exist; no more.
            return 'Only 50 phone numbers are allowed in Skip Trace.';
        }
        
        String cleanedNewPhoneNumber = newPhone.replaceAll('[^0-9]','');
        TFSC_Utils.ValidatePhoneNumber phoneValidator = new TFSC_Utils.ValidatePhoneNumber();
        String isValidError = phoneValidator.isValid(cleanedNewPhoneNumber);
        
        //if they entered 'old', then that's fine, since sfdc allowed it.
        if(cleanedNewPhoneNumber.length() > 0) {
            
            for(PhoneNumberObject phoneObj : phoneNumList) {
                if( !TFSC_Utils.isNullOrEmpty(phoneObj.phoneNumber) ) {
                    String cleanedPhone = phoneObj.phoneNumber.replaceAll('[^0-9]','');
                    if(!TFSC_Utils.isNullOrEmpty(cleanedPhone)) {
                        tempCurPhoneNumbers.add(cleanedPhone);
                    }
                }
            }
            
            for(String phoneStr : tempCurPhoneNumbers) {
                if(cleanedNewPhoneNumber.contains(phoneStr)) {
                    return 'This phone number is already in use.';
                }
            }
        }else{
            return 'Phone Number required for save.';
        }
        
        if (!(isValidError == '')) {
            return isValidError;
        }
        
        
        return '';
        
    }
    
    
    public PageReference updateAltBorrower() {
        
        if(borrowerPhoneFromJS != null && borrowerPhoneFromJS.length() > 0) {
            populateContextFacAfterFinancialAccountSet();
        }
        
        return null;
    }
    
    
    /**
    *   This method is for handling the "initialize Skip Trace" button click in the ui.
    */
    public PageReference initializeNewSkipTraceRecordAndPopulateData() {
        if(contextSkipTrace == null && contextFinancialAccount != null) {
            
            selectOrGenerateSkipTrace(); //try selecting in case a different user generated it already.
            
            if(contextSkipTrace == null) {
                contextSkipTrace = generateNewSkipTraceRecord(contextFinancialAccount.Id);
                insert contextSkipTrace;
            }
            
            populateSkipTraceRelatedDataAfterValidatingThatSkipTraceExists();
            //populateAddressesAndPhones();
        }
        return null;
    }
    
    public PageReference saveAfterFieldValueChange() {
        skipNoteDetailsToAppendAboutDates = '';
        
        updateContextValuesFromFieldUpdates();
        
        upsert contextSkipTrace;
        
        oldValsFromSkipTrace = new DateValuesForEditAndDisplay(contextSkipTrace);
        
        saveCaseStatus();
        
        return null;
    }
    
    public PageReference populatePhonesAndAddresses() {
        //populateAddressesAndPhones();
        return null;
    }
    
    public PageReference updateTimestamp() {
        LastCalledTimestampRequestAndResponse response = new LastCalledTimestampRequestAndResponse();
        LastCalledTimestampRequestAndResponse request;
        String errorString;
        
        try {
            request = (LastCalledTimestampRequestAndResponse)JSON.deserialize(saveJsonRequest, LastCalledTimestampRequestAndResponse.class);
            request.lastCalled = Date.today();
        }
        catch (Exception e) {
            errorString = e.getMessage();
        }
        
        
        
        if(errorString != null) {
            response = new LastCalledTimestampRequestAndResponse();
            response.saveErrorMessage = errorString;
            response.saveSuccess = 'false';
        }else if(request == null){
            response = new LastCalledTimestampRequestAndResponse();
            response.saveErrorMessage = 'Error updating last called timestamp';
            response.saveSuccess = 'false';
        }else{
            response = updateLastCalledTimestampResponse(request);
        }
        
        saveResponse = JSON.serialize(response);
        
        responseCount++;
        return null;
    }
    
    private LastCalledTimestampRequestAndResponse updateLastCalledTimestampResponse(LastCalledTimestampRequestAndResponse request) {
        
        LastCalledTimestampRequestAndResponse response = new LastCalledTimestampRequestAndResponse();
        
        if( TFSC_Utils.isNullOrEmpty(request.phoneNumber) ) {
            response.saveErrorMessage = 'TFSC Error 10066 - contact support.';
            response.saveSuccess = 'false';
        }else{
            
            PhoneNumberObject contextPhoneObj = getPhoneNumObjByPhoneNum(request.phoneNumber);
            Skip_Trace__c tmpST = contextSkipTrace.clone(true, true);
            
            if(contextPhoneObj == null) {
                // we didn't find a matching phone number in our list of phone numbers... so, we can't update last called timestamp
                response = new LastCalledTimestampRequestAndResponse();
                response.saveErrorMessage = 'PhoneNumberObject not updated';
                response.saveSuccess = 'false';
            }else{
                contextPhoneObj.lastCalled = Datetime.now();
                response = new LastCalledTimestampRequestAndResponse(contextPhoneObj);
                response.saveSuccess = 'true';
                
                updateAndOrderPhoneList();

            }
        }
        
        
        return response;
    }
    
    private DateValuesForEditAndDisplay oldValsFromSkipTrace;
    private void updateContextValuesFromFieldUpdates() {
        
        if(contextSkipTrace != null && oldValsFromSkipTrace != null) {
            
            
            if(oldValsFromSkipTrace.multipleAccountsIsPopulated != contextSkipTrace.Multiple_Accounts_Checkbox__c) {
                if(contextSkipTrace.Multiple_Accounts_Checkbox__c) {
                    contextSkipTrace.Multiple_Accounts_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed Multiple Accounts today. ';
                }else{
                    //contextSkipTrace.Multiple_Accounts_Date__c = null;
                }
            }
            
            //Modified by Shashank Singhal for S-321636 on 06/29/2015
            if(oldValsFromSkipTrace.dmsIsPopulated != contextSkipTrace.DMS_Checkbox__c) {
                if(contextSkipTrace.DMS_Checkbox__c) {
                    contextSkipTrace.DMS_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed DMS today. ';
                }else{
                    //contextSkipTrace.Multiple_Accounts_Date__c = null;
                }
            }
            //End of S-321636
            
            if(oldValsFromSkipTrace.dmsCredicAppIsPopulated != contextSkipTrace.DMS_Credit_App_Checkbox__c) {
                if(contextSkipTrace.DMS_Credit_App_Checkbox__c) {
                    contextSkipTrace.DMS_Credit_App_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed Credit App today. ';//Modified by Shashank Singhal for S-321636
                }else{
                    //contextSkipTrace.DMS_Credit_App_Date__c = null;
                }
            }
            
            if(oldValsFromSkipTrace.paymentReviewIsPopulated != contextSkipTrace.Payment_Review_Checkbox__c) {
                if(contextSkipTrace.Payment_Review_Checkbox__c) {
                    contextSkipTrace.Payment_Review_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed Payment Review today. ';
                }else{
                    //contextSkipTrace.Payment_Review_Date__c = null;
                }
            }
            
            if(oldValsFromSkipTrace.innovisIsPopulated != contextSkipTrace.Innovis_Checkbox__c) {
                if(contextSkipTrace.Innovis_Checkbox__c) {
                    contextSkipTrace.Innovis_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed Innovis today. ';
                }else{
                    //contextSkipTrace.Innovis_Date__c = null;
                }
            }
            
            if(oldValsFromSkipTrace.accurintIsPopulated != contextSkipTrace.Accurint_Checkbox__c) {
                if(contextSkipTrace.Accurint_Checkbox__c) {
                    contextSkipTrace.Accurint_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed Accurint today. ';
                }else{
                    //contextSkipTrace.Accurint_Date__c = null;
                }
            }
            
            if(oldValsFromSkipTrace.fastDataIsPopulated != contextSkipTrace.Fast_Data_Checkbox__c) {
                if(contextSkipTrace.Fast_Data_Checkbox__c) {
                    contextSkipTrace.Fast_Data_Date__c = Date.today();
                    skipNoteDetailsToAppendAboutDates += 'Completed Fast Data today. ';
                }else{
                    //contextSkipTrace.Fast_Data_Date__c = null;
                }
            }
                
        }
        
    }
    
    
    
    
    public class DateValuesForEditAndDisplay {
        
        public Boolean multipleAccountsIsPopulated{get;set;}
        public Boolean dmsCredicAppIsPopulated{get;set;}
        public Boolean paymentReviewIsPopulated{get;set;}
        public Boolean innovisIsPopulated{get;set;}
        public Boolean accurintIsPopulated{get;set;}
        public Boolean fastDataIsPopulated{get;set;}
        public Date notesReviewedBackTo{get;set;}
        public Boolean dmsIsPopulated{get; set;} //Modified by Shashank Singhal for S-321636 on 06/29/2015
        
        
        public DateValuesForEditAndDisplay(Skip_Trace__c skipTraceRecord) {
            //this.multipleAccountsIsPopulated = (skipTraceRecord.Multiple_Accounts_Date__c != null);
            this.multipleAccountsIsPopulated = skipTraceRecord.Multiple_Accounts_Checkbox__c ;
            this.dmsCredicAppIsPopulated = skipTraceRecord.DMS_Credit_App_Checkbox__c ;
            this.paymentReviewIsPopulated = skipTraceRecord.Payment_Review_Checkbox__c ;
            this.innovisIsPopulated = skipTraceRecord.Innovis_Checkbox__c ;
            this.accurintIsPopulated = skipTraceRecord.Accurint_Checkbox__c ;
            this.fastDataIsPopulated = skipTraceRecord.Fast_Data_Checkbox__c ;
            this.notesReviewedBackTo = skipTraceRecord.Notes_Reviewed_Back_To_Date__c ;
            this.dmsIsPopulated = skipTraceRecord.DMS_Checkbox__c ; //Modified by Shashank Singhal for S-321636 on 06/29/2015
        }
        
    }
    
    
    public class PhoneNumberObject {
        
        public String noCallReasonCode{get;set;} //delete
        public String randomId{get;set;}
        public String phoneNumber{get;set;}
        public String phoneStatus{get;set;}
        public String phoneSource{get;set;}
        public Boolean showMobilePhoneImage{get;set;}
        public Boolean enableClickToDial{get;set;}
        public String phoneType{get;set;}
        public String phoneTypeSingleChr{
            get {
                String strToReturn = '';
                if(phoneType != null && phoneType.length() > 0) {
                    strToReturn = phoneType.substring(0,1);
                }
                return strToReturn;
            }
        }
        public Date phoneDate{get;set;}
        public Datetime lastCalled{get;set;}
        
        public String errorStringShownFlag{get;set;}
        
        
        public PhoneNumberObject(String phoneNumber, String phoneStatus, String phoneType, String phoneSource, Date phoneDate) {
            randomId = TFSC_TestUtils.generateRandomString(15) ;
            this.phoneNumber = phoneNumber;
            this.phoneStatus = phoneStatus;
            this.phoneType   = phoneType;
            this.phoneSource = phoneSource;
            this.phoneDate   = phoneDate;
        }
        
        public void updateValsFromRequest(PhoneNumberSaveResponseAndRequest request) {
            this.phoneType   = getValAndReturnEmptyStringIfNull(request.phoneType);
            this.phoneSource = getValAndReturnEmptyStringIfNull(request.phoneSource);
            this.phoneStatus = getValAndReturnEmptyStringIfNull(request.phoneStatus);
            this.phoneNumber = getValAndReturnEmptyStringIfNull(request.phoneNumber);
        }
        
        private String getValAndReturnEmptyStringIfNull(String str) {
            String strToReturn = '';
            
            if(str != null) {
                strToReturn = str;
            }
            
            return strToReturn;
        }
        
        private Map<String,String> mapOfFirstCharToOrder = new Map<String,String>{
            'G' => '01',
            'C' => '02',
            'L' => '03',
            'S' => '04',
            'M' => '05',
            'D' => '06',
            'B' => '07',
            'T' => '08',
            'H' => '09',
            'N' => '10'
        };
        
        public String statusOrder{
            get{
                String strToReturn = '00';
                if(phoneStatus != null && phoneStatus.length() > 0) {
                    String firstChar = phoneStatus.substring(0,1).toUpperCase();
                    strToReturn = mapOfFirstCharToOrder.get(firstChar);
                    if(strToReturn == null) {
                        strToReturn = '00';
                    }
                }
                return strToReturn;
            }
        }
    }
    
    public class AddyJsonResponseAndRequest {
        public String saveSuccess{get;set;}
        public String saveErrorMessage{get;set;}
        
        public String randomId{get;set;}
        public String address{get;set;}
        public String source{get;set;}
        public String dateRange{get;set;}
        public String addressHtml{
            get{
                String str = '';
                if(address != null) {
                    str = address;
                    //str = str.replaceAll('\n', '<br/>');
                   // str = str.replaceAll('\'', '&apos;');
                    //str = str.replaceAll('\"', '');
                }
                return str;
            }
        }
        
        
        public AddyJsonResponseAndRequest() {
        }
        
        public void updateValuesFromAddyObj(AddressHistory addyObj) {
            this.address = addyObj.address;
            this.source = addyObj.source;
            this.dateRange = addyObj.dateRange;
            this.randomId = addyObj.randomId;
        }
    }
    
    public class PhoneNumberSaveResponseAndRequest {
        
        public String saveSuccess{get;set;}
        public String saveErrorMessage{get;set;}
        public String alertMessage{get;set;}
        
        public String randomId{get;set;}
        public String phoneNumber{get;set;}
        public String phoneStatus{get;set;}
        public String statusOrder{get;set;}
        public String phoneSource{get;set;}
        public String phoneType{get;set;}
        public String phoneTypeSingleChr{get;set;}
        public String enableClickToDial{get;set;}
        
        public String errorStringShownFlag{get;set;}
        
        public PhoneNumberSaveResponseAndRequest() {
            
        }
        public PhoneNumberSaveResponseAndRequest(PhoneNumberObject phoneNumObj) {
            if(phoneNumObj.randomId != null) {
                this.randomId             = phoneNumObj.randomId;
            }
            if(phoneNumObj.phoneNumber != null) {
                this.phoneNumber          = phoneNumObj.phoneNumber;
            }
            if(phoneNumObj.phoneStatus != null) {
                this.phoneStatus          = phoneNumObj.phoneStatus;
            }
            if(phoneNumObj.phoneSource != null) {
                this.phoneSource          = phoneNumObj.phoneSource;
            }
            if(phoneNumObj.phoneType != null) {
                this.phoneType            = phoneNumObj.phoneType;
            }
            if(phoneNumObj.phoneTypeSingleChr != null) {
                this.phoneTypeSingleChr   = phoneNumObj.phoneTypeSingleChr;
            }
            if(phoneNumObj.statusOrder != null) {
                this.statusOrder          = phoneNumObj.statusOrder;
            }
            if (phoneNumObj.errorStringShownFlag != null) {
                this.errorStringShownFlag = phoneNumObj.errorStringShownFlag;
            }
            if(phoneNumObj.enableClickToDial != null) {
                this.enableClickToDial = (phoneNumObj.enableClickToDial) ? 'true' : 'false';
            }
        }
    }
    
    
    public class AddressHistory {
        
        public String randomId{get;set;}
        public String address{get;set;}
        public String source{get;set;}
        public String dateRange{get;set;}
        public String addressHtml{
            get{
                String str = '';
                if(address != null) {
                    str = address;
                    str = str.replaceAll('\'', '&apos;');
                    str = str.replaceAll('\n', '<br/>');
                    //str = str.replaceAll('\"', '');
                }
                return str;
            }
        }
        
        public AddressHistory(String address, String source, String dateRange ) {
            this.randomId = TFSC_TestUtils.generateRandomString(15) ;
            this.address = address;
            this.source = source; 
            this.dateRange = dateRange;
        }
        
        public AddressHistory(AddyJsonResponseAndRequest request) {
            this.randomId = TFSC_TestUtils.generateRandomString(15) ;
            updateValuesFromRequest(request); //set other values
        }
        
        public void updateValuesFromRequest(AddyJsonResponseAndRequest request) {
            this.address = request.address;
            this.source = request.source;
            this.dateRange = request.dateRange;
        }
    }
    
    
    public class LastCalledTimestampRequestAndResponse {
        public String saveSuccess{get;set;}
        public String saveErrorMessage{get;set;}
        
        public String randomId{get;set;}
        public String phoneStatus{get;set;}
        public String statusOrder{get;set;}
        public String phoneSource{get;set;}
        public String phoneType{get;set;}
        public String phoneTypeSingleChr{get;set;}
        public String phoneNumber{get;set;}
        public Datetime lastCalled{get;set;}
        public LastCalledTimestampRequestAndResponse() {
            
        }    
        public LastCalledTimestampRequestAndResponse(PhoneNumberObject phoneNumObj) {
            if (phoneNumObj.randomId != null) {
                this.randomId = phoneNumObj.randomId;
            }
            if (phoneNumObj.phoneNumber != null) {
                this.phoneNumber = phoneNumObj.phoneNumber;
            }
            if(phoneNumObj.phoneStatus != null) {
                this.phoneStatus          = phoneNumObj.phoneStatus;
            }
            if(phoneNumObj.phoneSource != null) {
                this.phoneSource          = phoneNumObj.phoneSource;
            }
            if(phoneNumObj.phoneType != null) {
                this.phoneType            = phoneNumObj.phoneType;
            }
            if(phoneNumObj.phoneTypeSingleChr != null) {
                this.phoneTypeSingleChr   = phoneNumObj.phoneTypeSingleChr;
            }
            if(phoneNumObj.statusOrder != null) {
                this.statusOrder          = phoneNumObj.statusOrder;
            }
            if (phoneNumObj.lastCalled != null) {
                this.lastCalled = phoneNumObj.lastCalled;
            }
        }
    }
    
    
}