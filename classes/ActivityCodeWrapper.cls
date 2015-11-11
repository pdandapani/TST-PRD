global class ActivityCodeWrapper implements Comparable {

	public Activity_Code__c activityCode;
    public String flagType;
    
    // Constructor
    public ActivityCodeWrapper(Activity_Code__c ac, String fType) {
        activityCode = ac;
        flagType = fType;
        
        System.debug('************** activity code: ' + activityCode + ' ~ flagType: ' + flagType);
    }
    
    // Compare code options based on the sort order.
    global Integer compareTo(Object compareTo) {
        // Cast argument to ActivityCodeWrapper
        ActivityCodeWrapper compareToActivityCode = (ActivityCodeWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if(flagType == 'Quick'){
           System.debug('************** Quick Activity Code sorting ~ Quick flag: ' + activityCode.Flag_Quick__c  + ' Sort order: ' + activityCode.Sort_Order_Quick__c);
           if (activityCode.Sort_Order_Quick__c > compareToActivityCode.activityCode.Sort_Order_Quick__c) {
                // Set return value to a positive value.
                returnValue = 1;
        	} else if (activityCode.Sort_Order_Quick__c < compareToActivityCode.activityCode.Sort_Order_Quick__c) {
                // Set return value to a negative value.
                returnValue = -1;
        	} 
    	}
        
        if(flagType == 'RPC'){
           System.debug('************** RPC Activity Code sorting ~ RPC flag: ' + activityCode.Flag_RPC__c + ' Sort order: ' + activityCode.Sort_Order_RPC__c);
           if (activityCode.Sort_Order_RPC__c > compareToActivityCode.activityCode.Sort_Order_RPC__c) {
                // Set return value to a positive value.
                returnValue = 1;
        	} else if (activityCode.Sort_Order_RPC__c < compareToActivityCode.activityCode.Sort_Order_RPC__c) {
                // Set return value to a negative value.
                returnValue = -1;
        	} 
    	}
        
        if(flagType == 'Skip'){
           System.debug('************** Skip Activity Code sorting ~ Skip flag: ' + activityCode.Flag_Skip__c  + ' Sort order: ' + activityCode.Sort_Order_Skip__c);
           if (activityCode.Sort_Order_Skip__c > compareToActivityCode.activityCode.Sort_Order_Skip__c) {
                // Set return value to a positive value.
                returnValue = 1;
        	} else if (activityCode.Sort_Order_Skip__c < compareToActivityCode.activityCode.Sort_Order_Skip__c) {
                // Set return value to a negative value.
                returnValue = -1;
        	} 
    	}
        
        System.debug('***************** returnValue:' + returnValue);
        return returnValue;       
    }    
    
}