@IsTest
public class TFSC_Weblogin_ProvisionTest extends TFSC_Weblogin_Base {
	
	public static String SGUID1 = 'SGUID1forUnitTest';
	public static String FaNum1 = 'FAnumForUnitTest';
	public static String email1 = 'mgmtEmailForUnitTest@gmail.com';
	public static String firstName1 = 'fn1';
	public static String lastName1 = 'ln1';
	public static String companyName1 = 'cn1';
	public static String userId1 = 'userId1';

	@IsTest (SeeAllData=false)
	public static void testExistingWebloginContact() {
		
		createData(true);
		
		TFSC_Weblogin_Provision provision = new TFSC_Weblogin_Provision();
		provision.execute(SGUID1, FaNum1, '6',email1, userId1,'','','');
		
		TFSC_Weblogin_Register register = new TFSC_Weblogin_Register();
		register.execute(SGUID1, FaNum1, '6');

		TFSC_Weblogin_Unregister unregister = new TFSC_Weblogin_Unregister();
		unregister.execute(SGUID1, FaNum1);

		TFSC_Weblogin_Unprovision deprovision = new TFSC_Weblogin_Unprovision();
		deprovision.execute(SGUID1);
		
		TFSC_Weblogin_Provision provision2 = new TFSC_Weblogin_Provision();
		provision2.execute(SGUID1, FaNum1, '6',email1, userId1,'','','');
		
		
		TFSC_Weblogin_UnreadMsgCount unreadCount = new TFSC_Weblogin_UnreadMsgCount();
		unreadCount.execute(SGUID1);
		
		TFSC_Weblogin_Unprovision deprovision2 = new TFSC_Weblogin_Unprovision();
		deprovision2.execute(SGUID1);
	}

	@IsTest (SeeAllData=false)
	public static void testUpdateContactProvision() {
        TFSC_TestUtility testUtil = new TFSC_TestUtility();
        System.runAs(testUtil.testAdmin) {
        	
        	List<Contact> conflictingEmailContacts = new List<Contact>();
        	conflictingEmailContacts.add(new Contact(LastName='Person',Email=email1,Web_DeProvisioned__c=true));
        	conflictingEmailContacts.add(new Contact(LastName='Person',Email=email1));
			insert conflictingEmailContacts;
			
			TFSC_Weblogin_Provision provision = new TFSC_Weblogin_Provision();
	        
	        testUtil.finAcctCust.Customer_Role_Type__c = '6';
	        update testUtil.finAcctCust;
	        
			provision.execute(SGUID1, testUtil.finAcct.Financial_Account_Number__c, testUtil.finAcctCust.Customer_Role_Type__c,email1, userId1,'','','');
        }
	}

	@IsTest (SeeAllData=false)
	public static void testNewContactProvision() {
        TFSC_TestUtility testUtil = new TFSC_TestUtility();
        System.runAs(testUtil.testAdmin) {
			
			TFSC_Weblogin_Provision provision = new TFSC_Weblogin_Provision();
	        
	        testUtil.finAcctCust.Customer_Role_Type__c = '6';
	        update testUtil.finAcctCust;
	        
			provision.execute(SGUID1, testUtil.finAcct.Financial_Account_Number__c, testUtil.finAcctCust.Customer_Role_Type__c,email1, userId1,'','','');
        }
	}
	
	@IsTest (SeeAllData=false)
	public static void testProfileUpdate() {
		TFSC_Weblogin_ProvisionTest test = new TFSC_Weblogin_ProvisionTest();
		createData(true);
		
		TFSC_Weblogin_ProfileUpdate profileUpdate = new TFSC_Weblogin_ProfileUpdate();
		WebLoginWebServiceReply reply1 = profileUpdate.execute(SGUID1, 'mgmtEmailForUnitTest@gmail.com2','userIdForUnitTest2','FirstName2','LastName2','CompanyName2');		
		System.Debug(reply1.message);
		System.assert(reply1.resultCode == '0');
		test.testProfileUpdate(SGUID1,'mgmtEmailForUnitTest@gmail.com2','userIdForUnitTest2','FirstName2','LastName2','CompanyName2');
		
		WebLoginWebServiceReply reply2 = profileUpdate.execute(SGUID1,email1, '','','','');
		System.assert(reply2.resultCode == '0');
		test.testProfileUpdate(SGUID1,email1,'userIdForUnitTest2','FirstName2','LastName2','CompanyName2');
		
		profileUpdate.execute(SGUID1,'', userId1,'','','');
		test.testProfileUpdate(SGUID1,email1,userId1,'FirstName2','LastName2','CompanyName2');
		
		profileUpdate.execute(SGUID1,'', '',firstName1,'','');
		test.testProfileUpdate(SGUID1,email1,userId1,firstName1,'LastName2','CompanyName2');
		
		profileUpdate.execute(SGUID1,'', '','',lastName1,'');
		test.testProfileUpdate(SGUID1,email1,userId1,firstName1,lastName1,'CompanyName2');
		
		profileUpdate.execute(SGUID1,'', '','','',companyName1);
		test.testProfileUpdate(SGUID1,email1,userId1,firstName1,lastName1,companyName1);
		
		profileUpdate.execute(SGUID1,'mgmtEmailForUnitTest@gmail.com2', '','','',companyName1);
		test.testProfileUpdate(SGUID1,'mgmtEmailForUnitTest@gmail.com2',userId1,firstName1,lastName1,companyName1);
		
		profileUpdate.execute(SGUID1,'mgmtEmailForUnitTest@gmail.com3', '','','',companyName1);
		test.testProfileUpdate(SGUID1,'mgmtEmailForUnitTest@gmail.com3',userId1,firstName1,lastName1,companyName1);
		
		profileUpdate.execute(SGUID1,'mgmtEmailForUnitTest@gmail.com2', '','','',companyName1);
		test.testProfileUpdate(SGUID1,'mgmtEmailForUnitTest@gmail.com2',userId1,firstName1,lastName1,companyName1);
		
		
		//  change to sahin
		
		profileUpdate.execute(SGUID1,'sahin@yahoo.com', 'sahin1','','','');
		test.testProfileUpdate(SGUID1,'sahin@yahoo.com','sahin1',firstName1,lastName1,companyName1);
		
		profileUpdate.execute(SGUID1,'sahin@yahoo.com', 'sahin2','','','');
		test.testProfileUpdate(SGUID1,'sahin@yahoo.com','sahin2',firstName1,lastName1,companyName1);
		
		profileUpdate.execute(SGUID1,'sahin@yahoo.com', 'sahin1','','','');
		test.testProfileUpdate(SGUID1,'sahin@yahoo.com','sahin1',firstName1,lastName1,companyName1);
		
		profileUpdate.execute(SGUID1,'sahin@yahoo.com', 'sahin1','','','');
		test.testProfileUpdate(SGUID1,'sahin@yahoo.com','sahin1',firstName1,lastName1,companyName1);
	}
	
	public void testProfileUpdate(String SGUID, String mgmtEmail, String userId, String FirstName, String LastName, String CompanyName) {
		Contact test1Contact = findWebloginContactBySGUID(SGUID);
		System.Debug('testProfileUpdate -'+test1Contact.Email);
		System.Debug('mgmtEmail - '+mgmtEmail);
		
		System.assertEquals(test1Contact.SGUID__C, SGUID);
		System.assert(mgmtEmail.equalsIgnoreCase(test1Contact.Email));	
		System.assert(userId.equalsIgnoreCase(test1Contact.Web_UserId__c));	
		System.assert(FirstName.equalsIgnoreCase(test1Contact.FirstName));	
		System.assert(LastName.equalsIgnoreCase(test1Contact.LastName));			
		System.assert(CompanyName.equalsIgnoreCase(test1Contact.Web_CompanyName__c));		
	}
	
	
	
	public static void createData(boolean shouldCreateContact) {
		//imsert FA
		Financial_Account__c fa = new Financial_Account__c();
		fa.Financial_Account_Number__c = FaNum1;
		insert fa;
		
		if (!shouldCreateContact) return;
		
		//insert webLogin contact
		Contact wlContact = new Contact();
		wlContact.RecordTypeId = RecordTypeModel.ContactWebLoginRecTypeId;
		wlContact.SGUID__c = SGUID1;
		wlContact.firstName = firstName1;
		wlContact.LastName = lastName1;
		wlContact.Web_CompanyName__c = companyName1;
		wlContact.Web_UserId__c = userId1;
		wlContact.Email = email1;
		
		insert wlContact;
	}
}