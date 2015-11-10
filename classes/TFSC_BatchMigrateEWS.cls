global class TFSC_BatchMigrateEWS implements Database.Batchable<SObject> {

    final Id RECTYPE_WEBLOGIN = Contact.SObjectType.getDescribe().getRecordTypeInfosByName().get('Weblogin').getrecordTypeId();
    final Id RTID_COMMACCT = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Community Account').getRecordTypeId();

    //final String ERR_SGUID_IN_USE = 'SGUID already in use.';
    final String ERR_CANNOT_FIND_FA = 'Cannot find Financial Account.';
    final String ERR_CANNOT_FIND_FAC = 'Cannot find Financial Account Customer with matching borrower type.';
    final String ERR_CANNOT_ASSOC_FAC = 'Error associating contact to located Financial Account Customer';
    

    //public String SOQL = 'select id,name from EWS_User__c ';
    global String query = 
        'select ' +
            'Id, ' + 
            'Contact__c, ' +
            'FA_Role__c, ' + 
            'FA_Num__c, ' + 
            'SGUID__c, ' +
            'EWS_User__r.AcctMgmtEmail__c, ' + 
            'EWS_User__r.User_Id__c ' +
        'from EWS_Account__c ' +
        'where Contact__c = null and Last_Error__c = null';
        
    // Benjamin added FA_Num__c as a partition key to allow parallel batch execution
    public TFSC_BatchMigrateEWS(String key, Integer batchLimit) {
        if (Test.isRunningTest()){
            query = query + ' limit 10';
        } else {
        	query = query + ' and FA_Num__c >=  \''+ key + '\' limit '+batchLimit;
        }
        system.debug(query);

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<EWS_Account__c> ewsaccts){

        //contains any "error", or invalidation of the record to save back to record
        Map<Id,String> lastErrors = new Map<Id,String>{};

        //get unique set of SGUIDs
        Map<String,List<EWS_Account__c>> goodAccts = new Map<String,List<EWS_Account__c>>{};
        for (EWS_Account__c acct : ewsaccts) {
            //only add the first acct if there are duplicate SGUIDs in the scope
            if (goodAccts.containsKey(acct.SGUID__c)) {
                goodAccts.get(acct.SGUID__c).add(acct);
            }
            else {
                goodAccts.put(acct.SGUID__c, new List<EWS_Account__c> { acct });
            }
        }

        //are there any contacts/users with one of those SGUIDs?
        Map<String,Id> usedSguids = new Map<String,Id>{};

        for (Contact c : [select SGUID__c from Contact where SGUID__c in :goodAccts.keySet()]) {
            usedSguids.put(c.SGUID__c, c.Id);    
        }

        //now check for good FAs and FACs
        Map<String,Financial_Account__c> finAccts = new Map<String,Financial_Account__c>{};// financial account numbers
        Map<Id,Financial_Account_Customer__c> finAcctCusts = new Map<Id,Financial_Account_Customer__c>{};
        for (List<EWS_Account__c> accts : goodAccts.values()) {
            for (EWS_Account__c acct : accts) {
                finAccts.put(acct.FA_Num__c, null);
            }
        }

        //build a map of associated FAs
        for (Financial_Account__c finAcct : [
            select Id, Name, (
                select Id, Account__c, Customer_Borrower_Number__c, Borrower_Status__c, Account__r.FirstName, Account__r.LastName, Account__r.Name
                from Financial_Account_Customers__r
            )
            from Financial_Account__c
            where Name in :finAccts.keySet()
        ]) {
            finAccts.put(finAcct.Name, finAcct);
            for (Financial_Account_Customer__c fac : finAcct.Financial_Account_Customers__r) {
                finAcctCusts.put(fac.Id, fac);
            }
        }

        Map<String,Contact> newContacts = new Map<String,Contact>{};
        Map<Id,String> facid2sguid = new Map<Id,String>{}; //maps the FAC ID to the matching Contact's SGUID
        Map<Id,Id> facid2existingContactId = new Map<Id,Id>{}; //maps the contacts associations to existing contacts for FAC assignments

        TFSC_CommunityAccountUtil autil = new TFSC_CommunityAccountUtil();

        Map<Id,EWS_Account__c> updatedAccts = new Map<Id,EWS_Account__c>{};
        Map<Id,Financial_Account_Customer__c> updatedFacs = new Map<Id,Financial_Account_Customer__c>{};
        //make sure each acct has a valid FA/FAC combo
        for (List<EWS_Account__c> accts : goodAccts.values()) {
            for (EWS_Account__c acct : accts) {

                Financial_Account__c finAcct = finAccts.get(acct.FA_Num__c);
                if (finAcct != null) {
                    //loop thru the FACs, make sure there is one with a matching borrower number
                    Id facId = null;
                    for (Financial_Account_Customer__c fac : finAcct.Financial_Account_Customers__r) {
                        //does the borrower type match?
                        if (fac.Customer_Borrower_Number__c == acct.FA_Role__c && fac.Borrower_Status__c != 'Inactive') {
                            facId = fac.Id;
                            break;
                        }
                    }

                    //if there is a good FA/FAC combo we can make a contact
                    if (facId != null && finAcctCusts.containsKey(facId)) {

                        Financial_Account_Customer__c fac = finAcctCusts.get(facId);

                        facid2sguid.put(fac.Id, acct.SGUID__c);

                        Id contactId = usedSguids.get(acct.SGUID__c);
                        if (contactId == null) {
                        	String contactLastName = fac.Account__r.LastName;
                        	
                    	    if (String.IsBlank(contactLastName)) {
						        contactLastName = String.IsBlank(fac.Account__r.Name) 
						            ? 'Business' 
						            : fac.Account__r.Name
						        ;
						    }
                        	
                            newContacts.put(acct.SGUID__c, new Contact(
                                RecordTypeId = RECTYPE_WEBLOGIN,
                                LastName = contactLastName,
                                FirstName = fac.Account__r.FirstName,
                                AccountId = autil.acctId,
                                Web_CompanyName__c = fac.Account__r.Name,
                                Email = acct.EWS_User__r.AcctMgmtEmail__c,
                                Web_UserId__c = acct.EWS_User__r.User_Id__c,
                                SGUID__c = acct.SGUID__c,
                                CustomerPersonAccount__c = fac.Account__c
                            ));
                        }
                        else {
                            //bind to existing contact
                            acct.Contact__c = contactId;
                            fac.Weblogin_Contact__c = contactId;
                            facid2existingContactId.put(fac.Id, contactId);
                        }

                        updatedAccts.put(acct.Id, acct);
                        updatedFacs.put(fac.Id, fac);
                    }
                    else {
                        lastErrors.put(acct.Id, ERR_CANNOT_FIND_FAC);
                    }
                }
                else {
                    lastErrors.put(acct.Id, ERR_CANNOT_FIND_FA);
                }

            }

        }

        //no contacts so let's get out of here
        if (!updatedFacs.IsEmpty()) {
        	if (!newContacts.isEmpty()) {
            	Database.insert(newContacts.values(), false); //null ids will add lasterror in fac binding method
        	}

            //go back to the EWS Accts & FACs that were referenced and update them with the contact's id
            for(Contact newcon : newContacts.values()) {
                //bind the EWS Account and Contact
                for (EWS_Account__c acct : goodAccts.get(newcon.SGUID__c)) {
                    if (!lastErrors.containsKey(acct.Id)) {
                        acct.Contact__c = newcon.Id;
                        updatedAccts.put(acct.Id, acct);
                    }
                }
            }
            
            for(id facIdToUpdate : facid2sguid.keyset()) {
            	//bind the FAC and Contact
                Financial_Account_Customer__c fac = finAcctCusts.get(facIdToUpdate);
                if (newContacts.containsKey(facid2sguid.get(facIdToUpdate))) { //is new contactId
                	fac.Weblogin_Contact__c =  newContacts.get(facid2sguid.get(facIdToUpdate)).Id;
                	updatedFacs.put(fac.Id, fac);
                } else if (facid2existingContactId.containsKey(facIdToUpdate)) { 
                	fac.Weblogin_Contact__c = facid2existingContactId.get(facIdToUpdate);
                	updatedFacs.put(fac.Id, fac);
                } else {
                	string contactSguid = facid2sguid.get(facIdToUpdate);
                	if (goodAccts.containsKey(contactSguid)) {
		              	for (EWS_Account__c acct : goodAccts.get(contactSguid)) {
	                		lastErrors.put( acct.Id, ERR_CANNOT_ASSOC_FAC);
	                	}
                	}
                }
            }
            
            
        }
		Database.update(updatedAccts.values(), false);
		Database.update(updatedFacs.values(), false);

        //save errors
        if (!lastErrors.isEmpty()) {
            List<EWS_Account__c> badAccts = new List<EWS_Account__c>{};
            for (Id badId : lastErrors.keySet()) {
                badAccts.add(new EWS_Account__c(
                    Id = badId,
                    Last_Error__c = lastErrors.get(badId)
                ));
            }
			Database.update(badAccts, false);
        }

    }
    
    
 //   public static void migrateUser(EWS_User__c ewsUser) {
    //  List<EWS_Account__c>  accounts = [
    //      select id
    //      from EWS_Account__c
    //      where EWS_User__c = :ewsUser.id
    //  ];
        
    //  boolean provisioned = false;
    //  for(EWS_Account__c acct : accounts ) {
    //      if (provisioned) {
    //          //register
    //      } else {
    //          //provision - which will auto register
                
    //          provisioned = true;
    //      }
    //  }
                
    //}

    global void finish(Database.BatchableContext BC){
        //TFSC_BatchProvisionEWS.runNow();
    }

    //@future
    //public static void createCommunityUsers(Set<Id> contactIds) {

    //  Database.DMLOptions dmo = new Database.DMLOptions();
 //       dmo.EmailHeader.TriggerUserEmail = false; //do not send an email from us
 //       dmo.AllowFieldTruncation = true; //let the random strings get trimmed

 //       Profile communityProfile = [select Id from Profile where Name = 'TMCC Customer Community Login User'];

    //  List<User> users = new List<User>{};
    //  for(Contact con : [
    //      select Id, FirstName, LastName, Email, SGUID__c, Web_UserId__c
    //      from Contact
    //      where Id in :contactIds
    //  ]) {
            
    //      User u = new User(
    //          ContactId = con.Id,
    //            Username = con.SGUID__c.replaceAll('@', '') + '@tfs.com', // <-- use SGUID@tfs.com as user name to avoid problem with reusing email id.
    //            FirstName = con.FirstName,
    //            LastName = con.LastName,
    //            Email = con.Email,
    //            CommunityNickname = con.LastName + '_' + randomString(),
    //            Alias = randomString(),
    //            WebLogin_Username__c = con.Web_UserId__c, //custom field, aliasName cannot be trimmed
    //            FederationIdentifier = con.SGUID__c,
    //            Profileid = communityProfile.Id,
    //            EmailEncodingKey = 'UTF-8',
    //            LanguageLocaleKey = 'en_US',
    //            LocaleSidKey = 'en_US',
    //            TimezoneSidKey = 'America/Los_Angeles'
    //      );
    //      u.setOptions(dmo);

    //      users.add(u);

    //  }

    //  if (!users.isEmpty()) {
    //      //dont let one bad user spoil the batch
    //      Database.insert(users, false);

    //  }

    //}

    //private static string randomString() {
 //       return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
 //   }
    
    //TFSC_BatchMigrateEWS.runNow('Key'); 
    //beautiful!
    public static Id runNow(String key, Integer batchLimit){
        return runNow(1000, key, batchLimit);
    }

    //system will throw error if scopeSize not in range 1...2000
    public static Id runNow(Integer scopeSize, String key, Integer batchLimit) {
        return Database.executeBatch(new TFSC_BatchMigrateEWS(key,batchLimit), scopeSize);
    }


}