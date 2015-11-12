/*****
 * Salesforce.com Success Services
 * Name: RL_GenerateTestData
 * Description: Creates FA, FAC, Form Rule, Case and Repossession test data.
 */

global class RL_GenerateTestData {
    public static Financial_Account__c fa;
    public static Financial_Account_Customer__c fac;
    public static List<Form_Rule__c> formRuleList;
    public static Case aCase;
    public static Repossession__c repo;
    public static Case_Skills__c cs;

    static public List<Dailight_Savings_Periods__c> createDSTPeriods() {
        List<Dailight_Savings_Periods__c> dstPeriods = new Dailight_Savings_Periods__c[]{new Dailight_Savings_Periods__c(Dailight_Savings_In_Effect__c=false, End_Date__c=Date.newInstance(2015, 03, 07), Name='Daylight Savings Not In Effect 2014', Start_Date__c=Date.newInstance(2014, 11, 03)), 
            new Dailight_Savings_Periods__c(Dailight_Savings_In_Effect__c=true, End_Date__c=Date.newInstance(2014, 11, 02), Name='Daylight Savings In Effect 2014', Start_Date__c=Date.newInstance(2014, 03, 09))};
        insert dstPeriods;
        return dstPeriods;
    }

    static public Id getRecordType(String sObjectTypeName, String rtName) {
        List<RecordType> rtList = [Select ID from RecordType where sObjectType =: sObjectTypeName AND Name =: rtName];
        return rtList != null && rtList.size() > 0 ? rtList[0].Id : null;
    }

    static public Id getBusinessHoursId() {
        BusinessHours bh = [SELECT Id FROM BusinessHours where Name='Rights Letters Mailing'];
        return bh.Id;
    }

    static public void createTimezoneIndicators() {
        List<TimeZone_Indicator__c> zoneList = new TimeZone_Indicator__c[]{new TimeZone_Indicator__c(Name='90209', DST_Abbreviation__c = 'PDT', Higher_Range_of_Zip_Code__c=90213.0, Lower_Range_of_Zip_Code__c = 90209.0, Standard_Abbreviation__c='PST', Standard_GMT_Offset__c=-8.0, State__c='CA', Timezone__c ='America/Los_Angeles'),
            new TimeZone_Indicator__c(Name='1111', DST_Abbreviation__c = 'EDT', Higher_Range_of_Zip_Code__c=1112.0, Lower_Range_of_Zip_Code__c = 1111.0, Standard_Abbreviation__c='EST', Standard_GMT_Offset__c=-5.0, State__c='NY', Timezone__c ='America/New_York')};
        insert zoneList;
    }

    static public Financial_Account__c createFARetailIL(Account dealer, Id rtId) {
        fa = new Financial_Account__c(Name='Test FA', RecordTypeId=rtId, Maturity_Date__c = Date.today(), History_Counter_Days_Past_Due__c = '0147', Dealership__c = dealer.Id, Contract_Date__c=Date.today(), Payment_Date_Past_Due__c=Date.today());
        insert fa;

        fac = new Financial_Account_Customer__c(Customer_Role_Type__c='0-Primary Borrower', Borrower_Status__c = 'Active', Name = 'Test FAC1', Mailing_State_Garage__c = 'IL', Financial_Account__c = fa.Id, Account__c = dealer.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071');
        insert fac;
        return fa;
    }

    static public Financial_Account__c createFALeaseIL(Account dealer, Id rtId) {
        fa = new Financial_Account__c(Name='Test FA', RecordTypeId=rtId, Maturity_Date__c=Date.today(), History_Counter_Days_Past_Due__c='0147', Dealership__c=dealer.Id, Contract_Date__c=Date.today(), Payment_Date_Past_Due__c=Date.today());
        insert fa;

        fac = new Financial_Account_Customer__c(Customer_Role_Type__c='0-Primary Borrower', Borrower_Status__c = 'Active', Name = 'Test FAC', Mailing_State_Garage__c = 'IL', Financial_Account__c = fa.Id, Account__c = dealer.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071');
        insert fac;
        return fa;
    }

    static public Case_Skills__c createCaseSkills() {
        cs = new Case_Skills__c(RL_Daily_Case_Bandwidth__c=20, RL_Daily_Cases_for_Quality_Review__c=4, RL_New_Hire__c = True);
        insert cs;
        return cs;
    }

    static public Account createTestDealer(Id rtId) {
        Account acc = new Account (RecordTypeId = rtId, Name = 'Test Account', BillingState = 'IL');
        insert acc;
        return acc;
    }

    static public Case createCase(Financial_Account__c fAccount, Id caseRTId) {
        aCase = new Case(Financial_Account__c = fAccount.Id, recordTypeId = caseRTId);
        insert aCase;
        return aCase;
    }    

    static public Repossession__c createRepossession(Case theCase, Financial_Account__c fAccount, Id repoRTId) {
        repo = new Repossession__c(Financial_Account__c=fAccount.Id, Proposed_Notice_Date__c=Date.today(), RecordTypeId=repoRTId, Case__c = theCase.Id, State_of_Jurisdiction__c='IL',
                                    iRepo_RepoState__c = 'IL', iRepo_RepoZip__c = '90210', iRepo_RecoveryDateTime__c=DateTime.now(), Vehicle_Make__c = 'TOYOTA', Vehicle_Model__c='COROLLA',
                                    Proposed_Legal_Sale_Date__c=Date.Today());
        insert repo;
        return repo;
    }

    static public Repossession__c createRepossession(Case theCase, Financial_Account__c fAccount) {
        repo = new Repossession__c(Financial_Account__c=fAccount.Id, Proposed_Notice_Date__c=Date.today(), Case__c = theCase.Id, iRepo_VIN__c='12345', State_of_Jurisdiction__c='IL',
                                    iRepo_RepoState__c = 'IL', iRepo_RepoZip__c = '90210', iRepo_RecoveryDateTime__c=DateTime.now(), Vehicle_Make__c = 'TOYOTA', Vehicle_Model__c='COROLLA',
                                    Validation_Comments__c = 'TEST', Proposed_Legal_Sale_Date__c=Date.Today());
        insert repo;
        return repo;
    }

    static public Repossession__c createRepossessionMD(Case theCase, Financial_Account__c fAccount) {
        repo = new Repossession__c(Financial_Account__c=fAccount.Id, Proposed_Notice_Date__c=Date.today(), Case__c = theCase.Id, iRepo_VIN__c='12345', State_of_Jurisdiction__c='MD',
                                    iRepo_RepoState__c = 'MD', iRepo_RepoZip__c = '90210', iRepo_RecoveryDateTime__c=DateTime.now(), Vehicle_Make__c = 'TOYOTA', Vehicle_Model__c='COROLLA',
                                    Validation_Comments__c = 'TEST', Proposed_Legal_Sale_Date__c=Date.Today(), Other_Charges1__c=123, Other_Charges2__c=456);
        insert repo;
        return repo;
    }    

    static public List<Form_Validation__c> generateListOfValidations() {
        List<Form_Validation__c> listToReturn = new List<Form_Validation__c>();
        Form_Validation__c fv2 = generateFormValidation(false, 'error occurred', 'Personal_Property_Fee__c', 'Number', '== (Equal To)', null, null, null, null, null);
        fv2.RL_Field_Name3__c = 'United_Road_Transport_Fees__c';
        fv2.RL_Field3_Type__c = 'Number';
        fv2.RL_Operator3__c = '==';
        listToReturn.add( fv2 );
        
        return listToReturn;
    }    

    static public Form_Validation__c generateFormValidation(Boolean hardErr, String errMsg,
                                        String fieldName1, String fieldType1, String operator1, String value1,
                                        String fieldName2, String fieldType2, String operator2, String value2) {
        
        Form_Validation__c validation = new Form_Validation__c(
            Error_Message__c = errMsg, Hard_Error__c = hardErr, 
            RL_Field_Name1__c = fieldName1, RL_Field_Name2__c = fieldName2,
            RL_Field1_Type__c = fieldType1, RL_Field2_Type__c = fieldType2, 
            RL_Operator1__c = operator1, RL_Operator2__c = operator2, 
            RL_Value1__c = value1, RL_Value2__c = value2 ,
            SObject__c = 'Repossession__c'
        );
        
        return validation; 
    }    

    static public Map<String, Form_Rule__c> insertFormRuleData() {
        Id formRuleRTId = getRecordType('Form_Rule__c', 'Rights Letters');
        Id formRuleNoSRTId = getRecordType('Form_Rule__c', 'RL Notice of Sale');
        formRuleList = new Form_Rule__c[]{new Form_Rule__c (
            RecordTypeId = formRuleRTId,
            Name = '4015 (LA)',
            Account_Type__c = 'Retail',
            Form__c = '4015',
            State_of_Jurisdiction__c = 'LA',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 21,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,            
            Name = '4015 (RI)',
            Account_Type__c = 'Retail',
            Form__c = '4015',
            State_of_Jurisdiction__c = 'RI',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Retail-Conditional'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,            
            Name = '4015 (SC)',
            Account_Type__c = 'Retail',
            Form__c = '4015',
            State_of_Jurisdiction__c = 'SC',
            Time_Till_Notice__c = 5,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 21,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015 (VT)',
            Account_Type__c = 'Retail',
            Form__c = '4015',
            State_of_Jurisdiction__c = 'VT',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015 Generic',
            Account_Type__c = 'Retail',
            Form__c = '4015',
            State_of_Jurisdiction__c = 'AK;AL;AR;AZ;CO;DE;FL;HI;IA;ID;IN;KS;KY;MA;ME;MI;MN;MT;NC;ND;NE;NH;NJ;NM;OK;OR;SD;TN;UT;VA;WA;WV;WY',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015CA',
            Account_Type__c = 'Retail',
            Form__c = '4015CA',
            In_State_Repo__c = true,
            State_of_Jurisdiction__c = 'CA',
            Time_Till_Notice__c = 60,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Retail-CA In-State'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015CT',
            Account_Type__c = 'Retail',
            Form__c = '4015CT',
            State_of_Jurisdiction__c = 'CT',
            Time_Till_Notice__c = 3,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015GA',
            Account_Type__c = 'Retail',
            Form__c = '4015GA',
            State_of_Jurisdiction__c = 'GA',
            Time_Till_Notice__c = 10,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015IL',
            Account_Type__c = 'Retail',
            Form__c = '4015IL, 4081IL, 4082IL',
            State_of_Jurisdiction__c = 'IL',
            Time_Till_Notice__c = 3,
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 21,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Retail-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015MD',
            Account_Type__c = 'Retail',
            Form__c = '4015MD',
            State_of_Jurisdiction__c = 'MD',
            Time_Till_Notice__c = 5,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Retail-Conditional Reinstatement',
            Post_RL_Notice_Of_Sale__c = True),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015MO',
            Account_Type__c = 'Retail',
            Form__c = '4015MO',
            State_of_Jurisdiction__c = 'MO',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015MS',
            Account_Type__c = 'Retail',
            Form__c = '4015MS',
            State_of_Jurisdiction__c = 'MS',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Yes',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015NV',
            Account_Type__c = 'Retail',
            Form__c = '4015NV',
            State_of_Jurisdiction__c = 'NV',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015NY',
            Account_Type__c = 'Retail',
            Form__c = '4015NY',
            State_of_Jurisdiction__c = 'NY',
            Time_Till_Notice__c = 72,
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_HOURS,
            Non_Working_Day_Rule__c = RL_Constants.FOLLOWING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Yes',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015OH',
            Account_Type__c = 'Retail',
            Form__c = '4015OH',
            State_of_Jurisdiction__c = 'OH',
            Time_Till_Notice__c = 5,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015PA',
            Account_Type__c = 'Retail',
            Form__c = '4015PA',
            State_of_Jurisdiction__c = 'PA',
            Time_Till_Notice__c = 5,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015TX',
            Account_Type__c = 'Retail',
            Form__c = '4015TX',
            State_of_Jurisdiction__c = 'TX',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Retail-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4015WI',
            Account_Type__c = 'Retail',
            Form__c = '4015WI',
            State_of_Jurisdiction__c = 'WI',
            Time_Till_Notice__c = 5,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Yes',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '4033CA',
            Account_Type__c = 'Retail',
            Form__c = '4033CA',
            State_of_Jurisdiction__c = 'CA',
            Time_Till_Notice__c = 60,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Retail-CA Out-of-State'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(CT;VT)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'CT,VT',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(IL)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'LI',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 21,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(IL)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'LI',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 21,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(LA)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'LA',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(NY)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'NY',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 10,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(RI)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'RI',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015(RI)',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'RI',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015 Generic',
            Account_Type__c = 'Lease',
            Form__c = '6015',
            State_of_Jurisdiction__c = 'AK;AL;AR;AZ;CO;DE;FL;GA;HI;IA;ID;IN;KS;KY;LA;MI;MN;MO;MS;MT;NC;ND;NE;NH;NM;NV;OH;OK;OR;PA;SC;SD;TN;TX;UT;VA;WA;WV;WY',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015CA',
            Account_Type__c = 'Lease',
            Form__c = '6015CA',
            State_of_Jurisdiction__c = 'CA',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015MA',
            Account_Type__c = 'Lease',
            Form__c = '6015MA',
            State_of_Jurisdiction__c = 'MA',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015MD',
            Account_Type__c = 'Lease',
            Form__c = '6015MD',
            State_of_Jurisdiction__c = 'MD',
            Time_Till_Notice__c = 5,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015ME',
            Account_Type__c = 'Lease',
            Form__c = '6015ME',
            State_of_Jurisdiction__c = 'ME',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015NJ',
            Account_Type__c = 'Lease',
            Form__c = '6015NJ',
            State_of_Jurisdiction__c = 'NJ',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6015WI',
            Account_Type__c = 'Lease',
            Form__c = '6015WI',
            State_of_Jurisdiction__c = 'WI',
            Time_Till_Notice__c = 7,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6025CA',
            Account_Type__c = 'Lease',
            Form__c = '6025CA',
            State_of_Jurisdiction__c = 'CA',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6025WI',
            Account_Type__c = 'Lease',
            Form__c = '6025WI',
            State_of_Jurisdiction__c = 'WI',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6026 (CT;VT)',
            Account_Type__c = 'Lease',
            Form__c = '6026',
            State_of_Jurisdiction__c = 'CT;VT',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6026 (IL)',
            Account_Type__c = 'Lease',
            Form__c = '6026',
            State_of_Jurisdiction__c = 'IL',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 21,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6026 (LA)',
            Account_Type__c = 'Lease',
            Form__c = '6026',
            State_of_Jurisdiction__c = 'LA',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6026 (LA)',
            Account_Type__c = 'Lease',
            Form__c = '6026',
            State_of_Jurisdiction__c = 'LA',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6026 (RI)',
            Account_Type__c = 'Lease',
            Form__c = '6026',
            State_of_Jurisdiction__c = 'RI',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 20,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Conditional',
            Repossession_Record_Type__c = 'RL Lease-Conditional Reinstatement'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = '6026 Generic',
            Account_Type__c = 'Lease',
            Form__c = '6026',
            State_of_Jurisdiction__c = 'AK;AL;AR;AZ;CO;DE;FL;GA;HI;IA;ID;IN;KS;KY;LA;MA;ME;MI;MN;MO;MS;MT;NC;ND;NE;NH;NJ;NM;NV;OH;OK;OR;PA;SC;SD;TN;TX;UT;VA;WA;WV;WY',
            Time_Till_Notice__c = 7,
            Voluntary_surrender__c = true,            
            iRepo_SLA__c = 48,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_BUSINESS,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'No',
            Repossession_Record_Type__c = 'RL Lease-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleRTId,
            Name = 'Test',
            Account_Type__c = 'Retail',
            Form__c = 'Test',
            State_of_Jurisdiction__c = 'NY',
            Time_Till_Notice__c = 72,
            iRepo_SLA__c = 24,
            Notice_Calendar__c = RL_Constants.NOTICE_CALENDAR_HOURS,
            Non_Working_Day_Rule__c = RL_Constants.PRECEDING,
            Days_Till_Sale__c = 15,
            Sale_Calendar__c = RL_Constants.NOTICE_CALENDAR_CALENDAR,
            Reinstatement_Rights__c = 'Yes',
            Repossession_Record_Type__c = 'RL Retail-Generic'),
        new Form_Rule__c(
            RecordTypeId = formRuleNoSRTId,
            Name = '4028MD',
            Form__c = '4028MD',
            State_of_Jurisdiction__c = 'MD',
            Case_Record_Type__c = 'RL Notice of Sale'),
        new Form_Rule__c(
            RecordTypeId = formRuleNoSRTId,
            Name = '4820',
            Form__c = '4820',
            State_of_Jurisdiction__c = 'MD',
            Case_Record_Type__c = 'RL Notice of Sale-Salvage',
            Salvage__c = true)
        };
        insert formRuleList;
        Map<String, Form_Rule__c> formRuleMap = new Map<String, Form_Rule__c>();
        for (Form_Rule__c rule : formRuleList) {
            formRuleMap.put(rule.Name, rule);
        }
        return formRuleMap;
    }
}