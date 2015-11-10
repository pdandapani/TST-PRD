public without sharing class TFSC_WebToCaseAccountUtil {

	private final Integer MAX_SIZE = 10000;
	private final Id RTID_WTCACCT = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Web-To-Case Account').getRecordTypeId();
	
	private Account acct;

	public Id acctId { get { return acct.Id; } }

	public TFSC_WebToCaseAccountUtil() {

		//get the newest community account
		List<Account> accts = new List<Account>([
			select Id 
			from Account 
			where RecordTypeId = :RTID_WTCACCT
			order by CreatedDate 
			limit 1
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
			'select count() from Case where AccountId = :acctId'
		);
		if (contactSize >= MAX_SIZE) {
			createNewAccount();
		}

	}

	private void createNewAccount() {
		insert (this.acct = new Account(
			Name = 'Web-To-Case Account ' + System.now().formatGmt('YYYYMMdd'),
			RecordTypeId = RTID_WTCACCT
		));
	}

}