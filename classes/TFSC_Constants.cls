/**
* @author       Stevie Ella        
* @date         05/06/2014
* @description  
*   
*    All Constants for the TFS Collections project are here
*/
public class TFSC_Constants {
	
	public static final Integer PAGE_SIZE = 10;
	
	public static final String PICKLIST_NONE_VALUE = 'None';
	
	// Interaction Entry Panel: Tab names
	public static final String INTERACTION_ENTRY_PANEL_QUICK_TAB 	= 'quick-note-tabname';
	public static final String INTERACTION_ENTRY_PANEL_RPC_TAB 		= 'rpc-note-tabname';
	public static final String INTERACTION_ENTRY_PANEL_SKIP_TAB 	= 'skip-note-tabname';
	
	// Custom Settings: Picklist Name for Method for PTP
	public static final String CUSTOM_SETTING_PICKLIST_METHOD_OF_PAYMENT = 'PTPMethod';
	
	//Activity : Status
	public static final String ACTIVITY_STATUS_COMPLETED = 'Completed';

	//VPAs Option
	public static final String VPA_PICKLIST_DEFAULT_VALUE = 'None';

	// Validation map of results: Key Used
	public static final String PTP_WUSP_CONFIRMATION_REQUIRED_MAP_KEY_FIRST 	= 'WuspConfirmationRequired_1';
	public static final String PTP_WUSP_CONFIRMATION_REQUIRED_MAP_KEY_SECOND 	= 'WuspConfirmationRequired_2';
	public static final String PTP_DATES_MAP_KEY_FIRST 							= 'DateRulePromise_1';
	public static final String PTP_DATES_MAP_KEY_SECOND                         = 'DateRulePromise_2';
	public static final String PTP_DATE2_LESS_THAN_DATE1                        = 'Date2LessThanDate1';
	public static final String COMPLETE_DATA_MAP_KEY_FIRST 						= 'CompleteDataPromise_1';
	public static final String COMPLETE_DATA_MAP_KEY_SECOND 					= 'CompleteDataPromise_2';
	public static final String RPC_CODE_PTP_REQUIRED 							= 'PTPRequiredForRPCCode';
	public static final String RPC_CODE_PTP_NOT_ALLOWED 						= 'PTPNotAllowedForRPCCode';
	public static final String QUICK_CODE_NOTE_REQUIRED 						= 'QuickNoteRequiredForCode';
	public static final String RPC_CODE_NOTE_REQUIRED 							= 'RPCNoteRequiredForCode';
	public static final String SKIP_CODE_NOTE_REQUIRED 							= 'SkipNoteRequiredForCode';
	
	// PTP Methods
	public static final String PTP_METHOD_WUCQ_CODE 						= 'WUQC';
	public static final String PTP_METHOD_CONFIRMATION_REQUIRED_WUSP_CODE 	= 'WUSP';
	
	// CALLEE Relationship option
	public static final String CALLEE_RELATIONSHIP_CX = 'CX';
	
	// Incomplete PTP Data Error Messages
	public static final String PTP_INCOMPLETE_DATA_FIRST 	= 'Data Incomplete in Promise to pay #1: Date, Method and Amount must all be non-empty or all empty';
	public static final String PTP_INCOMPLETE_DATA_SECOND 	= 'Data Incomplete in Promise to pay #1: Date, Method and Amount must all be non-empty or all empty';
	
	// Picklist: Phone Types
	public static final String PHONE_TYPE_HOME 		= 'Home';
	public static final String PHONE_TYPE_MOBILE 	= 'Mobile';
	public static final String PHONE_TYPE_WORK 		= 'Work';
}