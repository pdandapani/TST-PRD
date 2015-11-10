public class TFSC_Weblogin_Provision extends TFSC_Weblogin_Base {

    static final Id RTID_COMMACCT = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Community Account').getRecordTypeId();

    public WebLoginWebServiceReply execute(String SGUID, String FinancialAccountNumber, String FinancialAccountBorrowerNumber, 
        String managementEmail, String userName,
        String FirstName, String LastName, String CompanyName) {
        
        //check if the SGUID is already registered
        Contact existingWebloginContact = findWebloginContactBySGUID(SGUID);
        
        if (existingWebloginContact <> null ) {
        	User webloginUser = findUserBySGUID(SGUID);
            if ( webloginUser <> null && !webloginUser.IsActive) {
                //@Future method to avoid Mix DML call
                reactivateExistingWebLoginUser(webloginUser);
            }
            
            //A Customer Community User is guaranteed to have a contact that can be used to trace back to PersonAccount
            
            existingWebloginContact.Web_DeProvisioned__c = false;
            update existingWebloginContact;
            
                
        } else {
            
            /*  disable checking of unique email and userId as discussed with Sahin on 9/8/2014
            The website will be responsible for that.
             
            //check if managementEmail is unique
            List<Account> accountWithDupEmail = [
                select id 
                from Account
                where isPersonAccount = true
                and PersonEmail = :managementEmail
                and Web_DeProvisioned__pc = false
            ];
            
            if ( accountWithDupEmail.size() > 0) {
                return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Provision - '+managementEmail+' is already registred with another account'); 
            }
            
            //check if userName is unique
            List<Account> accountWithDupUserId = [
                select id 
                from Account
                where isPersonAccount = true
                and Web_UserId__pc = :userName
                and Web_DeProvisioned__pc = false
            ];
            
            if ( accountWithDupUserId.size() > 0) {
                return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Provision - '+userName+' is already registred with another account'); 
            }
            */          
            
            //find the FA
	        List<Financial_Account__c> faList = [
	            select id
	            from Financial_Account__c
	            where Financial_Account_Number__c = :FinancialAccountNumber
	        ];
	        
	        if (faList.size()  <> 1) {
	            return new WebLoginWebServiceReply(-1,'cannot use FinancialAccountNumber & FinancialAccountBorrowerNumber to find Financial_Account_Customer__c. Aborting');
	        }
	        
	        Id financialAccountId = faList[0].Id;
	        
	        //find the FAC now
	        List<Financial_Account_Customer__c> facList = [
	            select id, Account__c, Account__r.FirstName, Account__r.LastName, Account__r.Name
	            from Financial_Account_Customer__c
	            where Financial_Account__c = :financialAccountId
	            and Customer_Borrower_Number__c = :FinancialAccountBorrowerNumber
	        ];
	        
	        if (facList.size() <> 1) {
	            //cannot find the customerPersonAccount - data problem
	            return new WebLoginWebServiceReply(-1,'cannot use FinancialAccountNumber & FinancialAccountBorrowerNumber to find Financial_Account_Customer__c. Aborting');
	        }
	        
	        //found Account id of Customer Person Account, firstname, lastname and companyname
	        Financial_Account_Customer__c fac = facList[0]; 
	        
            if ( LastName == null || LastName.length() == 0) { 
	            LastName = fac.Account__r.LastName;
	        }
	        
	        if ( CompanyName == null || CompanyName.length() == 0) { 
	            CompanyName = fac.Account__r.Name;
	        }
	        
	        if (String.IsBlank(LastName)) {
	            LastName = String.IsBlank(CompanyName) 
	                ? 'Business' 
	                : CompanyName
	            ;
	        }
              
        	Contact webloginContact;
        	List<Contact> existingMatchingLastnameEmail = [
                select id, Email, Web_DeProvisioned__c, SGUID__c
                from Contact
                where Email = :managementEmail 
                and LastName = :LastName
            ];

            boolean shouldCreateContact = true;
            if (existingMatchingLastnameEmail.size() > 0) {
            	for(Contact matchingContact : existingMatchingLastnameEmail) {
            		if (matchingContact.Web_DeProvisioned__c) {
            			//Archived contact. If email is not already changed, Change contact's Email and continue creating weblogin as usual.
            			if (!matchingContact.Email.endsWith('deactivated')) {
            				matchingContact.Email = matchingContact.Email + 'deactivated';
            				//matchingContact.SGUID__c = null;
            				update matchingContact;
            			}
            		} else {
            			//Shell Contact. Update contact with fields provided and set as Weblogin on FAC record.
            			shouldCreateContact = false;
            			webloginContact = UpdateWebloginContact(matchingContact, SGUID,FinancialAccountNumber, FinancialAccountBorrowerNumber, 
                			managementEmail, userName, FirstName, LastName, CompanyName);
            		}
            	}
            }
            if (shouldCreateContact) {
            	webloginContact = CreateWebloginContact(SGUID,FinancialAccountNumber, FinancialAccountBorrowerNumber, 
                	managementEmail, userName, FirstName, LastName, CompanyName);
            }
            if ( webloginContact == null) { 
                //return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Provision cannot find FA to complete provision - '+FinancialAccountNumber);
                return new WebLoginWebServiceReply(-1,'cannot use FinancialAccountNumber & FinancialAccountBorrowerNumber to find Financial_Account_Customer__c. Aborting');
            }   
            
            // now add a user to the system in future call to avoid Mix DML exception
            //SW: removed for JIT user provisioning
            //createPersonAccountUser(webloginContact.Id);
        }
        

        
        // now auto register this SGUID for this FAC
        TFSC_Weblogin_Register register = new TFSC_Weblogin_Register();
        WebLoginWebServiceReply registerResult = register.execute(SGUID, FinancialAccountNumber, FinancialAccountBorrowerNumber);
        
        if (registerResult.resultCode != '0') {
        	return registerResult;
        } else {
        	return new WebLoginWebServiceReply(0,'Provision & registration completed successfully for SGUID='+SGUID);
        }
        
    }
    
    private Contact CreateWebloginContact(String SGUID, String FinancialAccountNumber, String FinancialAccountBorrowerNumber, 
        String managementEmail, String userName, String FirstName, String LastName, String CompanyName) {
        	//now use FinancialAccountNumber & FinancialAccountBorrowerNumber to find
        //the Customer PersonAccount
        Contact customerContact = null;

        //retrieve the community account with the least number of total contacts
        //Account acct = [
        //    select Id//, Community_Contacts__c 
        //    from Account 
        //    where RecordTypeId = :RTID_COMMACCT 
        //    order by Community_Contacts__c
        //    limit 1
        //];
        
        
        //find the FA
        List<Financial_Account__c> faList = [
            select id
            from Financial_Account__c
            where Financial_Account_Number__c = :FinancialAccountNumber
        ];
        
        if (faList.size()  <> 1) {
            return null;
        }
        
        Id financialAccountId = faList[0].Id;
        
        //find the FAC now
        List<Financial_Account_Customer__c> facList = [
            select id, Account__c, Account__r.FirstName, Account__r.LastName, Account__r.Name
            from Financial_Account_Customer__c
            where Financial_Account__c = :financialAccountId
            and Customer_Borrower_Number__c = :FinancialAccountBorrowerNumber
        ];
        
        if (facList.size() <> 1) {
            //cannot find the customerPersonAccount - data problem
            return null;
        }

        TFSC_CommunityAccountUtil autil = new TFSC_CommunityAccountUtil();
        
        //found Account id of Customer Person Account, firstname, lastname and companyname
        Financial_Account_Customer__c fac = facList[0]; 
        
        Contact webloginContact = new Contact();
        //webloginContact.recordTypeId = RecordTypeModel.ContactWebLoginRecTypeId;
        webloginContact.AccountId = autil.acctId;
        webloginContact.RecordTypeId = Contact.SObjectType.getDescribe().getRecordTypeInfosByName().get('Weblogin').getrecordTypeId();
        webloginContact.SGUID__c = SGUID; 
        
        webloginContact.CustomerPersonAccount__c = fac.Account__c;   //link webloginPersonAccount to parent customerPersonAccount
        
        
        
        if ( FirstName == null || FirstName.length() == 0) { 
            webloginContact.FirstName = fac.Account__r.FirstName;
        } else {
            webloginContact.FirstName = FirstName;
        }
        
        if ( LastName == null || LastName.length() == 0) { 
            webloginContact.LastName = fac.Account__r.LastName;
        } else {
            webloginContact.LastName = LastName;
        }
        
        
        if ( CompanyName == null || CompanyName.length() == 0) { 
            webloginContact.Web_CompanyName__c = fac.Account__r.Name;
        } else {
            webloginContact.Web_CompanyName__c = CompanyName;
        }
        
        webloginContact.Email = managementEmail;
        webloginContact.Web_UserId__c = userName;

        if (String.IsBlank(webloginContact.LastName)) {
            webloginContact.LastName = String.IsBlank(webloginContact.Web_CompanyName__c) 
                ? 'Business' 
                : webloginContact.Web_CompanyName__c
            ;
        }
        
        insert webloginContact;

        //touch account
        //acct.Community_Contacts__c = acct.Community_Contacts__c == null ? 1 : (acct.Community_Contacts__c + 1);
        //update acct;
        
        return webloginContact;
    }
    
    private Contact UpdateWebloginContact(Contact matchingContact, String SGUID, String FinancialAccountNumber, String FinancialAccountBorrowerNumber, 
        String managementEmail, String userName, String FirstName, String LastName, String CompanyName) {

        
        //find the FA
        List<Financial_Account__c> faList = [
            select id
            from Financial_Account__c
            where Financial_Account_Number__c = :FinancialAccountNumber
        ];
        
        if (faList.size()  <> 1) {
            return null;
        }
        
        Id financialAccountId = faList[0].Id;
        
        //find the FAC now
        List<Financial_Account_Customer__c> facList = [
            select id, Account__c, Account__r.FirstName, Account__r.LastName, Account__r.Name
            from Financial_Account_Customer__c
            where Financial_Account__c = :financialAccountId
            and Customer_Borrower_Number__c = :FinancialAccountBorrowerNumber
        ];
        
        if (facList.size() <> 1) {
        	System.debug('****unable to find fac - data problem.');
            //cannot find the customerPersonAccount - data problem
            return null;
        }

        TFSC_CommunityAccountUtil autil = new TFSC_CommunityAccountUtil();
        
        //found Account id of Customer Person Account, firstname, lastname and companyname
        Financial_Account_Customer__c fac = facList[0]; 
        
        Contact webloginContact = matchingContact;
        //webloginContact.recordTypeId = RecordTypeModel.ContactWebLoginRecTypeId;
        //webloginContact.AccountId = autil.acctId; //already set when shell case contact is created
        webloginContact.RecordTypeId = Contact.SObjectType.getDescribe().getRecordTypeInfosByName().get('Weblogin').getrecordTypeId();
        webloginContact.SGUID__c = SGUID; 
        
        webloginContact.CustomerPersonAccount__c = fac.Account__c;   //link webloginPersonAccount to parent customerPersonAccount
        
        
        
        if ( FirstName == null || FirstName.length() == 0) { 
            webloginContact.FirstName = fac.Account__r.FirstName;
        } else {
            webloginContact.FirstName = FirstName;
        }
        
        if ( LastName == null || LastName.length() == 0) { 
            webloginContact.LastName = fac.Account__r.LastName;
        } else {
            webloginContact.LastName = LastName;
        }
        
        
        if ( CompanyName == null || CompanyName.length() == 0) { 
            webloginContact.Web_CompanyName__c = fac.Account__r.Name;
        } else {
            webloginContact.Web_CompanyName__c = CompanyName;
        }
        
        webloginContact.Email = managementEmail;
        webloginContact.Web_UserId__c = userName;

        if (String.IsBlank(webloginContact.LastName)) {
            webloginContact.LastName = String.IsBlank(webloginContact.Web_CompanyName__c) 
                ? 'Business' 
                : webloginContact.Web_CompanyName__c
            ;
        }
        
        update webloginContact;

        //touch account
        //acct.Community_Contacts__c = acct.Community_Contacts__c == null ? 1 : (acct.Community_Contacts__c + 1);
        //update acct;
        
        return webloginContact;
    }
   
    
    /* Commented 5/6 by Brandon Schoen as this is a artifact replaced by JIT since go-live and not able to be covered by unit tests
    
    //called in future call to avoid mixed dml restriction when inserting a personaccount and user in one ine of execution.
    @future 
    private  static void createPersonAccountUser(id webloginContactId) {
        Contact webloginContact = [
            Select Id,FirstName, LastName, SGUID__c, Web_CompanyName__c, Web_UserId__c, Email  
            from Contact 
            where id =:webloginContactId
        ];
        createPersonAccountUser(webloginContact.Id, webloginContact.FirstName, webloginContact.LastName, webloginContact.Web_UserId__c, webloginContact.Email, webloginContact.SGUID__c);   
    }
     
    private static void createPersonAccountUser(id personContactId, string first, string last, string aliasName, string managementEmail, string FedId) {
        Profile communityProfile = [select Id from Profile where name = 'TMCC Customer Community Login User'];
        

        string communityAlias = last+'_'+Rnd();
        
        //if ( aliasName.length() > 8) {
        //    aliasName = aliasName.substring(0,8);
        //}
        
        String SGUIDUserName = FedId;
        //elminate @ 
        SGUIDUserName = SGUIDUserName.replaceAll('@', '');
        SGUIDUserName = SGUIDUserName+'@tfs.com';
        
        User newUser = new User(
            contactId = personContactId,
            //username = managementEmail,
            username = SGUIDUserName,       // <-- use SGUID@tfs.com as user name to avoid problem with reusing email id.
            firstname = first,
            lastname = last,
            email = managementEmail,
            communityNickname = communityAlias,
            alias = Rnd().substring(0, 8),
            WebLogin_Username__c = aliasName, //custom field, aliasName cannot be trimmed
            FederationIdentifier = FedId,
            profileid = communityProfile.Id,
            emailencodingkey='UTF-8',
            languagelocalekey='en_US',
            localesidkey='en_US',
            timezonesidkey='America/Los_Angeles');
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;
        dmo.AllowFieldTruncation = true;
        newUser.setOptions(dmo);
        insert newUser;
        //Database.insert(newUser, dmo);
    }
    
    private static string Rnd() {
        //return String.valueOf(Math.random() * 100000);
        return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    }*/
    
    
    private WebLoginWebServiceReply reactivateExistingWebLoginUser(User webloginUser) {
        if ( !webloginUser.isActive) {
            webloginUser.isActive = true;
            update webloginUser;
        }
        
        return new WebLoginWebServiceReply(0,
            'TFSC_Weblogin_Provision - reactivated weblogin PersonAccount for webloginUser '+webloginUser.name); 
        
    }
}