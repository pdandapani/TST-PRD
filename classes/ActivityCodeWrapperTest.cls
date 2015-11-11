@isTest
private class ActivityCodeWrapperTest {

	
	
	// Setup test data
	private static List<Activity_Code__c> setupTestData(String testType){

		List<Activity_Code__c> listOfQuickCodes = new List<Activity_Code__c>();
		List<Activity_Code__c> listOfRPCCodes = new List<Activity_Code__c>();
		List<Activity_Code__c> listOfSkipCodes = new List<Activity_Code__c>();
		List<Activity_Code__c> listToReturn = new List<Activity_Code__c>();
		Map<String, Activity_Code__c> mapOfValidQuickActivityCodes = new Map<String, Activity_Code__c>();
	    Map<String, Activity_Code__c> mapOfValidRPCActivityCodes = new Map<String, Activity_Code__c>();
	    Map<String, Activity_Code__c> mapOfValidSkipActivityCodes = new Map<String, Activity_Code__c>();


	    if( testType == 'Quick'){

	    	Activity_Code__c quickCode2 = new Activity_Code__c(
                Name = 'DEV_QUICK2',
                Description__c = 'QUICK2',
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false,
                Sort_Order_Quick__c = 2
        	);
        	Activity_Code__c quickCode1 = new Activity_Code__c(
                Name = 'DEV_QUICK1',
                Description__c = 'QUICK1',
                Flag_Quick__c = true,
                Flag_RPC__c = false,
                Flag_Skip__c = false,
                Sort_Order_Quick__c = 1
        	);

        	listToReturn.add(quickCode2);
        	listToReturn.add(quickCode1);

	    }
        
        if( testType == 'RPC'){

		    Activity_Code__c rpcCode2 = new Activity_Code__c(
		            Name = 'DEV_RPC2',
		            Description__c = 'RPC2',
		            Flag_RPC__c = true,
		            Flag_Quick__c = false,
		            Flag_Skip__c = false,
		            Sort_Order_RPC__c = 2
		    );
		    Activity_Code__c rpcCode1 = new Activity_Code__c(
		            Name = 'DEV_RPC1',
		            Description__c = 'RPC1',
		            Flag_RPC__c = true,
		            Flag_Quick__c = false,
		            Flag_Skip__c = false,
		            Sort_Order_RPC__c = 1
		    );

		    listToReturn.add(rpcCode2);
		    listToReturn.add(rpcCode1);

		}

		if( testType == 'Skip') {

			Activity_Code__c skipCode2 = new Activity_Code__c(
                Name = 'DEV_SKIP2',
                Description__c = 'SKIP2',
                Flag_Skip__c = true,
                Flag_RPC__c = false,
                Flag_Quick__c = false,
                Sort_Order_Skip__c = 2
	        );
	        Activity_Code__c skipCode1 = new Activity_Code__c(
	                Name = 'DEV_SKIP1',
	                Description__c = 'SKIP1',
	                Flag_Skip__c = true,
	                Flag_RPC__c = false,
	                Flag_Quick__c = false,
	                Sort_Order_Skip__c = 1
	        );

	        listToReturn.add(skipCode2);
	        listToReturn.add(skipCode1);

		}
        
        return listToReturn;

	}
	


    static testMethod void getQuickCodeItemsTest(){

	    List<ActivityCodeWrapper> codeWrapper = new List<ActivityCodeWrapper>(); // Wrapper used for custom sort
	    List<Activity_Code__c> testCodes = setupTestData('Quick');
	    
	    for(Activity_Code__c activityCode : testCodes){

	        codeWrapper.add( new ActivityCodeWrapper(activityCode, 'Quick'));   

    	}

    	System.debug('******************** Beginning Quick sort ~ codeWrapper: ' + codeWrapper);
    	Test.startTest();
	    codeWrapper.sort(); //Sort using the Comparable interface with the appropriate sort order column
	    Test.stopTest();

	    System.assert(!codeWrapper.isEmpty());

    }

    static testMethod void getRPCCodeItemsTest(){

	    List<ActivityCodeWrapper> codeWrapper = new List<ActivityCodeWrapper>(); // Wrapper used for custom sort
	    List<Activity_Code__c> testCodes = setupTestData('RPC');
	    
	    for(Activity_Code__c activityCode : testCodes){
	        
	        codeWrapper.add( new ActivityCodeWrapper(activityCode, 'RPC'));   
    
    	}

    	System.debug('******************** Beginning RPC sort ~ codeWrapper: ' + codeWrapper);
    	Test.startTest();
	    codeWrapper.sort(); //Sort using the Comparable interface with the appropriate sort order column
	    Test.stopTest();

	    System.assert(!codeWrapper.isEmpty());

    }


    static testMethod void getSkipCodeItemsTest(){

	    List<ActivityCodeWrapper> codeWrapper = new List<ActivityCodeWrapper>(); // Wrapper used for custom sort
	    List<Activity_Code__c> testCodes = setupTestData('Skip');
	    
	    for(Activity_Code__c activityCode : testCodes){
	        
	        codeWrapper.add( new ActivityCodeWrapper(activityCode, 'Skip'));   
    
    	}

    	System.debug('******************** Beginning Skip sort ~ codeWrapper: ' + codeWrapper);
    	Test.startTest();
	    codeWrapper.sort(); //Sort using the Comparable interface with the appropriate sort order column
	    Test.stopTest();

	    System.assert(!codeWrapper.isEmpty());

    }
            

}