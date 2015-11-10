@isTest
private class TFSC_UtilsTest {

    static testMethod void isDailightSavingsPeriodTest() {
        
        // Create Dailight_Savings_Periods__c
        List<Dailight_Savings_Periods__c> listOfDailightSavingsPeriod = new List<Dailight_Savings_Periods__c>();
        Dailight_Savings_Periods__c dailightSavingsPeriod_1 = new Dailight_Savings_Periods__c(
            Name = 'FIRST_DAILIGHT_SAVING',
            Start_Date__c = Date.newInstance(2014, 2, 22),
            End_Date__c = Date.newInstance(2014, 8, 21),
            Dailight_Savings_In_Effect__c = true
        );
        Dailight_Savings_Periods__c dailightSavingsPeriod_2 = new Dailight_Savings_Periods__c(
            Name = 'FIRST_NON_DAILIGHT_SAVING',
            Start_Date__c = Date.newInstance(2014, 8, 22),
            End_Date__c = Date.newInstance(2015, 2, 21),
            Dailight_Savings_In_Effect__c = false
        );
        listOfDailightSavingsPeriod.add(dailightSavingsPeriod_1);
        listOfDailightSavingsPeriod.add(dailightSavingsPeriod_2);
        insert listOfDailightSavingsPeriod;
        
        Date currentDate = Date.newInstance(2014, 3, 10);
        System.assertEquals(TFSC_Utils.isDailightSavingsPeriod(currentDate), true);
        
        currentDate = Date.newInstance(2014, 10, 10);
        System.assertEquals(TFSC_Utils.isDailightSavingsPeriod(currentDate), false);
        
        currentDate = Date.newInstance(2015, 8, 10);
        System.assertEquals(TFSC_Utils.isDailightSavingsPeriod(currentDate), false);
        
    }
    
    static testMethod void getEnablePhoneNumberDependingOnTimeZoneTest() {
    
        // Create Dailight_Savings_Periods__c
        List<Dailight_Savings_Periods__c> listOfDailightSavingsPeriod = new List<Dailight_Savings_Periods__c>();
        Dailight_Savings_Periods__c dailightSavingsPeriod_1 = new Dailight_Savings_Periods__c(
            Name = 'FIRST_DAILIGHT_SAVING',
            Start_Date__c = Date.newInstance(2014, 2, 22),
            End_Date__c = Date.newInstance(2014, 8, 21),
            Dailight_Savings_In_Effect__c = true
        );
        Dailight_Savings_Periods__c dailightSavingsPeriod_2 = new Dailight_Savings_Periods__c(
            Name = 'FIRST_NON_DAILIGHT_SAVING',
            Start_Date__c = Date.newInstance(2014, 8, 22),
            End_Date__c = Date.newInstance(2015, 2, 21),
            Dailight_Savings_In_Effect__c = false
        );
        listOfDailightSavingsPeriod.add(dailightSavingsPeriod_1);
        listOfDailightSavingsPeriod.add(dailightSavingsPeriod_2);
        insert listOfDailightSavingsPeriod;
    
        // Create timezone indicator
        List<TimeZone_Indicator__c> listOfTimeZoneIndicators = new List<TimeZone_Indicator__c>();
        TimeZone_Indicator__c timezoneIndicator_1 = new TimeZone_Indicator__c(
            Name = '90000',
            Higher_Range_of_Zip_Code__c = 90099,
            Lower_Range_of_Zip_Code__c = 90000,
            Timezone__c = 'PACIFIC',
            Timezone_Indicator__c = 'PST',
            GMT_Till_Without_Daylight_Saving__c = '',
            GMT_From_Without_Daylight_Saving__c = '',
            GMT_Till_With_Daylight_Saving__c = '',
            GMT_From_With_Daylight_Saving__c = '',
            Observe_Daylight_Saving__c = true
        );
        TimeZone_Indicator__c timezoneIndicator_2 = new TimeZone_Indicator__c(
            Name = '90100',
            Higher_Range_of_Zip_Code__c = 90199,
            Lower_Range_of_Zip_Code__c = 90100,
            Timezone__c = 'PACIFIC',
            Timezone_Indicator__c = 'PST',
            GMT_Till_Without_Daylight_Saving__c = '',
            GMT_From_Without_Daylight_Saving__c = '',
            GMT_Till_With_Daylight_Saving__c = '',
            GMT_From_With_Daylight_Saving__c = '',
            Observe_Daylight_Saving__c = true
        );
        
        TimeZone_Indicator__c timezoneIndicator_3 = new TimeZone_Indicator__c(
            Name = '90200',
            Higher_Range_of_Zip_Code__c = 90299,
            Lower_Range_of_Zip_Code__c = 90200,
            Timezone__c = 'PACIFIC',
            Timezone_Indicator__c = 'PST',
            GMT_Till_Without_Daylight_Saving__c = '',
            GMT_From_Without_Daylight_Saving__c = '',
            GMT_Till_With_Daylight_Saving__c = '',
            GMT_From_With_Daylight_Saving__c = '',
            Observe_Daylight_Saving__c = true
        );
        
        listOfTimeZoneIndicators.add(timezoneIndicator_1);
        listOfTimeZoneIndicators.add(timezoneIndicator_2);
        listOfTimeZoneIndicators.add(timezoneIndicator_3);
        insert listOfTimeZoneIndicators;
        
    } 
    
    static testMethod void getEnablePhoneNumberInSkipTraceTableTest(){
        String hStatus = 'H - H_Status';
        String nStatus = 'N - N_Status';
        String gStatus = 'G - G_Status';
        String emptyStatus = '';
        
        System.assertEquals(TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(hStatus), false);
        System.assertEquals(TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(nStatus), false);
        System.assertEquals(TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(gStatus), true);
        System.assertEquals(TFSC_Utils.getEnablePhoneNumberInSkipTraceTable(emptyStatus), true);
    }
    
    static testMethod void getListDisplayFACNumbersTest(){
    
        List<Account> listAccounts = new List<Account>();
        listAccounts.add(new Account(name = 'Primary'));
        listAccounts.add(new Account(name = 'CoBorrower'));
        
        insert listAccounts;
        
        Financial_Account__c financialAccount = new Financial_Account__c(
            Financial_Account_Number__c = '12345',
            Payment_Amount_Past_Due__c = 300,
            Payment_Date_Next__c = date.newInstance(2015, 2, 17),
            History_Counter_Days_Past_Due__c = '51'
        );
        insert financialAccount;
    
        List<Financial_Account_Customer__c> listFACustomers = new List<Financial_Account_Customer__c>();
        Financial_Account_Customer__c financialAccountCustomer_1 = new Financial_Account_Customer__c(
            HomePhone_BillTo__c = '7014478311',
            Work_Phone_Bill_To__c = '7014833222',
            Mobile_Phone__c = '7014478333',
            Mailing_Postal_Code_Garage__c = '90240',
            Home_Phone_No_Call_Reason_Code_Garage__c = 'D',
            Mobile_Phone_No_Call_Reason_Code__c = 'K',
            Financial_Account__c = financialAccount.Id,
            Account__c = listAccounts.get(0).Id,
            Borrower_Position__c = 'Primary',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test2asdf'
        );
        Financial_Account_Customer__c financialAccountCustomer_2 = new Financial_Account_Customer__c(
            HomePhone_BillTo__c = '7014478332',
            Work_Phone_Bill_To__c = '7014478331',
            Mobile_Phone__c = '7014478334',
            Financial_Account__c = financialAccount.Id,
            Account__c = listAccounts.get(1).Id,
            Borrower_Position__c = 'Co-X',
            Borrower_Status__c = 'Active',
            Customer_Role_Type__c = 'test',
            FA_Role_Status__c = 'test',
            Financial_Account_Customer__c = 'test24asdf'
        );
        
        listFACustomers.add(financialAccountCustomer_1);
        listFACustomers.add(financialAccountCustomer_2);
        insert listFACustomers;
        
        TimeZone_Indicator__c timezoneIndicator_1 = new TimeZone_Indicator__c(
            Name = '90200',
            Higher_Range_of_Zip_Code__c = 90299,
            Lower_Range_of_Zip_Code__c = 90200,
            Timezone__c = 'PACIFIC',
            Timezone_Indicator__c = 'PST',
            GMT_Till_Without_Daylight_Saving__c = '23:59',
            GMT_From_Without_Daylight_Saving__c = '00:01',
            GMT_Till_With_Daylight_Saving__c = '23:59',
            GMT_From_With_Daylight_Saving__c = '00:01',
            Observe_Daylight_Saving__c = true
        );
        insert timezoneIndicator_1;
        
        List<Boolean> listOfResults = new List<Boolean>();
        
        Test.startTest();
        listOfResults = TFSC_Utils.getListDisplayFACNumbers(financialAccountCustomer_1);
        Test.stopTest();
        
        System.assertEquals(listOfResults.get(0), false);
        System.assertEquals(listOfResults.get(1), true);
        System.assertEquals(listOfResults.get(2), true);
    
    }
}