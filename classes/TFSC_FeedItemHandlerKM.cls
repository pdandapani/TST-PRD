public without sharing class TFSC_FeedItemHandlerKM {
	public void processChatterFeedItemsForKnowledgeManagement(List<FeedItem> feedItems) {
		
		if (!PermissionSetModel.hasStandaloneKnowledgePermissionSet()) {
			return;
		}
		
		//1. create case for chatter post with #feedback topic
        Map<Id, ArticleFeedbackModel.kavDetails> kavDetailsMapByKaId = createArticleFeedbackCase();
        
        //2. create records in knowledgeArticleChatterLog with optional link to case
        List<Km_Chatter_Log__c> chatterLogList = new List<Km_Chatter_Log__c>();
        for(FeedItem item : feedItems) {
			if (item.ParentId != null && ArticleFeedbackModel.getArticleType(item.ParentID) != null) {
				//we have a feedItem on an knowledge article
				Km_Chatter_Log__c chatterLog = new Km_Chatter_Log__c();
				
				if ( item.Body.length() < 255) {
					chatterLog.ChatterText__c = item.body;
				} else {
					chatterLog.ChatterText__c = item.body.substring(0,254);
				}
				if ( item.Body.containsIgnoreCase('#feedback')) {
					chatterLog.Has_Feedback_Tag__c = true;
				} else {
					chatterLog.Has_Feedback_Tag__c = false;
				}
				
				if ( kavDetailsMapByKaId.containsKey(item.parentId)) {
					ArticleFeedbackModel.kavDetails kavDetail = kavDetailsMapByKaId.get(item.parentId);
					
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
        
        //3. scan and delete attachments in Chatter feed for article -> then create case.
        //   feeditem cannot be updated. 
        //   So a new chatter item with same text will be created with same text and an explanation about the moved attachment.
        
	}
	
	
	
	private Map<Id, ArticleFeedbackModel.kavDetails> createArticleFeedbackCase(){
		String feedbackCaseRecTypeId = RecordTypeModel.LookupRecordTypeId('Case', 'Article_Feedback');
		
		Map<Id,Case> feedbackCases = new Map<Id,Case>();
        Map<Id,FeedItem> feedbackScopeMap = new Map<Id,FeedItem>();
        
        Map<Id,ArticleFeedbackModel.kavDetails> articleDetailsMap = new Map<Id,ArticleFeedbackModel.kavDetails>();
        
        for(FeedItem item : (List<FeedItem>)trigger.new){
            System.debug('************* FeedItem Details: ' + item);
            
            //check if FeedItem is attached to a Knowledge Article
            
            if( item.ParentId != null && ArticleFeedbackModel.getArticleType(item.ParentID) != null ){
                feedbackScopeMap.put(item.ParentId,item);
                System.debug('*************** FeedItem' + item.id + 'added to processing scope');
            } 
        }
        
        List<Id> knowledgeArticleIdList = new List<Id>();
        knowledgeArticleIdList.addAll(feedbackScopeMap.keySet());
        System.debug('************* Processing scope size: ' + feedbackScopeMap.size());
        
        Map<Id, ArticleFeedbackModel.kavDetails> kavDetailsMap = ArticleFeedbackModel.FindKnowledgeArticleDetails(knowledgeArticleIdList);
        
        if(kavDetailsMap != null && !kavDetailsMap.isEmpty()){
           for(FeedItem item : feedbackScopeMap.values()) {
           	
           		if ( item.Body.containsIgnoreCase('#feedback')) {
           			//item has a #feedback -> create a case
	           		ArticleFeedbackModel.kavDetails parent = kavDetailsMap.get(item.ParentId);
	           		
	           		Case articleFeedbackCase = new Case();
	           		articleFeedbackCase.RecordTypeId = feedbackCaseRecTypeId;
	           		articleFeedbackCase.Origin = 'Article Feedback' ;
	           		articleFeedbackCase.Status = 'New' ;
	           		articleFeedbackCase.Description = item.Body ;
	           		articleFeedbackCase.Subject = ('Feedback for Article ' + parent.articleNumber) ;
	           		articleFeedbackCase.Article_Feedback_Provided_By__c = item.CreatedById ;
	           		articleFeedbackCase.Article_Title__c = parent.articleTitle ;
	           		articleFeedbackCase.Article_URL__c = parent.knowledgeArticleVersionId ;
	           		articleFeedbackCase.Article_ID__c = item.ParentId ;
	           		articleFeedbackCase.Article_Number__c = parent.articleNumber ;
	           		
	           		//item 4d,4e,4f from Ben Moore's email on Mar 4th, 2015 
	           		articleFeedbackCase.SuppliedEmail = UserInfo.getUserEmail();
		           	articleFeedbackCase.SuppliedName = UserInfo.getName();
	           		User currentUser = findCurrentUser(UserInfo.getUserId());
	           		if ( currentUser <> null) {
		           		articleFeedbackCase.SuppliedPhone = currentUser.phone;
	           		}
	           		
					feedbackCases.put(item.ParentId,articleFeedbackCase);
           		} else {
           			System.Debug('item.Body does not contains #feedback  '+ item.Body);
           		}
			} 
        }
		
		
		System.debug('*************** feedbackCases size: ' + feedbackCases.size() + ' ~ feedbackCases IDs: ' + feedbackCases.keySet());
		if (!feedbackCases.isEmpty()){
			//http://developer.force.com/cookbook/recipe/running-case-assignment-rules-from-apex
			//Fetching the assignment rules on case

			AssignmentRule AR = [
				select id from AssignmentRule 
				where SobjectType = 'Case' and Active = true limit 1
			];
			
			//Creating the DMLOptions for "Assign using active assignment rules" checkbox
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
			
			List<Case> newCases = feedbackCases.values();
			for(Case newCase : newCases) {
				newCase.setOptions(dmlOpts);
			}
			insert newCases;
			
			boolean debug = true;
			if ( debug ){
				Case myCase = [
					select id, RecordType.name, owner.name, ownerId
					from case 
					where id = :newCases[0].id
				];
				System.Debug('**********************   case reordtype : '+ myCase.RecordType.name+'   '+ myCase.owner.name);
			}
			
		} 
		
		return kavDetailsMap;
	}
	
	public static User findCurrentUser(Id userId) {
		List<User> users = [
			select Email, Name, Phone
			from user
			where id = :userId
		];
		
		if (users.size() == 1) {
			return users[0];
		} else {
			return null;
		}
	}

}