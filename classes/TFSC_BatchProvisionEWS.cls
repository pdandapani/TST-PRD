global class TFSC_BatchProvisionEWS implements Database.Batchable<SObject> {
	
	final Id communityProfileId;
	final Database.DMLOptions dmlOpts;

	global String query = 
    	'select ' +
    		'Id, ' + 
    		'Contact__c, ' +
    		'Contact__r.FirstName, ' +
    		'Contact__r.LastName, ' +
    		'Contact__r.Email, ' +
    		'Contact__r.SGUID__c, ' +
    		'Contact__r.Web_UserId__c ' +
    	'from EWS_Account__c ' +
    	'where Contact__c != null ';

    global TFSC_BatchProvisionEWS() {

    	if (Test.isRunningTest()){
    		query = query + ' limit 10';
    	}

    	//this had better be preent
    	communityProfileId = [select Id from Profile where Name = 'TMCC Customer Community Login User'].Id;

		dmlOpts = new Database.DMLOptions();
        dmlOpts.EmailHeader.TriggerUserEmail = false; //do not send an email from us
        dmlOpts.AllowFieldTruncation = true; //let the random strings get trimmed

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    

    global void execute(Database.BatchableContext BC, List<EWS_Account__c> accts) {

    	//loop though the contact ids, and filter out those that already have a user
    	Map<Id,EWS_Account__c> goodAccts = new Map<Id,EWS_Account__c>{};
    	for (EWS_Account__c acct : accts) {
    		goodAccts.put(acct.Contact__c, acct);
    	}

    	//are there any users with one of those contact ids?
    	Set<Id> usedContactIds = new Set<Id>{};
    	for (User u : [select ContactId from User where ContactId in :goodAccts.keySet()]) {
    		usedContactIds.add(u.Id);
    	}

    	//filter out accounts with contacts that already have a user
    	for (Id contactId : goodAccts.keySet()) {
    		if (usedContactIds.contains(contactId)) {
    			goodAccts.remove(contactId);
    		}
    	}

    	//if none of the accounts have unused contacts just return
    	if (goodAccts.isEmpty()) return;

    	//make a user for each contact, and update the acct with its Id
    	List<User> users = new List<User>{};
    	for (EWS_Account__c acct : goodAccts.values()) {

    		User u = new User(
				ContactId = acct.Contact__c,
	            Username = acct.Contact__r.SGUID__c.replaceAll('@', '') + '@tfs.com', // <-- use SGUID@tfs.com as user name to avoid problem with reusing email id.
	            FirstName = acct.Contact__r.FirstName,
	            LastName = acct.Contact__r.LastName,
	            Email = acct.Contact__r.Email,
	            CommunityNickname = acct.Contact__r.LastName + '_' + randomString(),
	            Alias = randomString(),
	            WebLogin_Username__c = acct.Contact__r.Web_UserId__c, //custom field, aliasName cannot be trimmed
	            FederationIdentifier = acct.Contact__r.SGUID__c,
	            Profileid = communityProfileId,
	            EmailEncodingKey = 'UTF-8',
	            LanguageLocaleKey = 'en_US',
	            LocaleSidKey = 'en_US',
	            TimezoneSidKey = 'America/Los_Angeles'
			);
			u.setOptions(dmlOpts);

			users.add(u);

    	}

    	if (!users.isEmpty()) {
			//dont let one bad user spoil the batch
			Database.insert(users, false);
		}

    }

    global void finish(Database.BatchableContext BC){

	}

	private static string randomString() {
        return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    }
	
	//TFSC_BatchMigrateEWS.runNow(); //beautiful!
	public static Id runNow(){
    	return runNow(200);
	}

	//system will throw error if scopeSize not in range 1...2000
	public static Id runNow(Integer scopeSize) {
        return Database.executeBatch(new TFSC_BatchProvisionEWS(), scopeSize);
	}

}