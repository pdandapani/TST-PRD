public without sharing class TFSC_CollectionsCaseHandler implements TFSC_TriggerDispatcher.Handler{

	private static final String COLLECTION_REC_TYPE = RecordTypeModel.LookupRecordTypeId('Case', 'Collection');

	public void handle(){

		System.debug('******************* Beginning TFSC_CollectionsCaseHandler.handle() *******************');

		updateFinancialAccountRecourseCode((List<Case>)trigger.new);

	}


	private void updateFinancialAccountRecourseCode(List<Case> cases){

		Map<Id,Financial_Account__c> financialAccountsMap = new Map<Id,Financial_Account__c>();

		System.debug('******************* # of Cases: ' + cases.size() + ' ~ Case FA: ' + cases.get(0).Financial_Account__c + ' ~ Case RecordType: ' + cases.get(0).RecordTypeId + ' ~ Recourse Code: ' + cases.get(0).Collection_Recourse_Code__c);

		for(Case c : cases){

			if(c.Financial_Account__c != null && c.RecordTypeId == COLLECTION_REC_TYPE && c.Collection_Recourse_Code__c != null){

				System.debug('****************** Case recourse code: ' + c.Collection_Recourse_Code__c);

				financialAccountsMap.put(c.Financial_Account__c, new Financial_Account__c(
																						Id = c.Financial_Account__c,
																						Collection_Recourse_Code__c = c.Collection_Recourse_Code__c));

			}

		}

		System.debug('******************* # of FAs to update: ' + financialAccountsMap.size());

		if(!financialAccountsMap.isEmpty()){

			System.debug('****************** Updating recourse code on financial account');

			update financialAccountsMap.values();

		}

	}


}