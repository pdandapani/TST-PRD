global class ReusableContentKavModel {


	//ReusableContentKavModel.updateArticlesAssociatedWithThisContentTag('a00S0000004GgoMIAS')
	webservice static Id updateArticlesAssociatedWithThisContentTag(id reusableContentId) {	
		findReusableContentArticleForTag(reusableContentId);
		ReusableContentUpdateModel.UpdateArticlesByTag(reusableContentId);
		return reusableContentId;
	}

	webservice static Id reindexAllReusableContentTags() {	
		ReusableContentIndexBatch.runNow();
		return null;
	}  
	
	webservice static void startReusableContentIndexBatch(){
		ReusableContentIndexBatch.runNow();
	}

	//ReusableContentKavModel.findReusableContentArticleForTag('a00S0000004GgoMIAS');
	webservice static Id findReusableContentArticleForTag(id reusableContentId) {		
		
		// 1. delete all existing reusableContentArticleJuntion Records
		deleteReusableContentArticleJuntion(reusableContentId);
		
		// 2, define the search String
		//String searchKeyword =  '*TFS/LFS*';//'*Lemon*'; 
		Reusable_Content__c rc = [
			select id, Name
			from Reusable_Content__c
			where id = :reusableContentId
		];   
		
		//do not add * for the searchKeyword -- it is a contain method not a wild card match
		string searchKeyword = rc.Name;
	
		// 3. create a set of all reusableContentArticleJuntion records.
		List<ReusableContentKav__c> rckList = createReusableContentArticleJuntion(searchKeyword, reusableContentId);
		
		// 4. find if an rck has a draft version
		//    draft version may not have the content tag
		//    but the replacement process will avoid creating a draft version
		updateDraftVersionURL(rckList);
		
		return reusableContentId;
	}
	
	public static void updateDraftVersionURL(List<ReusableContentKav__c> rckList) {
		// 1. create a list of Knowledge Article Type in the rckList
		Set<String> kavApiNameSet = new Set<String>();
		for(ReusableContentKav__c rck : rckList ) {
			if (rck.Publish_Status__c == 'Online') {
				if (!kavApiNameSet.contains(rck.ArticleVersionTypeName__c) ) {
					String kavApiName = rck.ArticleVersionTypeName__c+'v';
					kavApiNameSet.add(kavApiName);
					System.Debug('updateDraftVersionURL found articleType : '+ kavApiName);
				}
			}
		}
		
		// 2. for each article version type 
		//      find all english draft
		List<ReusableContentKav__c> rckToUpdateList = new List<ReusableContentKav__c>();
		for (String kavApiName : kavApiNameSet ) {
			String soqlKav = 'select id, KnowledgeArticleId from '+ kavApiName + ' ' +
				'where PublishStatus = \'Draft\' and Language = \'en_US\'';
			List<SObject> kavObjs = Database.query(soqlKav);
			
			
			// put the KnowledgeArticleId__c and Id into a map for quick search
			Map<Id,id> kaIdDraftKavIdMap = new Map<Id,Id>();
			for (SObject kavObj : kavObjs) {
				
				Id knowledgeArticleId = (Id)kavObj.get('KnowledgeArticleId');
				Id draftId = (Id)kavObj.get('Id');
				
				kaIdDraftKavIdMap.put(knowledgeArticleId, draftId);
				
				System.Debug('kaIdDraftKavIdMap KnowledgeArticleId / DraftId : '+
					knowledgeArticleId +' : '+draftId);
			}
			
			// now check each Online RCK to see if any has a draft
			for(ReusableContentKav__c rck : rckList ) {
				if (rck.Publish_Status__c == 'Online') {
					if (kaIdDraftKavIdMap.containsKey(rck.KnowledgeArticleId__c)) {
						//this rck has a draft  - update the Draft kav id
						rck.DraftKavId__c = (Id)kaIdDraftKavIdMap.get(rck.KnowledgeArticleId__c);
						rckToUpdateList.add(rck);
					}
				}
			}
		}
		update rckToUpdateList;
		
	}


	public static void deleteReusableContentArticleJuntion(Id reusableContentId) {
		List<ReusableContentKav__c> records = [
			select id
			from ReusableContentKav__c
			where ReusableContentId__c = :reusableContentId
		];
		delete records;
	}

  
	//ReusableContentKavModel.searchAllActiveArticleTypes('TFS/LFS');
	public static List<ReusableContentKav__c> createReusableContentArticleJuntion(String keyword, Id reusableContentId) {
		List<KmSearchModel.FindKavResult> results = (new KmSoqlSearchModel()).SearchArticles(keyword);
		
		List<ReusableContentKav__c> rckList = new List<ReusableContentKav__c>();		
		for(KmSearchModel.FindKavResult result : results) {
			rckList.add(createReusableContentKav(result, reusableContentId, keyword));
		}
		insert rckList;
		
		return rckList;
	}
	
	public static ReusableContentKav__c createReusableContentKav(KmSearchModel.FindKavResult kav, Id reusableContentId, String searchKeyword) {
		ReusableContentKav__c result = new ReusableContentKav__c();
		
		result.ArticleNumber__c = kav.ArticleNumber;
		result.ArticleType__c = kav.ArticleType;
		result.ArticleVersionTypeName__c = kav.articleVersionTypeName;
		result.KavId__c = kav.KavId;
		result.KavIdDateTime__c = kav.KavId + '?DateTime='+String.ValueOf(DateTime.now().getTime());
		result.KnowledgeArticleId__c = kav.KnowledgeArticleId;
		result.Language__c = kav.Language;
		result.Publish_Status__c = kav.PublishStatus;
		result.ReusableContentId__c = reusableContentId;
		result.SearchKeyword__c = searchKeyword;
		result.Title__c = kav.Title;
		result.VersionNumber__c = String.ValueOf(kav.VersionNumber);
		
		return result;
	}

}