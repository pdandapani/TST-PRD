public without sharing class TFSC_FeedItemHandler implements TFSC_TriggerDispatcher.Handler {
	
	private static final String CASE_PREFIX = Case.SObjectType.getDescribe().getKeyPrefix();

	public void handle() {	
		//created by Scott Will on Community project to update the Parent Case
		updateParentCase();	
		
		TFSC_FeedItemHandlerKM handleKM = new TFSC_FeedItemHandlerKM();
		handleKM.processChatterFeedItemsForKnowledgeManagement((List<FeedItem>)trigger.new);
	}
	

	//created by Scott Will on Community project to update the Parent Case
	private void updateParentCase() {

		Map<Id,Case> cases = new Map<Id,Case>{};
		for(FeedItem item : (List<FeedItem>)trigger.new) {
			if (item.ParentId != null && ((String)item.ParentId).startsWith(CASE_PREFIX)) {
				cases.put(item.ParentId, new Case(Id = item.ParentId));
			}
		}

		if (!cases.isEmpty()) {
			update cases.values();
		}

	}
	
}