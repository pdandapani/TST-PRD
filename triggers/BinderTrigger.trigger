trigger BinderTrigger on Binder__c (before delete) {

	//bulkify
	List<id> bindersToDel = new List<id>();
	for(Binder__c binder : Trigger.old) {
		bindersToDel.add(binder.id);
	}
	

	List<BinderPage__c> binderPages = [select id from BinderPage__c where Binder__c in :bindersToDel];
	delete binderPages;

}