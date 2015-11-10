/*****
 * Salesforce.com Success Services
 * Name: RL_Constants
 * Description: Constants used in the Rights Letter implementation
 */

public class RL_Constants {
	public static final String RL_AGENT_PROFILE_NAME = 'Administrative Agent';
	public static final String NOTICE_CALENDAR_BUSINESS = 'Business';
    public static final String NOTICE_CALENDAR_HOURS = 'Hours';
    public static final String NOTICE_CALENDAR_CALENDAR = 'Calendar';
    public static final Integer MILLISECONDS_HOURS_MULTIPLIER = 3600000;
    public static final Integer MILLISECONDS_DAYS_MULTIPLIER = 86400000;
    public static final String PRECEDING = 'Preceding';
    public static final String FOLLOWING = 'Following';
    public static final String GMT_TIMEZONE = 'Etc/Greenwich';
    public static final String DATE_FORMAT = 'MM/dd/YY hh:mm a ';
    public static final String CALENDAR_NAME = 'Rights Letters Mailing';
    public static final Double LOWEST_ZIP_CODE = 501;
    public static final Double HIGHEST_ZIP_CODE = 99950;
    public static final String PRIMARY_BORROWER_ROLE_TYPE = '0-Primary Borrower';
    public static final String SOFT_VALIDATION_MESSAGE = 'Additional issues that should be addressed:';
    public static final String HARD_VALIDATION_MESSAGE = 'These issues must be fixed:';
    public static final String NOS_RT = 'RL Notice of Sale';
    public static final String NOS_SALVAGE_RT = 'RL Notice of Sale-Salvage';
    public static final String DR_NOS_RT = 'Notice of Sale';
    public static final String DR_RL_RT = 'Rights Letters';
    public static final String COVER_LETTER_FORM = '0606';
    public enum FormType {Automatic, Interactive}
    public enum SystemName {FileNet, Documentum}
    
}