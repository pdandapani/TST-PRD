public class TFSC_Weblogin_UnreadMsgCount extends TFSC_Weblogin_Base{

    
	public WebLoginWebServiceReply execute(String SGUID) {
		// find Community User record with Federation id = SGUID		
		User webloginUser = findUserBySGUID(SGUID);
		
		// return -1 if not found
		if (webloginUser == null) {
			return new WebLoginWebServiceReply(-1, SGUID + ' is not a valid Federation id');
		}
		
		// find last login date
		DateTime lastLoginDate = webloginUser.LastLoginDate;
		
		// find the weblogin PersonAccount associated with this user
		Contact webloginContact = findWebloginContactBySGUID(SGUID);
		
		if (webloginContact == null) {
			return new WebLoginWebServiceReply(-1, SGUID + ' is not a valid SGUID on PersonAccount of RecType Weblogin');
		}
		
	 	Id webloginContactId = webloginContact.Id;
		
		
		//find the FAC that this weblogin is registered with
		List<Financial_Account_Customer__c> facList = findFinancialAccountCustomerListByWebloginContactId(webloginContactId);

		Set<Id> facIdSet = new Set<id>();
		for(Financial_Account_Customer__c fac : facList) {
			facIdSet.add(fac.Id);
		}	

		//updated by Benjamin on 2015-02-27
		List<Case_LastViewed__c> caseLastViewedList = [
			select Case__c 
			from Case_LastViewed__c
			where User__c = :webloginUser.Id
			and Has_Viewed__c = true
		];
		
		Set<id> viewedCaseIdSet = new Set<Id>();
		for(Case_LastViewed__c clv : caseLastViewedList) {
			viewedCaseIdSet.add(clv.Case__c);
		}
		
		List<Case> contactCases = [
			select Id
			from Case
			where ContactId = :webloginContactId
			and Financial_Account_Customer__c in :facIdSet
		];
		
		Integer unreadMsgCount = 0;
		for(Case c : contactCases) {
			if ( !viewedCaseIdSet.contains(c.id )) {
				unreadMsgCount++;
			}
		} 
	
		System.Debug('TFSC_Weblogin_UnreadMsgCount for '+SGUID + ' = '+unreadMsgCount+ ' last login date = '+ lastLoginDate);		
		
		return new WebLoginWebServiceReply(unreadMsgCount, 'unread message = '+unreadMsgCount+' for '+SGUID+ ' last login date = '+ lastLoginDate);
	}  

}