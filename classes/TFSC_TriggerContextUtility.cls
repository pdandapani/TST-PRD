public with sharing class TFSC_TriggerContextUtility {
	
	private static boolean triggerExecuted = false;
		 
	public static void setAlreadyExecuted() {
       	 	triggerExecuted = true;
		 }
		 
	public static boolean hasAlreadyExecuted() {
		 	return triggerExecuted;
		 }
	

}