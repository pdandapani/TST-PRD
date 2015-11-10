/** Updated by: Paras Dhingra
    Modified Date: 6/1/2015
    Description : Story S-310930 Save the RFD values to an Open Collections Case
*/
/** Updated by : Paras Dhingra
    Modified Date : 6/29/2015
    Description : Story S-310348. Blank out Talked to value on change. Bypass talked to update if manually added by user.
*/
global with sharing class TFSC_InteractionEntryPanelController {
    
    public String lastDialedPhoneNumber{get;set;}
    // RM - 10/21/2014 - US512
    public String isKVPRouted{get; set;}
    
    public String campaignName{get;set;}
    public String newPassStrategy{get;set;}
    public Map<String, Activity_Code__c> mapOfValidQuickActivityCodes = new Map<String, Activity_Code__c>();
    public Map<String, Activity_Code__c> mapOfValidRPCActivityCodes = new Map<String, Activity_Code__c>();
    public Map<String, Activity_Code__c> mapOfValidSkipActivityCodes = new Map<String, Activity_Code__c>();
    public List<SelectOption> listOfMethodsOfPayment = new List<SelectOption>();
    public List<SelectOption> listOfVPAs = new List<SelectOption>();
    public List<SelectOption> listOfRFDs = new List<SelectOption>();
    public List<SelectOption> listOfCalleeRelationships = new List<SelectOption>();
    public static Map<String, Payment_Method__c> mapOfNameToMethodsOfPayment = new Map<String, Payment_Method__c>();
    public Map<String, Callee_Relationship__c> mapOfBorrowerPositionToRelationship = new Map<String, Callee_Relationship__c>();
    public Map<String, String> mapOfCampaignNameToType = new Map<String, String>();
    public Map<String, Id> mapOfCodeNameToCodeId = new Map<String, Id>(); 
    
    //added in the last hour to handle post-validation attempted save errors.
    public String saveResponseErrorMessage{get;set;}
    
    //public String financialAccountId{get;set;}
    public String searchTerm;
    
    //Financial Account ID from the main tab, and its full record
    public String financialAccountId {
        get {
            return ApexPages.currentPage().getParameters().get('Id');
        }
        set;
    }
    public Financial_Account__c financialAccount{get;set;}
    // Open Collections Cycle Case Created for Story S-310930 6/1/2015
    @TestVisible private Case Open_Collection_Cycle_Case {get;set;}
    
    //Financial Account Customer: The current person spoken to or the primary co-borrower
    public Financial_Account_Customer__c financialAccountCustomer{get;set;}
    
    public InteractionPanelWrapper interactionPanelWrapper{get;set;}
    public String currentCodeTab{get;set;}
    public String clickedId {get; set;}
    public String selectedCodeTab {

            get {
                return currentCodeTab;                     
            }
            set;
    }
    

    
    public String getSearchTerm(){
        return searchTerm;
    }
    
    public void setSearchTerm(String term){
        searchTerm = term;
    }
    /**
     * @author: Stevie ELLA
     * @date: 06/05/2014
     * @description:
     *      Retrieve all valid activity codes. Use them to populate code picklists for each tab (Quick, RPC, Skip) 
     *      instead of querying for each one of them. 
     */
    public TFSC_InteractionEntryPanelController() {
        
        if(isValidFinancialID()){
            
                currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB;
                
                // First Thing is to retrieve the current financial account record
                setFinancialAccountIdFromMainTab();
                setOpenCollectionsCase();// Added By Paras Dhingra for Story S-310930 6/1/2015
                // Also, set the financial account customer
                financialAccountCustomer = TFSC_Utils.getCoBorrowerFinancialAccountCustomerFromPhoneNumber(financialAccountId, '') ;
                
                // Set predetermined values for the entry panel
                interactionPanelWrapper = new InteractionPanelWrapper();
                
                try{
                    interactionPanelWrapper.totalAmountDue = financialAccount.Total_Amount_Due__c;
                    interactionPanelWrapper.firstBalancePTP = financialAccount.Total_Amount_Due__c;
                    interactionPanelWrapper.secondBalancePTP = interactionPanelWrapper.firstBalancePTP;
                    interactionPanelWrapper.calleeName = financialAccountCustomer.Account__r.Name;
                    interactionPanelWrapper.listOfTalkingPoints = getTalkingPoints();
                    /*Populating RFD picklist and Comment value from Open Collections case . Story S-310930 6/1/2015#Start*/
                    if(Open_Collection_Cycle_Case!=null)
                    {
                        if(Open_Collection_Cycle_Case.RFD_picklist__c!=null && Open_Collection_Cycle_Case.RFD_picklist__c!='')
                            interactionPanelWrapper.reasonOfDelinquency = Open_Collection_Cycle_Case.RFD_picklist__c;
                        if(Open_Collection_Cycle_Case.RFD_Text__c!=null && Open_Collection_Cycle_Case.RFD_Text__c!='')
                            interactionPanelWrapper.reasonOfDelinquencyNote = Open_Collection_Cycle_Case.RFD_Text__c;
                    }
                    /*Story S-310930 6/1/2015 #End*/
                }catch(Exception e){
                    appendErrorMessage(e.getMessage());
                }

                
                // Get all the activity codes
                List<Activity_Code__c> listOfValidActivityCodes = new List<Activity_Code__c>(
                    [
                        SELECT
                                    Id,
                                    Name,
                                    Description__c,
                                    Collection_Activity_Code__c,
                                    Flag_Quick__c,
                                    Flag_RPC__c,
                                    Flag_Skip__c,
                                    Sort_Order_Quick__c,
                                    Sort_Order_RPC__c,
                                    Sort_Order_Skip__c
                        FROM
                                    Activity_Code__c
                        WHERE
                                    Flag_Quick__c = true
                                    OR
                                    Flag_RPC__c = true
                                    OR
                                    Flag_Skip__c = true
                        ORDER BY
                                    Name ASC
                    ]
                );
                
                // Assign each of the codes to the appropriate list.
                for(Activity_Code__c activityCode: listOfValidActivityCodes){
                    
                    // If Flag Quick is checked, add the activity code to Quick Codes list
                    if(activityCode.Flag_Quick__c)
                        mapOfValidQuickActivityCodes.put(activityCode.Name, activityCode);
                    
                    // If Flag RPC is checked, add the activity code to RPC Codes list
                    if(activityCode.Flag_RPC__c)
                        mapOfValidRPCActivityCodes.put(activityCode.Name, activityCode);
                    
                    // If Flag Skip is checked, add the activity code to Skip Codes list
                    if(activityCode.Flag_Skip__c)
                        mapOfValidSkipActivityCodes.put(activityCode.Name, activityCode);
                    
                }
                System.debug('************* Quick Activity Codes count: ' + mapOfValidQuickActivityCodes.size());

                
                // Get all the methods of payment
                /*mapOfNameToMethodsOfPayment = Payment_Method__c.getAll();
                List<SelectOption> listOfMethods = new List<SelectOption>();
                for(Payment_Method__c picklistOption : mapOfNameToMethodsOfPayment.values()){
                        
                      listOfMethods.add(new SelectOption(picklistOption.Name, picklistOption.Value__c));
                        
                }
                listOfMethods.sort();
                listOfMethodsOfPayment.add(new SelectOption('None', 'None'));
                listOfMethodsOfPayment.addAll(listOfMethods);*/

                List<SelectOption> listOfPaymentMethods = new List<SelectOption>();
            
                List<PaymentMethodWrapper> pmtMethodWrapper = new List<PaymentMethodWrapper>(); //Wrapper used for custom sort
                List<Payment_Method__c> pMethodOptions = Payment_Method__c.getAll().values(); //Pull in custom setting records
            
                for(Payment_Method__c pMethod : pMethodOptions){ 
                    //Add the custom setting record to the wrapper list
                    pmtMethodWrapper.add( new PaymentMethodWrapper(pMethod));
                }
                
                pmtMethodWrapper.sort(); //Sort using the Comparable interface with the Sort_Order__c value
            
                for(PaymentMethodWrapper picklistOption : pmtMethodWrapper){
                    //Add the picklist options
                    listOfPaymentMethods.add(new SelectOption(picklistOption.pmtMethod.Name, picklistOption.pmtMethod.Name));
                }

                listOfMethodsOfPayment.add(new SelectOption(TFSC_Constants.PICKLIST_NONE_VALUE, TFSC_Constants.PICKLIST_NONE_VALUE));
                listOfMethodsOfPayment.addAll(listOfPaymentMethods);


                
                // Get all the VPAs
                List<SelectOption> listOfOriginalVPAs = new List<SelectOption>();
                for(VAP_Options__c picklistOption : VAP_Options__c.getAll().values()){
                        
                      listOfOriginalVPAs.add(new SelectOption(picklistOption.Name, picklistOption.Value__c));
        
                }
                listOfOriginalVPAs.sort();
                listOfVPAs.add(new SelectOption(TFSC_Constants.PICKLIST_NONE_VALUE, TFSC_Constants.PICKLIST_NONE_VALUE));
                listOfVPAs.addAll(listOfOriginalVPAs);
                
                // Get all the Reasons for Delinquency
                listOfRFDs.add(new SelectOption(TFSC_Constants.PICKLIST_NONE_VALUE, TFSC_Constants.PICKLIST_NONE_VALUE));
                List<SelectOption> listOfReasons = new List<SelectOption>();
            
                List<ReasonsForDelinquencyWrapper> rfdWrapper = new List<ReasonsForDelinquencyWrapper>(); //Wrapper used for custom sort
                List<Reason_For_Delinquency__c> rfdOptions = Reason_For_Delinquency__c.getAll().values(); //Pull in custom setting records
            
                for(Reason_For_Delinquency__c rfd : rfdOptions){ 
                    //Add the custom setting record to the wrapper list
                    rfdWrapper.add( new ReasonsForDelinquencyWrapper(rfd));
                }
                
                rfdWrapper.sort(); //Sort using the Comparable interface with the Sort_Order__c value
            
                for(ReasonsForDelinquencyWrapper picklistOption : rfdWrapper){
                    //Add the picklist options
                    listOfReasons.add(new SelectOption(picklistOption.rfd.Name, picklistOption.rfd.Name));
                }
                /*
                for(Reason_For_Delinquency__c picklistOption : Reason_For_Delinquency__c.getAll().values()){
                        
                      listOfReasons.add(new SelectOption(picklistOption.Name, picklistOption.Name));
        
                }
                
                listOfReasons.sort();
                */
                listOfRFDs.addAll(listOfReasons);
                      
                // Get all the Callee Relationships
                for(Callee_Relationship__c picklistOption : Callee_Relationship__c.getAll().values()){
                        
                      listOfCalleeRelationships.add(new SelectOption(picklistOption.Name, picklistOption.Name));
                      
                      try{
                            // Set mapOfBorrowerPositionToRelationship that is used when a different borrower is clicked on.
                            if(picklistOption.Borrower_Position__c != null || picklistOption.Borrower_Position__c != ''){
                                mapOfBorrowerPositionToRelationship.put(picklistOption.Borrower_Position__c, picklistOption);
                            }
                            if(financialAccountCustomer.Borrower_Position__c.equals(picklistOption.Borrower_Position__c)){
                                interactionPanelWrapper.calleeRelationship = picklistOption.Name;
                            }
                      }catch(Exception e){
                            appendErrorMessage('There is no Primary Borrower.');
                      }

                }
                listOfCalleeRelationships.sort();
                
                // Get all the <Name, Type> for Campaigns
                for(Dialer_Campaign__c campaignOption : Dialer_Campaign__c.getAll().values()){
                      mapOfCampaignNameToType.put(campaignOption.Name, campaignOption.Type__c);
                }
        }
    }
    
    public Boolean isValidFinancialID() {
        if(financialAccountId == null || financialAccountId.length() < 15) {
            appendErrorMessage('Invalid Financial Account Record ID.');
            return false;
        }
        
        return true;
    }
        
    /**
     * @author: Stevie ELLA
     * @date: 06/05/2014
     * @description:
     *      Set the active tab. This will be used when saving activities.
     */
    public void setActiveCodeTab(){
            System.debug('SELECTEDTABFUNC = ' + selectedCodeTab);
    }

    private void appendErrorMessage(String errorMessage) {
        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
    
    private void appendErrorMessage(Exception e) {
        appendErrorMessage( e.getMessage() );
    }
    
    /**
     * @author: Paras Dhingra(Appirio)
     * @date: 06/01/2015
     * @description: Story S-310930
     *      Save values of RFD and RFD comment to open collections case.
     */// #Start
    public void saveRFDValues(){
        if(Open_Collection_Cycle_Case!=null && Open_Collection_Cycle_Case.Id!=null)
        {
            try{
                Open_Collection_Cycle_Case.RFD_picklist__c = interactionPanelWrapper.reasonOfDelinquency == null?'':interactionPanelWrapper.reasonOfDelinquency;
                Open_Collection_Cycle_Case.RFD_Text__c = interactionPanelWrapper.reasonOfDelinquencyNote == null?'':interactionPanelWrapper.reasonOfDelinquencyNote;
                update Open_Collection_Cycle_Case;

                }catch(Exception e){

                }
            
        }
    }
    // S-310930 #End
        
    //@RemoteAction
    public void setFinancialAccountIdFromMainTab(){
        //financialAccountId = Apexpages.currentPage().getParameters().get('accountId');
        
        // Get Financial Account Details
        try{
                Id faAccountId = Id.valueOf(financialAccountId);
                financialAccount = [
                            SELECT
                                        Id,
                                        Financial_Account_Number__c,
                                        Total_Amount_Due__c,
                                        Payment_Amount_Past_Due__c,
                                        Payment_Date_Next__c,
                                        History_Counter_Days_Past_Due__c
                            FROM
                                        Financial_Account__c
                            WHERE
                                        //Id = :faAccountId
                                        Id = :financialAccountId
                            LIMIT
                                        1
                ];
                
        }catch(Exception e){
            appendErrorMessage('Financial Account record not found. 1');
        }
        //return null;
    }
    /*Added by Paras Dhingra S-310930 6/1/2015 #Start*/
    public void setOpenCollectionsCase(){// Fetch a related Open Collections Cycle Case. 
        try{
            Id faAccountId = Id.valueOf(financialAccountId);
            Open_Collection_Cycle_Case = new case();
            Open_Collection_Cycle_Case = [ 
                        Select
                                Id,
                                RFD_picklist__c,
                                RFD_Text__c,
                                Status,
                                Financial_Account__c
                        From
                                Case
                        WHERE
                                Financial_Account__c =:faAccountId
                        AND
                                isClosed = false
                        LIMIT
                                1
            ][0];
        }catch(Exception e){
            // Nothing to do
        }
    }
     /*Added by Paras Dhingra S-310930 6/1/2015 #End*/
    /**
     * @author: Stevie ELLA
     * @date: 07/05/2014
     * @description:
     *      Get all the Methods of Payment for the picklist 
     */
    public List<SelectOption> getMethodsOfPayment() {

            return listOfMethodsOfPayment;
            
    }
    
    /**
     * @author: Stevie ELLA
     * @date: 13/05/2014
     * @description:
     *      Get all the VPA for the picklist 
     */
    public List<SelectOption> getListOfVPAs() {

            return listOfVPAs;
            
    }
    
    /**
     * @author: Stevie ELLA
     * @date: 14/05/2014
     * @description:
     *      Get all the Callee Relationships for the picklist 
     */
    public List<SelectOption> getListOfCalleeRelationships() {

            return listOfCalleeRelationships;
            
    }
    
    /**
     * @author: Stevie ELLA
     * @date: 22/05/2014
     * @description:
     *      Get all the RFD for the picklist 
     */
    public List<SelectOption> getListOfRFDs() {

            return listOfRFDs;
            
    }
    
    /**
     * @author: Stevie ELLA
     * @date: 06/05/2014
     * @description:
     *      Get all the activity codes records flagged for Quick (From listOfValidQuickActivityCodes) and add their "name - description" as option for the Quick code picklist 
     */
    public List<SelectOption> getQuickCodeItems() {

            return getCodeItems(mapOfValidQuickActivityCodes.values(),'Quick');
            
    }

    /**
     * @author: Stevie ELLA
     * @date: 06/05/2014
     * @description:
     *      Get all the activity codes records flagged for Skip (From listOfValidSkipActivityCodes) and add their "name - description" as option for the Quick code picklist 
     */
    public List<SelectOption> getSkipCodeItems() {

            return getCodeItems(mapOfValidSkipActivityCodes.values(),'Skip');
    }
 
    /**
     * @author: Stevie ELLA
     * @date: 06/09/2014
     * @description:
     *      Get all the talking point articles 
     */
    public List<KnowledgeArticleWrapper> getTalkingPoints() {
            List<Collections_Talking_Point__kav> listOfTalkingPoints = new List<Collections_Talking_Point__kav>(
                    [
                            SELECT
                                    Id,
                                    Title,
                                    Sort__c,
                                    Summary,
                                    Details__c,
                                    Add_to_Standard_Note__c
                            FROM
                                    Collections_Talking_Point__kav
                            WHERE
                                    Language = 'en_US' and PublishStatus = 'Online'
                            ORDER BY
                                    Sort__c ASC
                    ]
            );
            
            List<KnowledgeArticleWrapper> listOfTalkingPointsWrapped = new List<KnowledgeArticleWrapper>(); 
            for(Collections_Talking_Point__kav article : listOfTalkingPoints){
                KnowledgeArticleWrapper articleWrapper = new KnowledgeArticleWrapper();
                articleWrapper.article = article;
                articleWrapper.isSelected = false;
                listOfTalkingPointsWrapped.add(articleWrapper);
            }
            return listOfTalkingPointsWrapped;
    }
       
    /*public List<SelectOption> getCodeItems(List<Activity_Code__c> listOfActivityCodes){
        
            List<SelectOption> codeOptions = new List<SelectOption>();
            List<SelectOption> resultingCodeOptions = new List<SelectOption>();
            resultingCodeOptions.add(new SelectOption('None','None'));
            
            for(Activity_Code__c activityCode: listOfActivityCodes){
            
                codeOptions.add(new SelectOption(activityCode.Name, activityCode.Name + ' - ' + activityCode.Description__c));
            
            }

            //codeOptions.sort();
            resultingCodeOptions.addAll(codeOptions);
            return resultingCodeOptions;
        
    }*/
    
    public List<SelectOption> getCodeItems(List<Activity_Code__c> listOfActivityCodes, String codeType){
        System.debug('************ getting code items for ' + listOfActivityCodes.size() + ' codes');
        List<SelectOption> codeOptions = new List<SelectOption>();
        List<ActivityCodeWrapper> codeWrapper = new List<ActivityCodeWrapper>(); // Wrapper used for custom sort
        List<SelectOption> resultingCodeOptions = new List<SelectOption>();
        resultingCodeOptions.add(new SelectOption('None','None'));
        
        for(Activity_Code__c activityCode: listOfActivityCodes){
            //Add the list of codes to the wrapper list
            codeWrapper.add( new ActivityCodeWrapper(activityCode, codeType));
            //codeOptions.add(new SelectOption(activityCode.Name, activityCode.Name + ' - ' + activityCode.Description__c));
        
        }
    
        codeWrapper.sort(); //Sort using the Comparable interface with the appropriate sort order column
    
        for(ActivityCodeWrapper picklistOption : codeWrapper){
            //Add the picklist options
            codeOptions.add( new SelectOption(picklistOption.activityCode.Name, picklistOption.activityCode.Name + ' - ' + picklistOption.activityCode.Description__c));
    
        }
        
        resultingCodeOptions.addAll(codeOptions);
        System.debug('***************** result size: ' + resultingCodeOptions.size());
        return resultingCodeOptions;
            
    }
    
    public String getRPCCodeQuery(){
        
        List<String> queriesRPCCode = new List<String>();
        
        // Talked To
        if(!''.equals(interactionPanelWrapper.calleeRelationship) && interactionPanelWrapper.calleeRelationship != null){
            queriesRPCCode.add('Talked_To__c INCLUDES (\'' + interactionPanelWrapper.calleeRelationship + '\')');
        }
        
        //Promise-to-pay #1
        if(!''.equals(interactionPanelWrapper.firstMethodOfPayment) && interactionPanelWrapper.firstMethodOfPayment != null){
            queriesRPCCode.add('Payment_Method__c INCLUDES (\'' + interactionPanelWrapper.firstMethodOfPayment + '\')');
        }
        
        //Phone number type Modified By Sandeep and Sirin
         if(!TFSC_Utils.isNullOrEmpty(lastDialedPhoneNumber))
         {
        String phoneNumberType = getTypeOfDialedPhoneNumber(lastDialedPhoneNumber, financialAccountCustomer, true);
        
        //RM - 10/21/2014 - US512 - START
        Boolean kvpRoutedBool = (isKVPRouted != null && isKVPRouted == 'Y'); //Rajesh - hardcoding for now, will replace with value from VF UI
        if (!kvpRoutedBool) //Current Outbound Scenario
            queriesRPCCode.add('(Phone_Type__c = \'' + phoneNumberType + '\' OR Phone_Type__c = \'\')');
        else
            queriesRPCCode.add('(Phone_Type__c = \'INBOUND\' OR Phone_Type__c = \'\')');
        //RM - 10/21/2014 - US512 - END
        
        }
        //Flag for RPC
        queriesRPCCode.add('Flag_RPC__c = true');
        
        return String.join(queriesRPCCode, ' AND ');
    }
    
    /**
     * @author: Stevie ELLA
     * @date: 06/08/2014
     * @description:
     *      Get all the activity codes records flagged for RPC (From listOfValidRPCActivityCodes) and add their "name - description" as option for the Quick code picklist 
     */
    public List<SelectOption> getRPCCodeItems() {

            //return getCodeItems(mapOfValidRPCActivityCodes.values());
            String query = getRPCCodeQuery();
            List<Activity_Code__c> listOfRPCCodes = new List<Activity_Code__c>();
            listOfRPCCodes = Database.query('SELECT Id, Name, Description__c,Collection_Activity_Code__c,Flag_RPC__c FROM Activity_Code__c WHERE ' + query + ' ORDER BY Sort_Order_RPC__c ASC');
            
            List<SelectOption> listOfRPCOptions = new List<SelectOption>();
            List<SelectOption> listOfRPCOptionsWithNone = new List<SelectOption>();
            listOfRPCOptionsWithNone.add(new SelectOption('None', 'None'));
            for(Activity_Code__c code: listOfRPCCodes){
                listOfRPCOptions.add(new SelectOption(code.Name, code.Name + ' - ' + code.Description__c));
            }
            //listOfRPCOptions.sort();
            listOfRPCOptionsWithNone.addAll(listOfRPCOptions);
            
            return listOfRPCOptionsWithNone;
            
    }
     
    public String getTypeOfDialedPhoneNumber(String dialedNumber, Financial_Account_Customer__c fac, Boolean firstTime){
            String strToReturn = TFSC_Constants.PHONE_TYPE_HOME;
            if(fac != null && dialedNumber != null && dialedNumber.length() > 0) {
                String cleanedDialedNumber = dialedNumber.replaceAll('[^0-9]',''); 
                
                if(  
                     (!TFSC_Utils.isNullOrEmpty(fac.Home_Phone_Garage__c) && fac.Home_Phone_Garage__c.replaceAll('[^0-9]','').contains(cleanedDialedNumber))
                     ||
                     (!TFSC_Utils.isNullOrEmpty(fac.HomePhone_BillTo__c) && fac.HomePhone_BillTo__c.replaceAll('[^0-9]','').contains(cleanedDialedNumber))
                   ) 
                {
                    strToReturn = TFSC_Constants.PHONE_TYPE_HOME ;
                }
                else if( !TFSC_Utils.isNullOrEmpty(fac.Mobile_Phone__c) && fac.Mobile_Phone__c.replaceAll('[^0-9]','').contains(cleanedDialedNumber) ){
                    strToReturn = TFSC_Constants.PHONE_TYPE_MOBILE;
                }
                else if(  
                         (!TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Garage__c) && fac.Work_Phone_Garage__c.replaceAll('[^0-9]','').contains(cleanedDialedNumber) ) 
                         || 
                         (!TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Bill_To__c) && fac.Work_Phone_Bill_To__c.replaceAll('[^0-9]','').contains(cleanedDialedNumber) )
                        )
                {
                    strToReturn = TFSC_Constants.PHONE_TYPE_WORK;
                }
                
                
                if(firstTime && strToReturn == TFSC_Constants.PHONE_TYPE_HOME) {
                    
                    Financial_Account_Customer__c[] facList;
                    
                    if(fac.Borrower_Position__c == 'Primary') {
                        facList = [select id, Work_Phone_Bill_To__c, Work_Phone_Garage__c, Mobile_Phone__c, HomePhone_BillTo__c, Home_Phone_Garage__c, Borrower_Position__c
                                                       from Financial_Account_Customer__c
                                                       where Financial_Account__c = :financialAccountId
                                                       and Borrower_Position__c <> 'Primary'
                                                       and (not Financial_Account_Customer__c like '%Inactive%')];
                    }else{
                        facList = [select id, Work_Phone_Bill_To__c, Work_Phone_Garage__c, Mobile_Phone__c, HomePhone_BillTo__c, Home_Phone_Garage__c, Borrower_Position__c
                                                       from Financial_Account_Customer__c
                                                       where Financial_Account__c = :financialAccountId
                                                       and Borrower_Position__c = 'Primary'
                                                       and (not Financial_Account_Customer__c like '%Inactive%')];
                    }
                    if(facList != null && facList.size() > 0) {
                        String tmpStrToReturn;
                        for(Financial_Account_Customer__c relatedFac : facList) {
                            tmpStrToReturn = getTypeOfDialedPhoneNumber(dialedNumber, relatedFac, false);
                            if(tmpStrToReturn != TFSC_Constants.PHONE_TYPE_HOME) {
                                strToReturn = tmpStrToReturn;
                            }
                        }
                    }
                }
                
            }
            
                
            
            return strToReturn;
    }
    
    
     /**
     * @author: Stevie ELLA
     * @date: 06/05/2014
     * @description:
     *      Save activities: Only save activities for the active tab and when the code has been defined
     */
    private void saveActivities(Boolean resetErrorString) {
        if(resetErrorString) {
            saveResponseErrorMessage = '';
        }
        
        
        List<Task> activitiesToInsert = new List<Task>();
        Activity_Code__c selectedCode;
        Id whatId = getWhatIdFinancialAccount(financialAccount);
        
        InteractionPanelWrapper parsedInteractionPanelWrapper = interactionPanelWrapper.clone();
        
        if(currentCodeTab == TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB && interactionPanelWrapper.quickCode != null && interactionPanelWrapper.quickCode != '' && interactionPanelWrapper.quickCode != TFSC_Constants.PICKLIST_NONE_VALUE){
            
            selectedCode = mapOfValidQuickActivityCodes.get(interactionPanelWrapper.quickCode);
            // Create the activity
            Task quickActivity = new Task(
                    Description = interactionPanelWrapper.quickNote,
                    Collection_Activity_Code__c = selectedCode.Name,
                    Subject = selectedCode.Name + ' - ' + selectedCode.Description__c,
                    Financial_Account__c = financialAccount.Id,
                    Financial_Account_Number__c = financialAccount.Financial_Account_Number__c,
                    Status = TFSC_Constants.ACTIVITY_STATUS_COMPLETED,
                    WhatId = whatId,
                    ActivityDate = Date.today()
            );
             //added by suman & Sandeep , date - 09/09/2015 *start*            
            //  system.debug('quickOKTEST0'+interactionPanelWrapper.firstPromiseDate);
                    // Add first promise to pay if date and amount are not null/empty
                    // Commented by Sandeep on 9/25
                  /*  if(interactionPanelWrapper.firstPromiseDate != null && interactionPanelWrapper.firstPromiseDate != '' && TFSC_Utils.getDecimalCurrencyValue(interactionPanelWrapper.firstAmountPTP) != 0 && interactionPanelWrapper.firstAmountPTP != ''){                   
                     quickActivity.Collection_Activity_Promise_Date_1__c = Date.parse(interactionPanelWrapper.firstPromiseDate);
                     quickActivity.Collection_Activity_Promise_Amount_1__c = TFSC_Utils.getDecimalCurrencyValue(interactionPanelWrapper.firstAmountPTP); 
                                }*/
                    
             //added by suman & Sandeep, date - 09/09/2015 *End* 
            activitiesToInsert.add(quickActivity);
            
            // Clear the fields so that it reset the form
            interactionPanelWrapper.quickCode = TFSC_Constants.PICKLIST_NONE_VALUE;
            interactionPanelWrapper.quickNote = '';
        }
        
        // For RPC only, include promise to payment, if any. And update financial account total amount due.
        if(currentCodeTab == TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB && interactionPanelWrapper.rpcCode != null && interactionPanelWrapper.rpcCode != '' && interactionPanelWrapper.rpcCode != TFSC_Constants.PICKLIST_NONE_VALUE){
            
            // Only create the activity if the promises passed the date rules validations
                    selectedCode = mapOfValidRPCActivityCodes.get(interactionPanelWrapper.rpcCode);
                    // Create the activity
                    Task rpcActivity = new Task(
                            Description = interactionPanelWrapper.rpcNote,
                            Collection_Activity_Code__c = selectedCode.Name,
                            Subject = selectedCode.Name + ' - ' + selectedCode.Description__c,
                            Financial_Account__c = financialAccount.Id,
                            Financial_Account_Number__c = financialAccount.Financial_Account_Number__c,
                            Status = TFSC_Constants.ACTIVITY_STATUS_COMPLETED,
                            WhatId = whatId,
                            ActivityDate = Date.today()
                            
                    );
                    
                    // Add first promise to pay if date and amount are not null/empty
                    if(interactionPanelWrapper.firstPromiseDate != null && interactionPanelWrapper.firstPromiseDate != '' && TFSC_Utils.getDecimalCurrencyValue(interactionPanelWrapper.firstAmountPTP) != 0 && interactionPanelWrapper.firstAmountPTP != ''){
                    
                        rpcActivity.Collection_Activity_Promise_Date_1__c = Date.parse(interactionPanelWrapper.firstPromiseDate);
                        rpcActivity.Collection_Activity_Promise_Amount_1__c = TFSC_Utils.getDecimalCurrencyValue(interactionPanelWrapper.firstAmountPTP);
                    
                    }
                    
                    // Add second promise to pay if date and amount are not null/empty
                    if(interactionPanelWrapper.secondPromiseDate != null && interactionPanelWrapper.secondPromiseDate != '' && TFSC_Utils.getDecimalCurrencyValue(interactionPanelWrapper.secondAmountPTP) != 0 && interactionPanelWrapper.secondAmountPTP != ''){
                    
                        rpcActivity.Collection_Activity_Promise_Date_2__c = Date.parse(interactionPanelWrapper.secondPromiseDate);
                        rpcActivity.Collection_Activity_Promise_Amount_2__c = TFSC_Utils.getDecimalCurrencyValue(interactionPanelWrapper.secondAmountPTP);
                    
                    }
                    activitiesToInsert.add(rpcActivity);
        
                    // Clear the fields so that it reset the form
                    interactionPanelWrapper.rpcCode = TFSC_Constants.PICKLIST_NONE_VALUE;
                    interactionPanelWrapper.rpcNote = '';
                    interactionPanelWrapper.clearPTP();

         }
        
        if(currentCodeTab == TFSC_Constants.INTERACTION_ENTRY_PANEL_SKIP_TAB && interactionPanelWrapper.skipCode != null && interactionPanelWrapper.skipCode != '' && interactionPanelWrapper.skipCode != TFSC_Constants.PICKLIST_NONE_VALUE){
            
            selectedCode = mapOfValidSkipActivityCodes.get(interactionPanelWrapper.skipCode);
            // Create the activity
            Task skipActivity = new Task(
                    Description = interactionPanelWrapper.skipNote,
                    Collection_Activity_Code__c = selectedCode.Name,
                    Subject = selectedCode.Name + ' - ' + selectedCode.Description__c,
                    Financial_Account__c = financialAccount.Id,
                    Financial_Account_Number__c = financialAccount.Financial_Account_Number__c,
                    Status = TFSC_Constants.ACTIVITY_STATUS_COMPLETED,
                    WhatId = whatId,
                    ActivityDate = Date.today()
            );
            
            if(newPassStrategy != null) {
                skipActivity.Collection_Recommended_Pass_Strategy__c = newPassStrategy;
            }
            
            activitiesToInsert.add(skipActivity);
            
            // Clear the fields so that it reset the form
            interactionPanelWrapper.skipCode = TFSC_Constants.PICKLIST_NONE_VALUE;
            interactionPanelWrapper.skipNote = '';
        }
        
        try{
            insert activitiesToInsert;
        }catch(Exception e){
            interactionPanelWrapper = parsedInteractionPanelWrapper;
            saveResponseErrorMessage = e.getMessage();
            
           //added by suman & Sandeep , date - 09/09/2015 *start* 
            string strquickOver = 'Notes may not exceed 450 characters for a collection activity. Use a CONT activity on the Quick tab to continue your note.';          
            
            /*if(saveResponseErrorMessage !=null && saveResponseErrorMessage!='' && saveResponseErrorMessage.contains('Collection_Activity_Promise_Date_1__c') ) {
               saveResponseErrorMessage = 'Promise to pay 1 is required for the selected activity code';         
               appendErrorMessage(saveResponseErrorMessage);
            } else */
                if(saveResponseErrorMessage !=null && saveResponseErrorMessage!='' && saveResponseErrorMessage.contains(strquickOver) ) {
               saveResponseErrorMessage = 'Notes may not exceed 450 characters for a collection activity. Use a CONT activity on the Quick tab to continue your note';         
               appendErrorMessage(saveResponseErrorMessage);
            } else if(saveResponseErrorMessage !=null && saveResponseErrorMessage!='' && saveResponseErrorMessage.contains('STRING_TOO_LONG') ) {
               saveResponseErrorMessage = 'String too long, Quick code limit exceeded (max length =32000)';         
               appendErrorMessage(saveResponseErrorMessage);
            }
           
           //added by suman & Sandeep , date - 09/09/2015 *End* 
        }
    }
    
   
    public PageReference saveActivities() {
        
        saveActivities(true);
        
        return null;
    }
    
    public static Boolean isPTPDataValid(String promiseDate, String promiseMethod, String promiseAmount){
        
        // If at least one of the promise data is not null/empty
        if((promiseDate.trim() != '' && promiseDate != null) || (promiseMethod.trim() != TFSC_Constants.PICKLIST_NONE_VALUE && !promiseMethod.trim().equals('')) || (promiseAmount.trim() != '' && promiseAmount != null)){
            
            // The all the data must be non-empty
            if((promiseDate.trim() != '' && promiseDate != null) && (promiseMethod.trim() != TFSC_Constants.PICKLIST_NONE_VALUE) && (promiseAmount.trim() != '' && promiseAmount != null)){
            
                return true;
            
            }else{
                return false;
            }
        }else{
            //If all the data are null/empty 
            return true; 
        }
    
    }
    
    public Id getWhatIdFinancialAccount(Financial_Account__c financialAccount){
    
        List<Case> listCasesOfFinancialAccount;
        try{
            listCasesOfFinancialAccount = 
            [
                SELECT
                        Id
                FROM
                        Case
                WHERE
                        Integration_ID__c = :financialAccount.Financial_Account_Number__c + 'COL'
            ];
        }catch(Exception e){
            appendErrorMessage('Financial Account record does not exist.');
        }
    
        if(listCasesOfFinancialAccount.size() != 0)
            return listCasesOfFinancialAccount.get(0).Id;
        else
            return financialAccount.Id;
    }
    
    public PageReference saveAllActivities(){
        
        String parsedCurrentTab = currentCodeTab;
        
        saveResponseErrorMessage = '';
        
        currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB;
        saveActivities(false);
        
        currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
        saveActivities(false);
        
        currentCodeTab = TFSC_Constants.INTERACTION_ENTRY_PANEL_SKIP_TAB;
        saveActivities(false);


        currentCodeTab = parsedCurrentTab;
        
        return null;
        
    }
    
    
    /**
     * For error reporting
     */
    @RemoteAction
    global static void saveNewSystemMessage(String description, Boolean notifyUser, String source, String title, String msgType) {
        System_Message__c sysMsg = new System_Message__c();
        sysMsg.Description__c = description;
        sysMsg.Notify_User__c = notifyUser;
        sysMsg.Source__c = source;
        sysMsg.Type__c = msgType;
        sysMsg.Title__c = title;
        
        insert sysMsg;
    }
    
    
    @RemoteAction
    global static Collections_Pass_Strategy__c updateCaseAndTaskWithSkipTraceEdits(String faId, String passStratName, string fAcctype, string previousPass) {
        Collections_Pass_Strategy__c passStratToReturn ;
        
        try {
            
            Map<Integer,Collections_Pass_Strategy__c> mapOfPassStrategyNumberToPassStrat = new Map<Integer,Collections_Pass_Strategy__c>();
            Map<String,Collections_Pass_Strategy__c> mapOfArticleNumStringToPassStrat = new Map<String,Collections_Pass_Strategy__c>();
            Map<String,Collections_Pass_Strategy__c> mapOfPassStratNameToPassStrat = new Map<String,Collections_Pass_Strategy__c>();
            for(Collections_Pass_Strategy__c passStrat : [select name, Sort__c, Article_Number__c, Standard_Note__c, RES__c, Account_type__c 
                                                            from Collections_Pass_Strategy__c where Account_type__c = :fAcctype
                                                            order by Sort__c]) //Modified by Shashank Singhal for S-330388
            {
                mapOfPassStrategyNumberToPassStrat.put( Integer.valueOf(passStrat.Sort__c), passStrat);
                mapOfArticleNumStringToPassStrat.put(passStrat.Article_Number__c, passStrat);
                mapOfPassStratNameToPassStrat.put(passStrat.Name, passStrat);
            }
            
            Case caseToUpdate;
            for(Case collectionCase : [select id, status, Previous_Pass__c //Modified by Shashank Singhal for S-330388
                                        from case
                                        where Financial_Account__c = :faId 
                                        and RecordType.Name = 'Collection'
                                        and isClosed = false
                                        limit 1])
            {
                //Collections_Pass_Strategy__c passStrat = mapOfPassStratNameToPassStrat.get(passStratName);
                if(passStratName != null && passStratName.length() > 0) {
                    collectionCase.Status = passStratName;
                    collectionCase.Previous_Pass__c = Integer.valueOf(previousPass);//Modified by Shashank Singhal for S-330388
                    caseToUpdate = collectionCase;
                }
            }
            
            if(caseToUpdate != null) {
                update caseToUpdate;
            }
        }
        catch (Exception e) {
        }
        
        return passStratToReturn;
    }
   
       
    @RemoteAction
    global static String getCampaignTypeFromName(String campaignName) {
            String campaignType = '';
            if(campaignName != null && !campaignName.equals('')){
                Dialer_Campaign__c campaign  = Dialer_Campaign__c.getInstance(campaignName);
                if(campaign != null)
                    campaignType = campaign.Type__c;
            }
            return campaignType;
    }
    
    @RemoteAction
    global static Activity_Code__c getActivityCodeObjectFromActivityName(String activityName) {
        Activity_Code__c actCodeToReturn;
        if(!TFSC_Utils.isNullOrEmpty(activityName)) {
            
            for(Activity_Code__c ac : [SELECT Id,
                                        Name, Description__c, Collection_Activity_Code__c, 
                                        CTI_Reason__c, CTI_Result__c
                                        From Activity_Code__c
                                        WHERE  CTI_Activity__c = true
                                        and Name = :activityName
                                        ]) 
            {
                actCodeToReturn = ac; //should only be one -- no need to code for null lists.
            }
        }
        
        return actCodeToReturn;
    }
    
    @RemoteAction
    global static Activity_Code__c getInOrderValidActivityCodeObjectFromActivityName(String rpcCode, String quickCode, String skipCode) {
        Activity_Code__c actCodeToReturn;
        List<String> listOfCodes = new List<String>();
        if(!TFSC_Utils.isNullOrEmpty(rpcCode)){
            listOfCodes.add(rpcCode);
        }
        if(!TFSC_Utils.isNullOrEmpty(quickCode)){
            listOfCodes.add(quickCode);
        }
        if(!TFSC_Utils.isNullOrEmpty(skipCode)){
            listOfCodes.add(skipCode);
        }
        
        if(listOfCodes.size() > 0) {
            Map<String, Activity_Code__c> mapActivityCodeNameToActivityCode = new Map<String, Activity_Code__c>();
            for(Activity_Code__c ac : [SELECT Id,
                                        Name, Description__c, Collection_Activity_Code__c, 
                                        CTI_Reason__c, CTI_Result__c
                                        From Activity_Code__c
                                        WHERE  CTI_Activity__c = true
                                        and Name in :listOfCodes
                                        ]) 
            {
                mapActivityCodeNameToActivityCode.put(ac.Name, ac);
            }
            
            // First check if RPC code is not null and has a reason/result
            if(!TFSC_Utils.isNullOrEmpty(rpcCode) && mapActivityCodeNameToActivityCode.containsKey(rpcCode)){
                actCodeToReturn = mapActivityCodeNameToActivityCode.get(rpcCode);
            }else if(!TFSC_Utils.isNullOrEmpty(quickCode) && mapActivityCodeNameToActivityCode.containsKey(quickCode)){
                actCodeToReturn = mapActivityCodeNameToActivityCode.get(quickCode);
            }else if(!TFSC_Utils.isNullOrEmpty(skipCode) && mapActivityCodeNameToActivityCode.containsKey(skipCode)){
                actCodeToReturn = mapActivityCodeNameToActivityCode.get(skipCode);
            }
        }
        
        return actCodeToReturn;
    }
    
    @RemoteAction
    global static String getCampaignType(){
        //mapOfBorrowerPositionToRelationship
        return '';
    }
    @RemoteAction
    global static Map<String, Boolean> validatePromiseData(
        String promiseToPayDate_1, 
        String promiseToPayMethod_1, 
        String promiseToPayAmount_1,
        String promiseToPayConfirmation_1,
        String promiseToPayDate_2, 
        String promiseToPayMethod_2,
        String promiseToPayAmount_2,
        String promiseToPayConfirmation_2,
        String quickCode,
        String quickNote,
        String rpcCode,
        String rpcNote,
        String skipCode,
        String skipNote,
        String tabName
    ){

        Map<String, Boolean> mapCodeRules = new Map<String, Boolean>();
        Date todayDate = Date.today();
        
        //validating for all tabs
        if( !TFSC_Utils.isNullOrEmpty(promiseToPayDate_1) && !TFSC_Utils.isNullOrEmpty(promiseToPayDate_2) ) {
            Date tmpDate1 = Date.parse(promiseToPayDate_1);
            Date tmpDate2 = Date.parse(promiseToPayDate_1);
            
            if(tmpDate1 != null && tmpDate2 != null && tmpDate1 > tmpDate2) {
                mapCodeRules.put(TFSC_Constants.PTP_DATE2_LESS_THAN_DATE1, false);
            }
        }
        
        if(tabname.equals(TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB)){
            mapCodeRules.putAll(checkRPCCodeRules(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1, rpcCode, rpcNote, tabName));
            
                Map<String, Boolean> mapSecondPromiseResult = checkPromiseToPayRules(promiseToPayDate_2, promiseToPayMethod_1, promiseToPayMethod_2, promiseToPayDate_1, promiseToPayConfirmation_2, '2');
                Map<String, Boolean> mapFirstPromiseResult = checkPromiseToPayRules(promiseToPayDate_1, promiseToPayMethod_1, null, todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year(), promiseToPayConfirmation_1, '1');
                
                Map<String, Boolean> mapPromisesResult = new Map<String, Boolean>();
                
                mapPromisesResult.putAll(mapFirstPromiseResult);
                mapPromisesResult.putAll(mapSecondPromiseResult);
                if(!TFSC_InteractionEntryPanelController.isPTPDataValid(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1)){
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_FIRST, false);
                }else{
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_FIRST, true);
                }
                if(!TFSC_InteractionEntryPanelController.isPTPDataValid(promiseToPayDate_2, promiseToPayMethod_2, promiseToPayAmount_2)){
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_SECOND, false);
                }else{
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_SECOND, true);
                }
                
                mapCodeRules.putAll(mapPromisesResult);
        }else{
            //if the tabName is empty/null, check the rules for all 3 tabs:
            if(quickCode != null && !quickCode.equals('')){
                tabName = TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB;
                mapCodeRules.putAll(checkRPCCodeRules(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1, quickCode, quickNote, tabName));
            }
            
            if(rpcCode != null && !rpcCode.equals('')){
                tabName = TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB;
                mapCodeRules.putAll(checkRPCCodeRules(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1, rpcCode, rpcNote, tabName));
                
                Map<String, Boolean> mapFirstPromiseResult = checkPromiseToPayRules(promiseToPayDate_1, promiseToPayMethod_1, null, todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year(), promiseToPayConfirmation_1, '1');
                Map<String, Boolean> mapSecondPromiseResult = checkPromiseToPayRules(promiseToPayDate_2, promiseToPayMethod_1, promiseToPayMethod_2, promiseToPayDate_1, promiseToPayConfirmation_2, '2');
                        
                Map<String, Boolean> mapPromisesResult = new Map<String, Boolean>();
                
                mapPromisesResult.putAll(mapFirstPromiseResult);
                mapPromisesResult.putAll(mapSecondPromiseResult);
                if(!TFSC_InteractionEntryPanelController.isPTPDataValid(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1)){
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_FIRST, false);
                }else{
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_FIRST, true);
                }
                if(!TFSC_InteractionEntryPanelController.isPTPDataValid(promiseToPayDate_2, promiseToPayMethod_2, promiseToPayAmount_2)){
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_SECOND, false);
                }else{
                    mapPromisesResult.put(TFSC_Constants.COMPLETE_DATA_MAP_KEY_SECOND, true);
                }
                
                mapCodeRules.putAll(mapPromisesResult);
            }
            
            if(skipCode != null && !skipCode.equals('')){
                tabName = TFSC_Constants.INTERACTION_ENTRY_PANEL_SKIP_TAB;
                mapCodeRules.putAll(checkRPCCodeRules(promiseToPayDate_1, promiseToPayMethod_1, promiseToPayAmount_1, skipCode, skipNote, tabName));
            }
        }
        return mapCodeRules;
            
    }

    @RemoteAction
    global static Map<String, Boolean> checkRPCCodeRules(String promiseToPayDate, String promiseToPayMethod,  String promiseToPayAmount, String code, String note, String tabName){
        Map<String, Boolean> codeRules = new Map<String, Boolean>();
        
        // Get the activity code
        Activity_Code__c activityCode = TFSC_Utils.getActivityCodeByName(code);
        if(activityCode != null ){
                // Set RPC code rules for Promise To Pay
            if(tabname.equals(TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB)){
                if(activityCode.Flag_Promise_Required__c){
                    codeRules.put(TFSC_Constants.RPC_CODE_PTP_NOT_ALLOWED, true);
                    if(!promiseToPayDate.trim().equals('') && !promiseToPayMethod.equals(TFSC_Constants.PICKLIST_NONE_VALUE) && !promiseToPayAmount.trim().equals('')){
                        codeRules.put(TFSC_Constants.RPC_CODE_PTP_REQUIRED, true);
                    }else{
                        codeRules.put(TFSC_Constants.RPC_CODE_PTP_REQUIRED, false);
                    }
                }else{
                    codeRules.put(TFSC_Constants.RPC_CODE_PTP_REQUIRED, true);
                    if(promiseToPayDate.trim().equals('') && promiseToPayMethod.equals(TFSC_Constants.PICKLIST_NONE_VALUE) && promiseToPayAmount.trim().equals('')){
                        codeRules.put(TFSC_Constants.RPC_CODE_PTP_NOT_ALLOWED, true);
                    }else{
                        codeRules.put(TFSC_Constants.RPC_CODE_PTP_NOT_ALLOWED, false);
                    }
                }
            }
            
            // Set code rules for Note
            String mapKey;
            if(tabName.equals(TFSC_Constants.INTERACTION_ENTRY_PANEL_RPC_TAB))
                mapKey = TFSC_Constants.RPC_CODE_NOTE_REQUIRED;
            else if(tabName.equals(TFSC_Constants.INTERACTION_ENTRY_PANEL_QUICK_TAB))
                mapKey = TFSC_Constants.QUICK_CODE_NOTE_REQUIRED;
            else if(tabName.equals(TFSC_Constants.INTERACTION_ENTRY_PANEL_SKIP_TAB))
                mapKey = TFSC_Constants.SKIP_CODE_NOTE_REQUIRED;
            
    
            if(activityCode.Flag_Notes_Required__c && note.trim().equals('')){
                codeRules.put(mapKey, false);
            }else{
                codeRules.put(mapKey, true);
            }
        }
        
        return codeRules;
    }

    @RemoteAction
    global static Map<String, Boolean> checkPromiseToPayRules(String promiseToPayDate, String promiseToPayMethod_1, String promiseToPayMethod_2, String startDateText, String confirmation, String promiseNumber){
        
        Map<String, Boolean> resultsMap = new Map<String, Boolean>();
        String key, wuspConfirmationKey;
        String promiseToPayMethodForDateVal, promiseToPayMethod;
        if(promiseNumber.equals('1')){
            key = TFSC_Constants.PTP_DATES_MAP_KEY_FIRST;
            wuspConfirmationKey = TFSC_Constants.PTP_WUSP_CONFIRMATION_REQUIRED_MAP_KEY_FIRST;
            promiseToPayMethodForDateVal = promiseToPayMethod_1;
            promiseToPayMethod = promiseToPayMethod_1;
        }else{
            key = TFSC_Constants.PTP_DATES_MAP_KEY_SECOND;
            wuspConfirmationKey = TFSC_Constants.PTP_WUSP_CONFIRMATION_REQUIRED_MAP_KEY_SECOND;
            promiseToPayMethodForDateVal = promiseToPayMethod_1;
            promiseToPayMethod = promiseToPayMethod_2;
        }
        // If both the date and the method are not set, it is valid.
        if(
            ((promiseToPayDate == null || promiseToPayDate.trim().equals(''))
            && (promiseToPayMethod.equals('None')))
            ||
            promiseToPayMethod.equals('None')
        ){
            return new Map<String, Boolean>{key => true, wuspConfirmationKey => true};
        }
        
        //mapOfNameToMethodsOfPayment = Payment_Method__c.getAll();
        Payment_Method__c methodOfPayment = Payment_Method__c.getInstance(promiseToPayMethodForDateVal); 
        //mapOfNameToMethodsOfPayment.get(promiseToPayMethod); 
        
        // If the payment method is not valid, it's not valid
        if(methodOfPayment == null)
            return new Map<String, Boolean>{key => false, wuspConfirmationKey => true};
        
        // If the promise date or start date is not valid, it is not valid
        Date startDate;
        Date promiseDate;
        
        try{
            startDate = Date.parse(startDateText);
            promiseDate = Date.parse(promiseToPayDate);
        }catch(Exception e){
            return new Map<String, Boolean>{key => false, wuspConfirmationKey => true};
        }
        
        // If method is WUSP and Confirmation is Null/Empty
        if(promiseToPayMethod.equals(TFSC_Constants.PTP_METHOD_CONFIRMATION_REQUIRED_WUSP_CODE) && confirmation.trim().equals('')){
            resultsMap.put(wuspConfirmationKey, false);
        }else{
            resultsMap.put(wuspConfirmationKey, true);
        }
            
        Integer numberOfValidDays = Integer.valueOf(methodOfPayment.Promise_Days__c);
        Date validLimitDate = TFSC_Utils.getLimitDate(startDate, numberOfValidDays);
        if(promiseDate > validLimitDate || promiseDate < startDate || TFSC_Utils.isWeekendDay(promiseDate)){
            resultsMap.put(key, false);
        }else{
            resultsMap.put(key, true);
        }
        
        return resultsMap;
    }
    
    public void updateBalances(){

        try{
            
            interactionPanelWrapper.firstBalancePTP = interactionPanelWrapper.totalAmountDue - interactionPanelWrapper.getCleanFirstAmount();
            interactionPanelWrapper.secondBalancePTP = interactionPanelWrapper.firstBalancePTP - interactionPanelWrapper.getCleanSecondAmount();
            
        }catch(Exception e){
            appendErrorMessage(e.getMessage());
        }
    }
    
    /*
    * @author   Stevie Ella
    * @date 5/20/2014
    * @description: Update the talkTo field when a FA customer link is clicked on.
    */
    public void changeTalkToData(){
        //Initialized the object to avoid Null Reference Exception by Suman & Sandeep, 09/09/2015
         Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
         // Changes made by Paras Dhingra for Story S-310348 #Start 6/29/2015
         // Fetch all the financial account customers
         Map <Id,Financial_Account_Customer__c> facMap  = new Map<Id, Financial_Account_Customer__c>();
         Boolean isManuallyAdded = true;
         try{
            /*fac = [
                    SELECT 
                            id, 
                            Borrower_Position__c,
                            Account__r.Name
                    FROM 
                            Financial_Account_Customer__c
                    WHERE 
                            Id = :clickedId
                    LIMIT 
                            1
                  ];
            */
            // fetch all related FACs to compare the existing value with
            facMap = new Map<Id, Financial_Account_Customer__c>( [ 
                    SELECT 
                            id, 
                            Borrower_Position__c,
                            Account__r.Name
                    FROM 
                            Financial_Account_Customer__c
                    WHERE 
                            Financial_Account__c = :financialAccountId
                  ]);

         }catch(Exception e){
         }
         if(facMap!=null){
            for(Financial_Account_Customer__c fc : facMap.values()){
                if(interactionPanelWrapper.calleeName!=null){
                    if(interactionPanelWrapper.calleeName == fc.Account__r.name){
                        isManuallyAdded = false;// If the existing name matches any of the related FAC then it is not manually added
                        break;
                    }
                }
            }
         }
         if(!(isManuallyAdded) || (interactionPanelWrapper.calleeName=='')){// If not manually added then let the logic update the borrower name.
             if (facMap!=null){fac = facMap.get(clickedId);}// Added by Sandeep for Null Reference exception.
            if(fac!=null && fac.Account__c!=null)// If Statement added for I-171630 by Paras Dhingra 7/14/2015
                interactionPanelWrapper.calleeName = fac.Account__r.Name;
             if(fac!= null && fac.Borrower_Position__c!=null){// Added by Sandeep for Null Reference exception.
             if(mapOfBorrowerPositionToRelationship!=null && mapOfBorrowerPositionToRelationship.containsKey(fac.Borrower_Position__c)){ // Added null check for I-171630 by Paras Dhingra 7/14/2015
                interactionPanelWrapper.calleeRelationship = mapOfBorrowerPositionToRelationship.get(fac.Borrower_Position__c).Name;           
             }   }

         }
        // Paras Dhingra 6/29/2015 S-310348 #End
    }
    
   /**
    * @author   Stevie Ella
    * @date 5/20/2014
    * @description Generate the formatted note for RPC tab.
    */
    public PageReference generateFormattedNote(){
    
        // Get the spoken customer phone number
        Financial_Account_Customer__c financialAccountCustomerLocal;
        if(interactionPanelWrapper.calleeRelationship.equals(TFSC_Constants.CALLEE_RELATIONSHIP_CX)){
            financialAccountCustomerLocal = TFSC_Utils.getCoBorrowerFinancialAccountCustomer(financialAccountId);
        }else{
            financialAccountCustomerLocal = TFSC_Utils.getPrimaryFinancialAccountCustomer(financialAccountId);
        }
        
        String currentNote = interactionPanelWrapper.rpcNote;
        String currentPhoneNumber = '';
        if(financialAccountCustomerLocal != null && financialAccountCustomerLocal.Home_Phone_Garage__c != null) {
            currentPhoneNumber = financialAccountCustomerLocal.Home_Phone_Garage__c;
        }
        
        List<String> listOfFormattedNoteElements = new List<String>();
        
        // NOTE TO STEVIE -- THIS MIGHT BE INCORRECT.
        //        I added it here, but maybe the lastDialedPhoneNumber needs to always be the starting text, and the rest is the same??
        // Build the note
        // Add the phone number
        if(!TFSC_Utils.isNullOrEmpty(lastDialedPhoneNumber)){
            listOfFormattedNoteElements.add(lastDialedPhoneNumber);
        }else if(!TFSC_Utils.isNullOrEmpty(currentPhoneNumber)){
            listOfFormattedNoteElements.add(currentPhoneNumber);
        }
        
        // Campaign Type
        String campaignType = getCampaignTypeFromName(campaignName);
        if(!campaignType.equals('')){
            listOfFormattedNoteElements.add(campaignType);
        }
        
        // Add the spoken person status and name
        listOfFormattedNoteElements.add('TT: ' + interactionPanelWrapper.calleeRelationship);
        listOfFormattedNoteElements.add(interactionPanelWrapper.calleeName);
        
        // Add the VAP choice
        listOfFormattedNoteElements.add(interactionPanelWrapper.vapChoice);
        
        // Add the home phone number is it's checked and non-null
        if(interactionPanelWrapper.isHomePhoneNumber && !TFSC_Utils.isNullOrEmpty(financialAccountCustomerLocal.Home_Phone_Garage__c)){
            listOfFormattedNoteElements.add('H# ' + TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Home_Phone_Garage__c));
        } 
        // Add the work phone number is it's checked and non-null
        if(interactionPanelWrapper.isWorkPhoneNumber && !TFSC_Utils.isNullOrEmpty(financialAccountCustomerLocal.Work_Phone_Garage__c)){
            listOfFormattedNoteElements.add('W# ' + TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Work_Phone_Garage__c));
        }
        // Add the cell phone number is it's checked and non-null
        if(interactionPanelWrapper.isCellPhoneNumber && !TFSC_Utils.isNullOrEmpty(financialAccountCustomerLocal.Mobile_Phone__c)){
            listOfFormattedNoteElements.add('C# ' + TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mobile_Phone__c));
        }
        // Add the Total Amount Due if not null/empty
        if(!TFSC_Utils.isNullOrEmpty(String.valueOf(financialAccount.Total_Amount_Due__c))){
            listOfFormattedNoteElements.add('TAD: $' + financialAccount.Total_Amount_Due__c);
        }
        
        // Add the Garage Address if checked and not null/empty
        if(interactionPanelWrapper.isGarageAddressConfirmed){
            listOfFormattedNoteElements.add('PHYS ADD: ' + 
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_Street_Garage__c) + ' ' + 
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_City_Garage__c) + ' ' + 
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_State_Garage__c) + ' ' +
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_Country_Code_Garage__c) + ' ' +
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_Postal_Code_Garage__c)
            );
        }
        
        // Add the Bill To Address if checked and not null/empty
        if(interactionPanelWrapper.isBillToAddressConfirmed){
            listOfFormattedNoteElements.add('BILL TO: ' + 
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_Street_BillTo__c) + ' ' + 
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_City_BillTo__c) + ' ' + 
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_State_BillTo__c) + ' ' +
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_CountryCode_BillTo__c) + ' ' +
                TFSC_Utils.getValueOrEmpty(financialAccountCustomerLocal.Mailing_PostalCode_BillTo__c)
            );
        }
        
        // Add the past amount due if not null/empty
        if(!TFSC_Utils.isNullOrEmpty(String.valueOf(financialAccount.Payment_Amount_Past_Due__c))){
            Decimal roundedDec = financialAccount.Payment_Amount_Past_Due__c.setScale(2);
            String strPpdTemp = String.valueOf(roundedDec);
            //String[] args = new String[]{'#.##'};
            //strPpdTemp = String.format(strPpdTemp, args);
            listOfFormattedNoteElements.add('Past Due: $' + strPpdTemp);
        }
        // Add the next due date if not null/empty
        if(!TFSC_Utils.isNullOrEmpty(String.valueOf(financialAccount.Payment_Date_Next__c))){
            listOfFormattedNoteElements.add('Next Due: ' + String.valueOf(financialAccount.Payment_Date_Next__c));
        }
        
        // Add the Reason for Delinquency
        if(!TFSC_Utils.isNullOrEmpty(interactionPanelWrapper.reasonOfDelinquency)){
            String reasonForDelinquency = 'RFD: ' + interactionPanelWrapper.reasonOfDelinquency;
            if(!TFSC_Utils.isNullOrEmpty(interactionPanelWrapper.reasonOfDelinquency)){
                reasonForDelinquency += ' ' + interactionPanelWrapper.reasonOfDelinquencyNote;
            }
            
            listOfFormattedNoteElements.add(reasonForDelinquency);
        }
        
        // Add the DPD if not null/empty INCORRECT -- SEE NEW EDIT TO US865
        //if(!TFSC_Utils.isNullOrEmpty(financialAccount.History_Counter_Days_Past_Due__c)){
        //    listOfFormattedNoteElements.add('DPD: ' + financialAccount.History_Counter_Days_Past_Due__c);
        //}

        // Add the promise #1
        String promise_1 = TFSC_Utils.formatPromiseForNote(
                interactionPanelWrapper.firstPromiseDate, 
                interactionPanelWrapper.firstMethodOfPayment, 
                interactionPanelWrapper.firstAmountPTP, 
                interactionPanelWrapper.firstConfirmationPTP
        );
        if(!TFSC_Utils.isNullOrEmpty(promise_1)){
            listOfFormattedNoteElements.add(promise_1);
        }

        // Add the promise #2
        String promise_2 = TFSC_Utils.formatPromiseForNote(
                interactionPanelWrapper.secondPromiseDate, 
                interactionPanelWrapper.secondMethodOfPayment, 
                interactionPanelWrapper.secondAmountPTP, 
                interactionPanelWrapper.secondConfirmationPTP
        );
        if(!TFSC_Utils.isNullOrEmpty(promise_2)){
            listOfFormattedNoteElements.add(promise_2);
        }
        
        // Add talking point
        for(KnowledgeArticleWrapper talkingPoint : interactionPanelWrapper.listOfTalkingPoints){
            if(talkingPoint.isSelected && talkingPoint.article.Add_to_Standard_Note__c)
                listOfFormattedNoteElements.add(talkingPoint.article.title + ' - ' + talkingPoint.article.summary);
        }
        
        
        listOfFormattedNoteElements.add(currentNote);
        // Set the note to the RPC tab note text area
        
        
        //split the note at the last space before the 450th character.
        String noteFinal = String.join(listOfFormattedNoteElements, ', ');
        
        String noteFinal1;
        String noteFinal2;
        List<String> noteList;
        List<String> noteList1;
        List<String> noteList2;
        if(noteFinal.length() > 450) {
            noteList = noteFinal.substring(0,450).split(' ');
            
            noteFinal2 = noteFinal.substring(450);
            if(noteList.size() > 1) {
                noteFinal2 = noteList[noteList.size() - 1] + ' ' + noteFinal2;
                
                noteList.remove( noteList.size() - 1 );
                noteFinal1 = String.join(noteList, ' ');
            }else{
                noteFinal1 = noteFinal.substring(0,450);
            }
            
            noteFinal = noteFinal1 + '\n\n' + noteFinal2;
            
        }
        
        interactionPanelWrapper.rpcNote = noteFinal;
        
        return null;
    }
     

     
    /**
    * @author   Stevie Ella
    * @date 2/21/2014
    * @description This class will handle and transmit the results of the different counts to the toolbar
    */
    global class InteractionPanelWrapper {
 
        // Codes and Notes for Quick, RPC and Skip
        public String quickCode{get;set;}
        public String rpcCode{get;set;}
        public String skipCode{get;set;}
        public String quickNote{get;set;}
        public String rpcNote{get;set;}
        public String skipNote{get;set;}
        
        public Boolean rpcCodePTPRequired{get;set;}
        
        public Decimal totalAmountDue{get;set;}
        
        // First and Second Promise to pay
        public String firstPromiseDate{get;set;}
        public String secondPromiseDate{get;set;}
        public String firstMethodOfPayment{get;set;}
        public String secondMethodOfPayment{get;set;}
        public String firstAmountPTP{get;set;}
        public String secondAmountPTP{get;set;}
        public String firstConfirmationPTP{get;set;}
        public String secondConfirmationPTP{get;set;}
        public Decimal firstBalancePTP{get;set;}
        public Decimal secondBalancePTP{get;set;}
        
        // Confirm data from the customer
        public String vapChoice{
            get{
                if(vapChoice == null)
                    return TFSC_Constants.VPA_PICKLIST_DEFAULT_VALUE;
                else
                    return vapChoice;
            }
            set;
        }
        public boolean isHomePhoneNumber{get;set;}
        public boolean isCellPhoneNumber{get;set;}
        public boolean isWorkPhoneNumber{get;set;}
        public boolean isBillToAddressConfirmed{get;set;}
        public boolean isGarageAddressConfirmed{get;set;}
        
        //Talked-to
        public String calleeRelationship{get;set;}
        public String calleeName{get;set;}
        
        // PTP Error Message
        public String firstIncompleteErrorMessage{get;set;}
        public String secondIncompleteErrorMessage{get;set;}
        
        //Reason OF Delinquency
        public String reasonOfDelinquency{get;set;}
        public String reasonOfDelinquencyNote{get;set;}
        
        // Talking Points
        public List<KnowledgeArticleWrapper> listOfTalkingPoints{get; set;} 
        
        public InteractionPanelWrapper(){
            firstPromiseDate = '';
            secondPromiseDate = '';
            firstMethodOfPayment = '';
            secondMethodOfPayment = '';
            firstAmountPTP = '';
            secondAmountPTP = '';
            firstConfirmationPTP = '';
            secondConfirmationPTP = '';
            
            rpcCodePTPRequired = false;
        }
        
        public void clearPTP(){
            firstPromiseDate = '';
            firstMethodOfPayment = 'None';
            firstAmountPTP = '';
            firstConfirmationPTP = '';
            firstBalancePTP = totalAmountDue;
            
            secondPromiseDate = '';
            secondMethodOfPayment = 'None';
            secondAmountPTP = '';
            secondConfirmationPTP = '';
            secondBalancePTP = totalAmountDue;
        }

        public Decimal getCleanFirstAmount(){
            Decimal decimalFirstAmount;
            try{
                decimalFirstAmount = TFSC_Utils.getDecimalCurrencyValue(firstAmountPTP);
            }catch(Exception e){
                decimalFirstAmount = 0;
            }
            return decimalFirstAmount;
        }  
        
        public Decimal getCleanSecondAmount(){
            Decimal decimalSecondAmount;
            try{
                decimalSecondAmount = TFSC_Utils.getDecimalCurrencyValue(secondAmountPTP);
            }catch(Exception e){
                decimalSecondAmount = 0;
            }
            return decimalSecondAmount;
        }       
        
    }
    
    global class KnowledgeArticleWrapper{
        public Collections_Talking_Point__kav article {get;set;}
        public Boolean isSelected {get;set;}
    }
    
}