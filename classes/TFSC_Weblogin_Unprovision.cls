public class TFSC_Weblogin_Unprovision extends TFSC_Weblogin_Base {


	public WebLoginWebServiceReply execute(String SGUID) {
		
		
		WebLoginWebServiceReply result = new WebLoginWebServiceReply();
		
		Contact matchingContact = findWebloginContactBySGUID( SGUID);
		if (matchingContact != null) {
			List<User> users = [
				select id, IsActive
				from user
				where FederationIdentifier = :SGUID
				limit 1
			]; 
			
			if ( users.size() == 1) {
				update new User(
						Id = users[0].Id,
						IsActive = false
				);
			}
			result.resultCode = '0';
			result.message = 'TFSC_Weblogin_Unprovision completed successfully for SGUID:'+SGUID;
			
			//@future
			deactivePersonAccountBySGUID(SGUID);
		} else {
			// cannot find contact with SGUID specified
			
			result.resultCode = '-1';
			result.message = 'TFSC_Weblogin_Unprovision no user with SGUID='+SGUID+' in User::SGUID__c. Aborted.';
		}

		return result;
		
	}

	@future
	public static void deactivePersonAccountBySGUID(String SGUID) {
		Contact webLoginContact = (new TFSC_Weblogin_Unprovision()).findWebloginContactBySGUID( SGUID);
		
		if (webLoginContact <> null) {
			webLoginContact.Web_DeProvisioned__c = true;
			update webLoginContact;			
		}
	}

}