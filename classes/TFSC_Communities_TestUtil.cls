/**
* @author: Salesforce Services
* @date:    2014-09-06
* @description: Test Class for the TFS/LFS Communities
*               
* @log:
* -----------------------------------------------------------------------------
*    Developer                    Date                Description
* -----------------------------------------------------------------------------
*    Scott W	                2014-09-06          creation
*   
*/
@isTest(SeeAllData=false)
private class TFSC_Communities_TestUtil {
	
	static testMethod void test_SupportRequests() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_SupportRequests;
			System.Test.setCurrentPage(pr);
			TFSC_SupportRequestsController con = new TFSC_SupportRequestsController();

			con.orderBy = 1;
			con.fetchSupportRequests();

			con.orderBy = 2;
			con.fetchSupportRequests();

			con.orderBy = 3;
			con.fetchSupportRequests();

			con.orderBy = 4;
			con.fetchSupportRequests();

		}
	}

	static testMethod void test_SupportRequests_NonCommunityUser() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.testAdmin) { //not a community user

			//setup the test page
			PageReference pr = Page.TFSC_SupportRequests;
			System.Test.setCurrentPage(pr);
			TFSC_SupportRequestsController con = new TFSC_SupportRequestsController();

			Boolean hasSupportRequests = con.hasSupportRequests;

		}
	}

	static testMethod void test_SupportRequest() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_SupportRequests;
			pr.getParameters().put('id', test.cases[0].Id);
			System.Test.setCurrentPage(pr);

			TFSC_SupportRequestController con = new TFSC_SupportRequestController(
				new ApexPages.StandardController(test.cases[0])
			);

			Boolean hasAttachments = con.hasAttachments;
			Boolean hasComments = con.hasComments;
			Boolean isSupportRequest = con.isSupportRequest;
			Boolean isDueDateChangeRequest = con.isDueDateChangeRequest;

			PageReference addAttachment = con.addAttachment();
			PageReference addComment = con.addComment();

		}
	}

	@IsTest
	public static void test_SupportAttachment() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_SupportAttachment;
			pr.getParameters().put('id', test.cases[0].Id);
			System.Test.setCurrentPage(pr);

			TFSC_SupportAttachmentController con = new TFSC_SupportAttachmentController(
				new ApexPages.StandardController(test.cases[0])
			);
			Id ChatterNetworkId = TFSC_SupportAttachmentController.ChatterNetworkId;
		}
	}

	static testMethod void test_SupportComment() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_SupportComment;
			pr.getParameters().put('id', test.cases[0].Id);
			System.Test.setCurrentPage(pr);

			TFSC_SupportCommentController con = new TFSC_SupportCommentController(
				new ApexPages.StandardController(test.cases[0])
			);

			con.newComment.CommentBody = 'Comment';
			con.createComment();

		}
	}

	static testMethod void test_RequestDueDateChange() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_SupportComment;
			System.Test.setCurrentPage(pr);

			TFSC_RequestDueDateChangeController con = new TFSC_RequestDueDateChangeController(
				new ApexPages.StandardController(new Case())
			);

			con.newCase.Description = 'Description';
			con.newCase.Requested_Due_Date_Day_of_Month__c = '15';
			con.create();

			con.newCase.I_Agree_to_Terms_and_Conditions__c = true;
			con.create();

		}
	}

	static testMethod void test_NewSupportRequest() {
		//setup the test data
		TestUtility test = new TestUtility();
		System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_SupportComment;
			System.Test.setCurrentPage(pr);

			TFSC_NewSupportRequestController con = new TFSC_NewSupportRequestController(
				new ApexPages.StandardController(new Case())
			);

			con.newCase.Description = 'Description';
			con.create();

		}
	}

	static testMethod void test_CommunitiesIntermediate() {
		//setup the test data
		//TestUtility test = new TestUtility();
		//System.runAs(test.communityUser) {

			//setup the test page
			PageReference pr = Page.TFSC_CommunitiesIntermediate;
			System.Test.setCurrentPage(pr);

			TFSC_CommunitiesIntermediateController con = new TFSC_CommunitiesIntermediateController();
			String defaultPage = con.defaultPage;
			System.assertEquals(defaultPage, TFSC_CommunitySettings.DEFAULT_PAGE);

			TFSC_CommunitiesIntermediateController.noop();

		//}
	}

	static testMethod void test_EasyXDMWrapper() {
		//setup the test data
		//TestUtility test = new TestUtility();
		//System.runAs(test.communityUser) {

			//setup the test page
			//PageReference pr = Page.TFSC_CommunitiesIntermediate;
			//System.Test.setCurrentPage(pr);

			TFSC_EasyXDMWrapperController con = new TFSC_EasyXDMWrapperController();
			String redirectUrl = con.redirectUrl;
			System.assertEquals(redirectUrl, TFSC_CommunitySettings.REDIRECT_URL);

		//}
	}

	class TestUtility {

		public Financial_Account__c finAcct {get;private set;}
		public Financial_Account_Customer__c finAcctCust {get;private set;}
		public Account person {get;private set;}
		public Contact personContact {get;private set;}
		public User testAdmin {get;private set;}
		public User communityUser {get;private set;}
		public FeedItem feedItem {get;private set;}
		public List<Case> cases {get;private set;}
		public List<CaseComment> caseComments {get;private set;}

		public TestUtility() {

			UserRole sysAdminRole = [select Id from UserRole where Name = 'System Administration'];

			//create a test admin, so that we can perform the next set of dml statements with it
			insert (this.testAdmin = newUser('System Administrator', sysAdminRole.Id, null));

			System.runAs(this.testAdmin) {
				//insert FA
				insert (this.finAcct = new Financial_Account__c(
					Financial_Account_Number__c = TFSC_TestUtils.generateRandomString(8)
				));
				
				//insert personAccount
				insert (this.person = new Account(
					RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Web Login').getRecordTypeId(),
					SGUID__c = TFSC_TestUtils.generateRandomString(10),
					FirstName = 'Test',
					LastName = 'Person',
					Web_CompanyName__pc = 'Company Name',
					Web_UserId__pc = 'WebUserId',
					PersonEmail = 'email@example.test'
				));

				//need to pull the associated contact that the system created
				this.personContact = [
					select Id 
					from Contact 
					where Id in (
						select PersonContactId 
						from Account 
						where Id = :this.person.Id
					)
				];

				insert (this.finAcctCust = new Financial_Account_Customer__c(
					Financial_Account__c = this.finAcct.Id,
					Account__c = this.person.Id,
					Name = 'FinAcctCust',
					Weblogin_Contact__c = this.personContact.Id,
					Borrower_Status__c = 'Active'
				));

				//sample cases, one support request, one due date change request
				insert (this.cases = new List<Case>{
					newSupportRequest(this.finAcctCust.Id, this.person.Id),
					newDueDateChageRequest(this.finAcctCust.Id, this.person.Id)
				});

				insert (this.feedItem = new FeedItem(
					ParentId = this.cases[0].Id,
					ContentFileName = 'FeedItem',
					ContentData = Blob.valueOf('ContentData'),
					Body = 'Body'
				));

			}

			//build a community user 
			insert (this.communityUser = newUser('TMCC Customer Community Login User', null, this.personContact.Id));

		}

		private User newUser(String profileName, Id roleId) {
			return newUser(profileName, roleId, null);
		}

		private User newUser(String profileName, Id roleId, Id pcId) {
			User newUser = TFSC_TestUtils.generateTestUser(profileName, false);
			newUser.UserRoleId = roleId;
			newUser.ContactId = pcId;
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

	}
	
}