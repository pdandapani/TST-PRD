@isTest(SeeAllData=false)
public class TFSC_TestUtility {

	public Financial_Account__c finAcct {get;private set;}
	public Financial_Account_Customer__c finAcctCust {get;private set;}
	public Account person {get;private set;}
	public Contact personContact {get;private set;}
	public User testAdmin {get;private set;}
	public User communityUser {get;private set;}
	public List<CaseOutCome__c> caseOutcomes {get;private set;}
	public List<Case> cases {get;private set;}
	public FeedItem feedItem {get;private set;}
	public CaseComment caseComment {get;private set;}

	public TFSC_TestUtility() {

		Profile tmccCustomerProfile = [select Id from Profile where Name = 'TMCC Customer Community Login User'];
		Profile sysAdminProfile = [select Id from Profile where Name = 'System Administrator'];
		UserRole sysAdminRole = [select Id from UserRole where Name = 'System Administration'];

		String SGUID = randomness().substring(0,10);

		//create a test admin, so that we can perform the next set of dml statements with it
		insert (this.testAdmin = newUser(sysAdminProfile.Id, sysAdminRole.Id));

		System.runAs(this.testAdmin) {
			//insert FA
			insert (this.finAcct = new Financial_Account__c(
				Financial_Account_Number__c = TFSC_TestUtils.generateRandomString(8)
			));
			
			//insert personAccount
			insert (this.person = new Account(
				RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
				SGUID__c = TFSC_TestUtils.generateRandomString(10),
				FirstName = 'Test',
				LastName = 'Person',
				Web_CompanyName__pc = 'Company Name',
				Web_UserId__pc = 'WebUserId',
				PersonEmail = 'email@example.test'
			));

			TFSC_CommunityAccountUtil autil = new TFSC_CommunityAccountUtil();

			//need to pull the associated contact that the system created
			//this.personContact = [
			//	select Id 
			//	from Contact 
			//	where Id in (
			//		select PersonContactId 
			//		from Account 
			//		where Id = :this.person.Id
			//	)
			//];
			insert (this.personContact = new Contact(
				LastName = 'Test',
				AccountId = autil.acctId,
				Email = 'test@abc.com',
				RecordTypeId = Contact.SObjectType.getDescribe().getRecordTypeInfosByName().get('Weblogin').getRecordtypeId(),
				SGUID__c = SGUID
			));

			insert (this.finAcctCust = new Financial_Account_Customer__c(
				Financial_Account__c = this.finAcct.Id,
				Account__c = this.person.Id,
				Name = 'FinAcctCust',
				Borrower_Status__c = 'TEST',
				Weblogin_Contact__c = this.personContact.Id
			));

			insert (this.caseOutcomes = new List<CaseOutCome__c> {
				newCaseOutcome('Subject'),
				newCaseOutcome('Default') 
			});

			//sample cases, one support request, one due date change request
			insert (this.cases = new List<Case>{
				newSupportRequest(this.finAcctCust.Id, this.person.Id),
				newDueDateChageRequest(this.finAcctCust.Id, this.person.Id)
			});

			insert (this.caseComment = new CaseComment (
				ParentId = this.cases[0].Id,
				CommentBody = 'CommentBody',
				IsPublished = true
			));

			insert (this.feedItem = new FeedItem(
				ParentId = this.cases[0].Id,
				ContentFileName = 'FeedItem',
				ContentData = Blob.valueOf('ContentData'),
				Body = 'Body'
			));

		}

		//build a community user 
		insert (this.communityUser = newUser(tmccCustomerProfile.Id, null, this.personContact.Id, SGUID));

	}

	private CaseOutCome__c newCaseOutcome(String subject) {
		return new CaseOutCome__c(
			CaseSubject__c = subject,
			OutCome__c = randomness().substring(0,10),
			OutComeId__c = randomness().substring(0,6)
		);
	}

	private User newUser(Id profileName, Id roleId) {
		return newUser(profileName, roleId, null, null);
	}

	private User newUser(String profileId, Id roleId, Id pcId, String fedId) {
		User newUser = new User(
			Alias = 'stst123', 
            Email='usr123@toyotaDevish.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profileId, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='usr' + randomness().substring(0,5) + '@toyotaDevish.com',
            UserRoleId = roleId,
            ContactId = pcId,
            FederationIdentifier = fedId
        );

		return newUser;
	}

	private Case newSupportRequest(Id finAcctCustId, Id acctId) {
		return newCase(finAcctCustId, acctId, Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support Request').getRecordTypeId());
	}

	private Case newDueDateChageRequest(Id finAcctCustId, Id acctId) {
		Case retCase = newCase(finAcctCustId, acctId, Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Due Date Change Request').getRecordTypeId());
		retCase.Subject = 'Due Date Change Request';
		retCase.Requested_Due_Date_Day_of_Month__c = '15';
		retCase.I_Agree_to_Terms_and_Conditions__c = true;
		return retCase;
	}

	private Case newCase(Id finAcctCustId, Id acctId, Id recTypeId) {
		return new Case(
			AccountId = acctId,
			RecordTypeId = recTypeId,
			Financial_Account_Customer__c = finAcctCustId,
			Status = 'New',
			Subject = 'Subject',
			Description = 'Description'
		);
	}

	private String randomness() {
		return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
	}

}