/**
* @author: Salesforce Services
* @date:    2014-08-06
* @description: Helper class for the TFSC_CaseTrigger trigger
*               
* @log:
* -----------------------------------------------------------------------------
*    Developer                    Date                Description
* -----------------------------------------------------------------------------
*    Scott W	                2014-08-06          creation
*   
*/
public with sharing class TFSC_WebToCaseHandler implements TFSC_TriggerDispatcher.Handler {
	
	//static final Id DEFAULT_PERSON_ID = WebToCase_Settings__c.getInstance().Dummy_PersonId__c;
	static final Id RTID_COMMACCT = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Community Account').getRecordTypeId();
	static final Id RTID_WEBTOCASE = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Web-To-Case').getRecordTypeId();

	public void handle() {
		associateCaseToCommunityAccount(trigger.new);
		copyFACFieldsToCases(trigger.new);
	}
	
	/**
	 * Bulk method, for a given Case, if the RecordType is not 'Web-To-Case'
	 * then copy
	 *
	 * @param  newCases List of new Cases, ie trigger.new
	 * @return void
	 */
	private void copyFACFieldsToCases(List<Case> newCases) {
		Map<id,Case> facIdToCaseMap = new Map<id,Case>();
		for(Case c : newCases) {
			system.debug('***case fac is '+c.Financial_Account_Customer__c);
			if (c.RecordTypeId != RTID_WEBTOCASE && c.Financial_Account_Customer__c != null) {
				facIdToCaseMap.put(c.Financial_Account_Customer__c, c);
			}
		}
		
		//List<Financial_Account_Customer__c> caseFacs = ;
		for(Financial_Account_Customer__c fac : [
			select Id, Financial_Account_Customer__c 
			from Financial_Account_Customer__c 
			where Id in :facIdToCaseMap.keyset()
		]) {
			if (facIdToCaseMap.containsKey(fac.Id)) {
				Case facCase = facIdToCaseMap.get(fac.Id);
				system.debug('***case fac is still '+facCase.Financial_Account_Customer__c);
				system.debug('***setting to  '+fac.Financial_Account_Customer__c);
				facCase.Financial_Account_Customer_ID__c = fac.Financial_Account_Customer__c;
			}
		}
	}

	/**
	 * Bulk method, for a given Case, if the RecordType is 'Web-To-Case'
	 * then assign the ParentId to a community account
	 *
	 * @param  newCases List of new Cases, ie trigger.new
	 * @return void
	 */
	private void associateCaseToCommunityAccount(List<Case> newCases) {

		List<Case> webToCase = new List<Case>{};

		for(Case c : newCases) {
			//only deal with web-to-case type Cases
			if (c.RecordTypeId == RTID_WEBTOCASE) {
				webToCase.add(c);
			}
		}

		if (!webToCase.isEmpty()) {

			//wait to pull these, majority of cases are not web-to-case and dont need
			//this overhead. no need to grab more than the batch size.  as the next trigger
			//fires an new set will sort to the top. in reality only 1 case of this
			//type will probably ever come in at a time.
			//List<Account> commAccts = new List<Account>([
			//	select Id, WebToCase_Cases__c
			//	from Account
			//	where RecordTypeId = :RTID_COMMACCT
			//	order by WebToCase_Cases__c nulls first
			//	limit :webToCase.size()
			//]);
			TFSC_WebToCaseAccountUtil wutil = new TFSC_WebToCaseAccountUtil();

			//if (!commAccts.isEmpty()) {
				
				//Map<Id,Account> accts = new Map<Id,Account>{};
				//Integer i = 0;
				//Integer j = commAccts.size();

				for (Case c : webToCase) {
					//loop through the community accounts and increment the 
					//count each time it gets assigned to a case.
					//Account acct = commAccts[i++];
					//acct.WebToCase_Cases__c = acct.WebToCase_Cases__c == null ? 1 : (acct.WebToCase_Cases__c + 1);
					//accts.put(acct.Id, acct);
				
					c.ContactId = null; //nullify contact
					c.AccountId = wutil.acctId;

					//if (i == j) {
					//	i = 0;
					//}

				}

				//update accts.values();

			//}

		}

	}

}