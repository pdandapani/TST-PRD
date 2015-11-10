public class TFSC_Weblogin_ProfileUpdate extends TFSC_Weblogin_Base{

		public WebLoginWebServiceReply execute(String SGUID, String managementEmail, String userName, String FirstName, String LastName, String CompanyName) {
	
		boolean isUpdated = false;
		
		//use the SGUID to find the Weblogin Contact record
		Contact webloginContact = findWebloginContactBySGUID(SGUID);
		
		if (webloginContact == null ) {
			return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_ProfileUpdate - '+SGUID+' not found for profile update'); 
		}

		String beforeProfile = webloginToString(webloginContact);
	
		//if managementEmail <> null check for unique
		if (managementEmail <> null && managementEmail.length() > 0 ) {
			//check if managementEmail is unique
			List<Contact> contactWithDupEmail = [
				select id, Email
				from Contact
				where RecordTypeId = :RecordTypeModel.ContactWebLoginRecTypeId
				and Email = :managementEmail
			];
			
			if (( contactWithDupEmail.size() > 0) && (contactWithDupEmail[0].Email <> managementEmail)) {
				return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_ProfileUpdate - '+managementEmail+' is already registered with another contact'); 
			}
			
			webloginContact.Email = managementEmail;

			isUpdated = true;
		}
	
		if (userName <> null && userName.length() > 0 ) {
			//check if userName is unique
			List<Contact> contactsWithDupUsername = [
				select id, Web_UserId__c
				from Contact
				where RecordTypeId = :RecordTypeModel.ContactWebLoginRecTypeId
				and Web_UserId__c = :userName
			];
			
			if (( contactsWithDupUsername.size() > 0)  && (contactsWithDupUsername[0].Web_UserId__c <> userName)) {
				return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_ProfileUpdate - '+userName+' is already registred with another contact'); 
			}
			
			webloginContact.Web_UserId__c = userName;
			isUpdated = true;
		}	
		
		if (FirstName <> null && FirstName.length() > 0 ) {
			webloginContact.FirstName = FirstName;
			isUpdated = true;
		}
		
		if (LastName <> null && LastName.length() > 0 ) {
			webloginContact.LastName = LastName;
			isUpdated = true;
		}		


		if (CompanyName <> null && CompanyName.length() > 0 ) {
			webloginContact.Web_CompanyName__c = CompanyName;
			isUpdated = true;
		}
		
		String afterProfile = webloginToString(webloginContact);
		
		if (isUpdated) {
			update webloginContact;
			
			List<User> webusers = [select Id from User where Contact.Id = :webloginContact.Id limit 1];
			if (webusers.size() == 0) {
				//no need to reply with error
				//for JIT - there is no guarantee that the user will exist or be active at this point
				//return new WebLoginWebServiceReply(-1, 'TFSC_Weblogin_ProfileUpdate - '+SGUID+' user not found!');
			} else {
				//@future
				updateWebUser(webusers[0].Id, managementEmail, username, FirstName, LastName, CompanyName);
			}

			return new WebLoginWebServiceReply(0,'TFSC_Weblogin_ProfileUpdate from '+ beforeProfile +' to '+ afterProfile);
		} else {
			return new WebLoginWebServiceReply(0,'TFSC_Weblogin_ProfileUpdate no change for  '+ beforeProfile );
		}
		
		
	}
	
	public String webloginToString(Contact webloginContact) {
		String result = webloginContact.Web_UserId__c+'/'+ webloginContact.Email+'/'+webloginContact.FirstName+'/'+ webloginContact.LastName +'/'+ webloginContact.Web_CompanyName__c;
		return result;
	}  

	@future
	public static void updateWebUser(Id userId, String email, String username, String fnom, String lnom, String cnom) {
		User u = new User(Id = userId);
		if (String.isNotBlank(email)) {
			u.Email = email;
		}
		if (String.isNotBlank(username)) {
			u.Weblogin_Username__c = username;
		}
		if (String.isNotBlank(fnom)) {
			u.FirstName = fnom;
		}
		if (String.isNotBlank(lnom)) {
			u.LastName = lnom;
		}
		if (String.isNotBlank(cnom)) {
			u.LastName = cnom;
		}
		update u;
	}
	
	
}