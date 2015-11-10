global class ReasonsForDelinquencyWrapper implements Comparable {

	public Reason_For_Delinquency__c rfd;
    
    // Constructor
    public ReasonsForDelinquencyWrapper(Reason_For_Delinquency__c r) {
        rfd = r;
    }
    
    // Compare RFD options based on the sort order.
    global Integer compareTo(Object compareTo) {
        // Cast argument to ReasonsForDelinquencyWrapper
        ReasonsForDelinquencyWrapper compareToRfd = (ReasonsForDelinquencyWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (rfd.Sort_Order__c > compareToRfd.rfd.Sort_Order__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (rfd.Sort_Order__c < compareToRfd.rfd.Sort_Order__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }    
    
}