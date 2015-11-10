public class ReusableContentUpdateModel {
	public static final String CR = '\r\n';
	
	public static void UpdateArticlesByTag(id reusableContentId) {
		
		Reusable_Content__c rcTag = [
			select id, Publish__c
			from Reusable_Content__c
			where id = :reusableContentId
		];
		
		if (rcTag == null) {
			System.Debug('ERROR - ReusableContentUpdateModel::UpdateArticlesByTag cannot locate reusableContentId : '+reusableContentId);
			return;
		}
		
		boolean toPublishDraft = rcTag.Publish__c;
		
  		List<Id> reusableContentIds = new List<Id>();
  		reusableContentIds.add(reusableContentId);
  		
  		UpdateArticlesByTags(reusableContentIds, toPublishDraft);
  	}
  	
	public static void UpdateArticlesFromAllTags() {
		List<Reusable_Content__c> rcList = [
			select id
			from Reusable_Content__c
		];

  		List<Id> reusableContentIds = new List<Id>();
		for(Reusable_Content__c rc : rcList) {
			reusableContentIds.add(rc.id);
		}
  		UpdateArticlesByTags(reusableContentIds, false);  //publishDraft = false
  	}
  
  	private static void UpdateArticlesByTags(List<id> reusableContentIds, boolean toPublishDraft) {
  		System.Debug(CR+CR+'ReusableContentUpdateModel::UpdateArticlesByTags for rc tag : '+ reusableContentIds+CR+CR);
  		
  		
  		// 1 - find all ReusableContentKav__c associated with this reusableContentId
  		List<ReusableContentKav__c> rckList = [
  			select id, ArticleNumber__c, ArticleType__c, ArticleVersionTypeName__c, KavId__c, KnowledgeArticleId__c, Publish_Status__c, VersionNumber__c, Title__c, DraftKavId__c
  			from ReusableContentKav__c
  			where ReusableContentId__c in :reusableContentIds
  			order by Publish_Status__c, ArticleNumber__c    //sort by Publish_Status__c to show the Draft before Online
  		];
  		
  		// 2 - sort out the Draft from the Online Articles
  		// for a draft article - it is good for replacement
  		// for an online article without a draft - create a draft in the article type future routine to avoid governor limit as much as possible and perform replacement 
  		// for an online article with a draft - just ignore it.
  		
  		Map<String, ReusableContentKav__c> rckMapForDraft = new Map<String, ReusableContentKav__c>();
  		Map<String, ReusableContentKav__c> rckMapForOnline = new Map<String, ReusableContentKav__c>();
  		
  		for (ReusableContentKav__c rck :  rckList) {
  			if ( rck.Publish_Status__c == 'Draft' ) {
  				rckMapForDraft.put(rck.ArticleNumber__c, rck);
  			} else if (rck.Publish_Status__c == 'Online' ) {
  			
  				if (!rckMapForDraft.containsKey(rck.ArticleNumber__c) && (rck.DraftKavId__c == null)) {
  					rckMapForOnline.put(rck.ArticleNumber__c, rck);
  				}else{
  					//if rck.DraftKavId__c != null, then we have a draft [ without the tag ] already.  cannot create another one.
  				}
  			}
  		}
  		
  		//3 - now we have 2 maps consist of Draft & Online Articles -
  		// sort into separate lists by Dynamic Knowledge Article Type
  		Map<String, List<ReusableContentKav__c>> mapOfListOfDraftArticles = sortKnowledgeArticleByType(rckMapForDraft);
  		Map<String, List<ReusableContentKav__c>> mapOfListOfOnlineArticles = sortKnowledgeArticleByType(rckMapForOnline);
  		
  		
		//4 - start a separate Async Job for each type of draft Knowledge Article
  		for (String articleType : mapOfListOfDraftArticles.KeySet()) {		
  			List<SObject> kavs = mapOfListOfDraftArticles.get(articleType);
  			Set<Id> kavIds = getKavIdList(kavs);
  			String kavType = articleType.toLowerCase()+'v';
  			
  			System.Debug('Starting async job ReplaceContent for '+ kavType+' kavIds = '+kavIds);
  			ReplaceContentFuture(kavType , kavIds, toPublishDraft);
  		}
  		
  		
  		//5 - find out which of these online articles needs new content
  		//    perform an extra read per article type has low impact to governor limit		
  		Map<String, List<ReusableContentKav__c>> mapOfListOfOnlineArticlesNeedDraft = sortOnlineArticlesForChange(mapOfListOfOnlineArticles);
  		
  		
  		//6 - start a separate Async Job for each type of online knowledge articles
  		//    creating a new draft requires a DML operation - as of Spring 15 - there can only be 150 DML statement per invocation.
  		//    if each article type has more than 150 online knowledge articles that requires new reusable content, then the future 
  		//    call will fail.
  		//    The solution is to pre-create draft articles so that the number of draft articles created is < 150.
  		//
  		//    https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_gov_limits.htm
  		//
  	  	for (String articleType : mapOfListOfOnlineArticlesNeedDraft.KeySet()) {		
  	  		
  	  		System.Debug('Step 6 - articleType = '+ articleType);
  	  		
  			List<ReusableContentKav__c> onlineRckList = mapOfListOfOnlineArticlesNeedDraft.get(articleType);
  			if ( onlineRckList.size() > 0) {
	  			Set<Id> kavIds = new Set<Id>();
	  			for(ReusableContentKav__c onlineRck : onlineRckList) {
	  				kavIds.add(onlineRck.KavId__c);
	  			}
	  			String kavType = articleType.toLowerCase()+'v';
	  			
	  			System.Debug('Starting async job ReplaceContent for '+ kavType+' kavIds = '+kavIds);
	  			CreateDraftAndReplaceContentFuture(kavType , kavIds, toPublishDraft);
  			}
  		}
  	}
  	
  	@Future
  	public static void CreateDraftAndReplaceContentFuture(String articleVersionType, Set<Id> kavIds, boolean toPublishDraft)  {
  		
  		System.Debug(CR+CR+'CreateDraftAndReplaceContentFuture'+CR+CR);
  		
  		// 1. translate the KavIds into KaId
  		String soql = 'select id, knowledgeArticleId ' +
  			'from '+articleVersionType+' ' +
  			'where id in :kavIds';
  		List<SObject> kavList =  Database.Query(soql);
  		
  		Set<Id> kaIds = new Set<Id>();
  		for (SObject kav : kavList) {
  			kaIds.add((Id)kav.get('knowledgeArticleId'));
  		}
  		
  		// 2. create a draft article for each of these online that requires changes
  		Set<Id> draftKavIds = new Set<Id>();
  		for(Id kaId : kaIds) {
  			//https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_classes_knowledge_kbManagement.htm#apex_KbManagement_PublishingService_editOnlineArticle
  			String draftArticleId = KbManagement.PublishingService.editOnlineArticle(kaId, false);  //unpublish = false
  			draftKavIds.add(draftArticleId);
  		}  
  		
  		// 3. invoke ReplaceContent
  		ReplaceContent(articleVersionType , draftKavIds, toPublishDraft);
  	}
  	
  	public static Map<String, List<ReusableContentKav__c>> sortOnlineArticlesForChange(Map<String, List<ReusableContentKav__c>> mapOfListOfOnlineArticles) {
  		
  		System.Debug(CR+CR+'sortOnlineArticlesForChange # of online articleType to check = '+mapOfListOfOnlineArticles.size()+CR+CR);
  		
  		//create a map of <kavId, ReusableContentKav__c>
  		Map<Id, ReusableContentKav__c> rckByKavIdMap = new Map<Id, ReusableContentKav__c>();
  		for(String articleType : mapOfListOfOnlineArticles.KeySet()) {
  			List<ReusableContentKav__c> rckList = mapOfListOfOnlineArticles.get(articleType);
  			for(ReusableContentKav__c rck :rckList) {
  				rckByKavIdMap.put(rck.kavId__c, rck);
  			}
  		}
  		
  		
  		Map<String, List<ReusableContentKav__c>> result = new Map<String, List<ReusableContentKav__c>>();
  		
  		//articleType is the KnowledgeArticle API name in lowercase
  		for ( String articleType : mapOfListOfOnlineArticles.KeySet()) {			
  			System.Debug('sortOnlineArticlesForChange checking articleType = '+ articleType+CR);
  			List<SObject> rckList = mapOfListOfOnlineArticles.get(articleType);
  			if ( rckList == null) {
  				System.Debug(mapOfListOfOnlineArticles.keySet());
  			}
  			System.Debug('sortOnlineArticlesForChange checking articleType = '+ articleType+'  rckList size = ' + rckList.size() + CR);
  			Set<Id> kavIds = getKavIdList(rckList);
  			String articleVersionType = articleType.toLowerCase()+'v';
  			
  			//construct SOQL to retrieve the Online articles to see if it needs update
  			Schema.SObjectType sObjectType = KmArticleTypeModel.knowledgeArticleVersionsMap.get(articleVersionType);
  			Set<String> fieldSet = KmArticleTypeModel.discoverAccessibleRichTextFields(sObjectType);
  			String SOQL_query = 'select ';
			for(String field : fieldSet) {
				SOQL_query += field + ', ';
			}
			SOQL_query = SOQL_query.removeEnd(', ');
			SOQL_query += ' from '+articleVersionType;
			SOQL_query += ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' ';
			SOQL_query += ' and Id in :kavIds'; 
	  		
	  		System.Debug(SOQL_query);
	  		List<SObject> kavs = Database.query(SOQL_query);
	  		
	  		for (SObject kav : kavs ) {
	  			boolean needDraftVersion = false;  			
	  			for ( String field : fieldSet) {  // for each field
	  				string oldField = (String)kav.get(field);
	  				if ( oldField <> null) {
		  				string newField = oldField;
			  			for(String contentTag :  reusableContentMap.KeySet() ) {  // compare with each content tag	
			  				System.Debug('checking field '+field+' for tag '+ oldField+ ' for contentTag = '+contentTag);
			  				if ( oldField.contains(contentTag)) {   
			  					//perform replace here by looking for matching <div></div>
			  					newField = substituteReusableContent(newField, contentTag, reusableContentMap.get(contentTag), 0);	
			  					
			  					if ( newField <> oldField) {
			  						System.Debug('need Draft version since oldField <> newField => '+newField);
			  						needDraftVersion = true;
			  					}
			  					
			  				}
			  			}
	  				} else {
	  					System.Debug(' field '+ field + ' is null');
	  				}
	  			}
	  			if (needDraftVersion) {
	  				if ( !result.containsKey(articleType)) {
	  					result.put(articleType, new List<ReusableContentKav__c>());
	  				}
	  				Id kavId = (Id)kav.get('Id');
	  				ReusableContentKav__c rck = rckByKavIdMap.get(kavId);
	  				
	  				System.Debug(CR+CR+'sortOnlineArticlesForChange - article '+ rck.Title__c + ' has change - need a draft for update' +CR+CR);
	  				
	  				result.get(articleType).add(rck);
	  			}
	  		}
	  		
  		}
  		return result;
  	}
  	
  	public static Set<Id> getKavIdList(List<SObject> objects) {
  		Set<Id> result = new Set<Id>();
  		for(SObject obj : objects) {
  			
  			Id kavId = (Id)obj.get('KavId__c');
  			result.add(kavId);
  		}
  		return result;
  	}
  	
  	//Maximum number of methods with the future annotation allowed per Apex invocation	50
  	@future  //async jobs : one for each knowledge Article type - as of spring 15 - we support 50 async job per innvocation
  	public static void ReplaceContentFuture(String articleVersionType, Set<Id> kavIds, boolean toPublishDraft) {
  		ReplaceContent(articleVersionType,kavIds,toPublishDraft);
  	}
  	public static void ReplaceContent(String articleVersionType, Set<Id> kavIds, boolean toPublishDraft) {
  		System.Debug('ReplaceContent for '+ articleVersionType + '  ' + kavIds);
  		
  		// 1. find a list of all Rich Text Fields to scan for content tag
  		Schema.SObjectType sObjectType = KmArticleTypeModel.knowledgeArticleVersionsMap.get(articleVersionType);
  		if (sObjectType == null ) {
  			Set<String> kavs = KmArticleTypeModel.knowledgeArticleVersionsMap.KeySet();
  			System.Debug('ERROR ReplaceContent - cannot locate ' +articleVersionType + ' in these kavs ' + kavs);
  			return;
  		}
		Set<String> fieldSet = KmArticleTypeModel.discoverAccessibleRichTextFields(sObjectType);
		if ( fieldSet.size() == 0 ) {
			System.Debug('ReplaceContent could not locate fields for '+ articleVersionType);
			return;
		}
			
  		// 2. retrieve & process all draft knowledge articles
  		
  		String SOQL_query = 'select ';
		for(String field : fieldSet) {
			SOQL_query += field + ', ';
		}
		SOQL_query = SOQL_query.removeEnd(', ');
		SOQL_query += ' from '+articleVersionType;
		SOQL_query += ' WHERE PublishStatus = \'Draft\' AND Language = \'en_US\' ';
		SOQL_query += ' and Id in :kavIds'; 
  		
  		System.Debug(SOQL_query);
  		List<SObject> kavs = Database.query(SOQL_query);
  		
  		// 3. for each articles, compare each field with each content tag - replace if necessary
  		List<SObject> dirtyRecords = new List<SObject>();
  		for (SObject kav : kavs ) {
  			boolean dirty = false;  			
  			for ( String field : fieldSet) {  // for each field
  				string oldField = (String)kav.get(field);
  				if ( oldField <> null) {
	  				string newField = oldField;
		  			for(String contentTag :  reusableContentMap.KeySet() ) {  // compare with each content tag	
		  				System.Debug('checking field '+field+' for tag '+ oldField+ ' for contentTag = '+contentTag);
		  				if ( oldField.contains(contentTag)) {   
		  					//perform replace here by looking for matching <div></div>
		  					newField = substituteReusableContent(newField, contentTag, reusableContentMap.get(contentTag), 0);	
		  					System.Debug('newField = '+newField);
		  					if ( newField <> oldField) {
		  						kav.put(field, newField);
		  						dirty = true;
		  					}
		  					
		  				}
		  			}
  				} else {
  					System.Debug(' field '+ field + ' is null');
  				}
  			}
  	
  			if ( dirty) {
  				dirtyRecords.add(kav);
  			}
  		}
  		update dirtyRecords;
  		
  		//
  		// 4. if any field in the article changes - publish if requested
  		if (toPublishDraft) {
  			for(SObject kav : dirtyRecords ) {
  				boolean flagAsNew = true;
  				Id articleId = (Id)kav.get('KnowledgeArticleId');
  				publishArticle( articleId, flagAsNew);
  			}
  		} 
  		
  	}
  	

    
    /**
    * @description      Recurive method to substitute all instances of reusable content tag in the subject
    *                   with the reusable content text. 
    * @param  String    subject - the target text within which the reusable content tag has to be searched
    *                             for substituting the reusable content 
    * @param  String    contentName - Name of the reusable content tag
    * @param  String    reusableContent - reusable content text
    * @param  Integer   searchPos - The position at which the search for the reusable content has to begin. 
    *                               On call from client, it will be zero. On recursive calls, this will be 
    *                               replaced with the length of the string already processed. 
    * @return String    subject with reusable content tag div's content replaced with reusable content text. 
    */
    private static String substituteReusableContent(String subject, String contentName, String reusableContent, Integer searchPos) {
        System.debug('++++++substituteReusableContent::Recursive call: subject = '+ subject + '  searchPos = ' + searchPos);
        String rcDivTagStart = '<div id="'+contentName+'">';
        String rcDivTagEnd = '</div>';
        String returnString = subject; //set returnString to subject initially
        
        Integer rcDivTagStartPos = returnString.indexOf(rcDivTagStart, searchPos);
        
        if (rcDivTagStartPos == -1) {
            return (returnString);
        } else {
            Integer rcDivTagEndPos = returnString.indexOf(rcDivTagEnd, rcDivTagStartPos + rcDivTagStart.length());
            
            if (rcDivTagEndPos == -1) {
                return (returnString);
            } else {
                returnString = subject.subString(0, rcDivTagStartPos) + //String before the reusable content tag start
                               rcDivTagStart + reusableContent + rcDivTagEnd; //Replaced content along with the tag start & end
                Integer newSearchPos = returnString.length(); //Find the position from which new search has to start
                returnString += subject.subString(rcDivTagEndPos + rcDivTagEnd.length()); //String after the reusable content tag end
                
                //recursively call this method to replace any more instances of the tag
                return (substituteReusableContent(returnString, contentName, reusableContent, newSearchPos));
            }
        }
    }
  	
  	public static Map<String, List<ReusableContentKav__c>> sortKnowledgeArticleByType(Map<String, ReusableContentKav__c> rckMap) {
  		
  		Map<String, List<ReusableContentKav__c>> mapOfListOfDraftArticles = new Map<String, List<ReusableContentKav__c>>();
   		for (ReusableContentKav__c rck : rckMap.Values() ) {
  			String articleVersionType = rck.ArticleVersionTypeName__c;
  			if ( !mapOfListOfDraftArticles.containsKey(articleVersionType)) {
  				mapOfListOfDraftArticles.put(articleVersionType, new List<ReusableContentKav__c>());
  			}
  			mapOfListOfDraftArticles.get(articleVersionType).add(rck);
  		}
  		

  		String debugStr = CR+ 'sortKnowledgeArticleByType' + CR;
  		for(String articleType : mapOfListOfDraftArticles.KeySet()) {
  			debugStr += '     '+articleType+' : '+mapOfListOfDraftArticles.get(articleType).size() + CR;
  		}
  		System.Debug(debugStr);
  		
  		return mapOfListOfDraftArticles;
  	}
  	
  	/**
    * @description  Schedule and publish articles based on specified date.
    * @param        String  Article ID. 
    * @param        Boolean Flag for revision.             
    */
    public static void publishArticle(String articleId, Boolean flagAsNew) {
    	KbManagement.PublishingService.publishArticle(articleId, flagAsNew);
    }
  	
  	//////////////////////////////////////////////////////////////////////////////////
  	
	private static Map<String,String> pReusableContentMap = null;
	public static Map<String,String> reusableContentMap {
		get {
			if ( pReusableContentMap == null ) {
				pReusableContentMap = new Map<String,String>();
				
				List<Reusable_Content__c> rcList = [
					select Name, Description__c
					from Reusable_Content__c
				];
				
				for (Reusable_Content__c rc : rcList ) {
					//String key = '<div id="' + rc.Name + '">';
					String key = rc.Name;
					pReusableContentMap.put(key, rc.Description__c);
				}
			}
			return pReusableContentMap;
		}
	}
  
}