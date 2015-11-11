public virtual class TFSC_Weblogin_Base {


	public User findUserBySGUID(String SGUID) {
		// find Community User record with Federation id = SGUID
		List<User> users = [
			SELECT LastLoginDate, IsActive, LastName, FirstName, FederationIdentifier, Name, ProfileId
			FROM User 
			WHERE FederationIdentifier =:SGUID
		];
		
		// return -1 if not found
		if (users.size() <> 1) {
			return null;
		} else {
			return users[0];
		}
		
	}
	
	public Contact findWebloginContactBySGUID(String SGUID) {
		List<Contact> contacts = [
			select id, CustomerPersonAccount__c, Web_CompanyName__c, Web_UserId__c, Web_DeProvisioned__c,
				FirstName, LastName, Email, SGUID__c
			from Contact
			where SGUID__c = :SGUID
			and RecordTypeId = :RecordTypeModel.ContactWebLoginRecTypeId
		];
		
		if (contacts.size() <> 1) {
			return null;
		} else {  
			return contacts[0];
		}
	}
	
	public List<Financial_Account_Customer__c> findFinancialAccountCustomerListByWebloginContactId(String webloginContactId) {
		List<Financial_Account_Customer__c> facList = [
			select Id
			from Financial_Account_Customer__c
			where Weblogin_Contact__c = :webloginContactId
		];
		
		return facList;
	}

	//protected List<Financial_Account__c> find
}