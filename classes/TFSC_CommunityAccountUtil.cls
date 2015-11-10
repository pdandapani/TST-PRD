public without sharing class TFSC_CommunityAccountUtil {

	private final Integer MAX_SIZE = 10000;
	private final Id RTID_COMMACCT = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Community Account').getRecordTypeId();
	
	private Account acct;

	public Id acctId { get { return acct.Id; } }

	//find the newest community account.  if it does not exist, or it has too
	//many contacts, then create a new community account to use instead
	public TFSC_CommunityAccountUtil() {

		//get the newest community account
		//Added limit 10 with support's feedback that limit 1 caused CreatedDate to tableScan. limit 10 uses proper RecordTypeId index
		List<Account> accts = new List<Account>([
			select Id 
			from Account 
			where RecordTypeId = :RTID_COMMACCT
			order by CreatedDate 
			limit 10
		]);

		//add an account if none are present yet
		if (accts.isEmpty()) {
			createNewAccount();
		}
		else {
			this.acct = accts[0];
		}

		Id acctId = acct.Id;
		Integer contactSize= Database.countQuery(
			'select count() from Contact where AccountId = :acctId'
		);
		if (contactSize >= MAX_SIZE) {
			createNewAccount();
		}

	}

	private void createNewAccount() {
		insert (this.acct = new Account(
			Name = 'Community Account ' + System.now().formatGmt('YYYYMMdd'),
			RecordTypeId = RTID_COMMACCT
		));
	}

}