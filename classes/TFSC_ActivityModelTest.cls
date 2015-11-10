@isTest
private class TFSC_ActivityModelTest {
    
    //Setup test data
    static String testFAId = null;
    static String testFARecourseCode = null;
    static String testFACId = null;
    static String testFANumber = null;
    static String testActivityCode = 'CMNP';
    

    private static void setupTestFA(){

        Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
        Financial_Account__c testFA = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct);
        Financial_Account_Customer__c testFAC = TFSC_TestUtils.setupAndReturnFAC(testFA, acct, 'Primary');

        testFAId = testFA.Id;
        testFACId = testFAC.Id;
        testFARecourseCode = testFA.Collection_Recourse_Code__c;
        testFANumber = testFA.Name;
        System.debug('*************** testFAId: ' + testFAId);

    }

    private static void setupTestTask(){

        String activityCode = 'CMNP';

        Task note = new Task(ActivityDate = Date.today(),
                             Collection_Activity_Code__c = testActivityCode,
                             Description = 'Test note',
                             Financial_Account_Number__c = testFANumber,
                             Financial_Account__c = testFAId,
                             Priority = 'Normal',
                             Source_System_Created_By__c = 'SFDC',
                             Status = 'Completed',
                             Subject = testActivityCode + ' - Test',
                             WhatId = testFAId
                            );

        insert note;

    }

    private static void setupCustomSetting(){

        Repo_Recovery_Activity_Codes__c testSetting = new Repo_Recovery_Activity_Codes__c(Name = testActivityCode);

        insert testSetting;

    }

    //Execute test
    static testmethod void testActivityModel(){
        setupTestFA();
        setupTestTask();
        setupCustomSetting();
      
        List<String> testFAIds = new List<String>();
        String currentDate = String.valueOf(Date.today().month()) +'/'+ String.valueOf(Date.today().day()) +'/' +String.valueOf(Date.today().year());
        // 5/22/2015
        
        
        
        System.debug('************************ currentDate: ' +currentDate);
        testFAIds.add(testFAId);

        Test.startTest();
        List<String> contactDates = TFSC_ActivityModel.LookupMostRecentContactDate(testFAIds);
        Test.stopTest();

        System.debug('************************ returned date: ' + contactDates.get(0));
        System.assert(contactDates.size() > 0);
       
      //  String[] strcontactDate = new List<String>();
        
        
      /*  
       // String[] strcontactDate = new String()[];
        if(contactDates.get(0).contains(':')){
           strcontactDate = contactDates.get(0).Split(':');
        }
        system.debug('@@@'+strcontactDate);
      */
      
      
        System.assertEquals(contactDates.get(0), currentDate );


    }


}