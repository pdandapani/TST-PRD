global class PaymentMethodWrapper implements Comparable{

	public Payment_Method__c pmtMethod;
    
    // Constructor
    public PaymentMethodWrapper(Payment_Method__c pMethod) {
        pmtMethod = pMethod;
    }
    
    // Compare RFD options based on the sort order.
    global Integer compareTo(Object compareTo) {
        // Cast argument to PaymentMethodWrapper
        PaymentMethodWrapper compareToPmtMethod = (PaymentMethodWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (pmtMethod.Sort_Order__c > compareToPmtMethod.pmtMethod.Sort_Order__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (pmtMethod.Sort_Order__c < compareToPmtMethod.pmtMethod.Sort_Order__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }

}