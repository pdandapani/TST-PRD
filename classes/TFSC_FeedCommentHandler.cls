public class TFSC_FeedCommentHandler implements TFSC_TriggerDispatcher.Handler {

	public void handle() {	
		System.Debug('TFSC_FeedCommentHandler::handle   size='+trigger.new.size());
		processChatterFeedItemsForKnowledgeManagement((List<FeedComment>)trigger.new);
	}

	private void processChatterFeedItemsForKnowledgeManagement(List<FeedComment> feedComments) {
		
		if (!PermissionSetModel.hasStandaloneKnowledgePermissionSet()) {
			return;
		}
		
		//1 - find a list of FeedItem & parent id
		List<Id> feedItemIdList = New List<Id>();
		for(FeedComment fc : feedComments) {
			if ( !PermissionSetModel.hasKnowledgeAdminPermissionSet()) {
				feedItemIdList.add(fc.FeedItemId);
			}
		}
		
		List<FeedItem> itemList = [
			select id, parentId
			from FeedItem
			where id in :feedItemIdList
		];
		
		System.Debug('processChatterFeedItemsForKnowledgeManagement found itemList '+
			itemList.size());
		
		Map<Id, Id> mapFeedItemParentId = new Map<Id, Id>();
		for(FeedItem item : itemList) {
			//filter just 
			if (  item.ParentId != null && ArticleFeedbackModel.getArticleType(item.ParentID) != null ) {
				mapFeedItemParentId.put(item.id, item.ParentId);
			} else {
				System.Debug('processChatterFeedItemsForKnowledgeManagement - parent id is not an article' +
					item.ParentId);
			}
		}
		
		Map<Id, ArticleFeedbackModel.kavDetails> kavDetailsMapByKaId  =
			ArticleFeedbackModel.FindKnowledgeArticleDetails(mapFeedItemParentId.Values());
		
		//
		List<Km_Chatter_Log__c> chatterLogList = new List<Km_Chatter_Log__c>();
		for(FeedComment fc : feedComments) {
			if (mapFeedItemParentId.containsKey(fc.FeedItemId) ) {
				Km_Chatter_Log__c chatterLog = new Km_Chatter_Log__c();
				
				
				if ( fc.CommentBody.length() < 255) {
					chatterLog.ChatterText__c = fc.CommentBody;
				} else {
					chatterLog.ChatterText__c = fc.CommentBody.substring(0,254);
				}
				if ( fc.CommentBody.containsIgnoreCase('#feedback')) {
					chatterLog.Has_Feedback_Tag__c = true;
				} else {
					chatterLog.Has_Feedback_Tag__c = false;
				}
				
				Id feedItemId = fc.FeedItemId;
				Id kaId = mapFeedItemParentId.get(feedItemId);
				if (kavDetailsMapByKaId.containsKey(kaId)) {
					ArticleFeedbackModel.kavDetails kavDetail = kavDetailsMapByKaId.get(kaId);
					
					chatterLog.kavId__c = kavDetail.knowledgeArticleVersionId;
					chatterLog.articleType__c = kavDetail.articleType;
					chatterLog.articleNumber__c = kavDetail.articleNumber;
					chatterLog.versionNumber__c = kavDetail.versionNumber;
					chatterLog.articleTitle__c = kavDetail.articleTitle;  
				}
				
				chatterLogList.add(chatterLog);
				
			}
		}	
		 
		if ( chatterLogList.size() > 0) {
			insert chatterLogList;
		}
	}
	
	
	
	
}