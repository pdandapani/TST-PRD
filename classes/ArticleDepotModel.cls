/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  ArticleDepotModel call methods to interact with the Article Depot
*  
* upgraded for dynamic article types and fields
* converted to global class to support List Button webservice call
**/

global class ArticleDepotModel {
	
	/* v1 static fields - v2 needs dynamic article types and fields
	public static String articleFieldSelect =  'select id, ArticleNumber, Title, LastPublishedDate, FirstPublishedDate, ' +
		'VersionNumber, PublishStatus, ArticleType, UrlName, ArchivedDate, KnowledgeArticleId, LastModifiedDate ';
				
	public static String articleFieldSelectNonCollectionExtra = ', FOPP_Text__c, Expiration_Date__c, ' +
		'Department_Role__c, Knowledge_Container_Name__c, Desk_Guide_Pack__c ';		
			
	*/	
	
	public static String kaSoqlSelect(String articleTypeApiName) {
		String result = 'select ';
		Schema.SObjectType articleTypeSchema = KmArticleTypeModel.globalDescribeSObjects.get(articleTypeApiName);
		if (articleTypeSchema <> null ) {
			List<String> allFields = KmArticleTypeModel.discoverAccessibleFields(articleTypeSchema);
			for(String field : allFields) {  
				result += field+', ';
			}
			
			result = result.substringBeforeLast(', ');
			result += ' ';
		}
		return result;  
	}
	
	//ArticleDepotModel.startPdfConversion();
	@future(Callout=true)
	 public static void startPdfConversion() {
		Http h = new Http();
	
		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
		HttpRequest req = new HttpRequest();
		
		String endPointURL = '';
		
		try{
    		//endPointURL = 'http://75.85.65.144:8080/SFDCweblinkKM/kmArticleToPdf';

    		KB_App_Settings__c kmEngineArticleToPdfUrl = KB_App_Settings__c.getInstance('kmEngineArticleToPdfUrl');
    		
    		if ( kmEngineArticleToPdfUrl != null) {
    			endPointURL = kmEngineArticleToPdfUrl.Value__c;
    		} 
    	}
    	catch(Exception e){
    		endPointURL = 'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmArticleToPdf';
    	}
		
		req.setEndpoint(endPointURL);
		req.setMethod('GET');
	 
		// Send the request, and return a response
		if (!Test.isRunningTest()) {
			HttpResponse res = h.send(req);
		}  
    }  
	
	
			
	/*
	ArticleDepotModel.clearDepot('REMOVEME ReallyWantToClear');
	ArticleDepotModel.clearDepotPdf('REMOVEME ReallyWantToClear');
	ArticleDepotModel.copyToDepot();
	*/
	public static void clearDepot(String reallyWantToClear) {
		
		if ( reallyWantToClear == 'ReallyWantToClear') {
			List<ArticlePDF__c> articles = [ select id from ArticlePDF__c];
			delete articles;
		}
	}
	public static void clearDepotPdf(String reallyWantToClear) {
		
		if ( reallyWantToClear == 'ReallyWantToClearPdf') {
			List<ArticlePDF__c> articles = [ select ArticlePdfContentVersionId__c from ArticlePDF__c];
			for(ArticlePDF__c article : articles) {
				article.ArticlePdfContentVersionId__c = null;
			}
			
			update articles;
		}
	}


	//ArticleDepotModel.copyToDepot();
	public static integer copyToDepot() {
		return copyToDepot(1000);
	}

	public static integer copyToDepot(integer maxCount) {
	
		// use a map to get all 8 article types
		
		integer totalNewArticles = 0;
		for(String articleTypeApiName : KmArticleTypeModel.activeKavApiNames){
			if ( maxCount > 1000 ) {
				maxCount = 1000;  //handle a max of 1000 article for each of the 8 article types
			}		
			totalNewArticles += copyKavToDepot(articleTypeApiName, maxCount);
		}
		
		return totalNewArticles;
	}
	

	
	private static integer copyKavToDepot(String kavType, integer maxCount) {		
		//part 1 - get all the active KA
		List<ArticlePDF__c> newArticlePdfs = copyOnlineKavToDepot(kavType, maxCount);
	
		//part 2 - now deal with the archived ones
	
		// to access the archived articles - we need to specified this isLatestVersion = false and the knowledgeArticleId 
		// so need to create an Apex Batch job to sync each knowledge Article type.
		// need to look into flex queue
		//https://developer.salesforce.com/blogs/engineering/2014/05/flex-batch-apex-muscles-flexqueue.html
		
		
		List<Id> newArticlePdfOriginalArticleIds = new List<Id>();
		for(ArticlePDF__c newArticlePdf : newArticlePdfs){
			newArticlePdfOriginalArticleIds.add(newArticlePdf.OrginalArticleId__c);
		}
		syncArchivedKavToDepotFuture(kavType, newArticlePdfOriginalArticleIds);

		return newArticlePdfs.size();
	}
	
	
	@future   //execute as future to get a new execution context and restart the governor limit
	private static void syncArchivedKavToDepotFuture( String kavType, List<Id> newArticlePdfOriginalArticleIds ) {	
		
		for(Id newArticlePdfOriginalArticleId : newArticlePdfOriginalArticleIds) {
			System.Debug('New ArticlePDF inserted - OrginalArticleId__c = '+ newArticlePdfOriginalArticleId);
		}
		syncArchivedKavToDepot(kavType, newArticlePdfOriginalArticleIds);
	}
	
	public static void syncArchivedKavToDepot( String kavType, List<Id> newArticlePdfOriginalArticleIds ) {	
		//1 - find a list of archived article with archived date in the last 3 months
		DateTime syncLimit = DateTime.now().addMonths(-3);
		
		String kaType = kavType.removeEnd('v');
		
		String findArchivedKaSOQL = 'select id, ArchivedDate, ArticleNumber from ' + kaType + 
			' where archivedDate <> null and archivedDate > :syncLimit ';
		list<sObject> archivedKas = Database.query(findArchivedKaSOQL);
		
		set<Id> allDoneKaIdSet = new set<Id>();
		set<Id> archiveKaToBeMergedIdSet = new set<Id>();
		for(sObject archivedKa : archivedKas) {
			archiveKaToBeMergedIdSet.add(archivedKa.id);
			allDoneKaIdSet.add(archivedKa.id);
		}
		
		//2 - find archived Article that is has been marked archived in the ArticleDepot - we can ignore these
		List<ArticlePDF__c> archivedArticlesStillOnlineList = [
			select id, OrginalArticleId__c, PublishStatus__c, ArchivedDate__c
			from ArticlePDF__c
			where OrginalArticleId__c in :archiveKaToBeMergedIdSet
			and PublishStatus__c = 'Archived'
		];
		
		//filter all articlePDF that are ready to go and does not need sync
		for(ArticlePDF__c articlePDF : archivedArticlesStillOnlineList) {
			if (articlePDF.ArchivedDate__c == null ) {
				allDoneKaIdSet.remove(articlePDF.OrginalArticleId__c);
			}
		}
		
		System.Debug('allDoneKaIdSet = '+ allDoneKaIdSet);
		
		//add back the one that existed but needs update
		archiveKaToBeMergedIdSet.removeAll(allDoneKaIdSet);
	   
        //	
        for(Id newArticlePdfOriginalArticleId : newArticlePdfOriginalArticleIds) {
			System.Debug('add '+newArticlePdfOriginalArticleId+ ' to the archiveKaToBeMergedIdSet');
			archiveKaToBeMergedIdSet.add(newArticlePdfOriginalArticleId);
		}   
	   
	   	System.Debug('archiveKaToBeMergedIdSet = '+ archiveKaToBeMergedIdSet);
	   
		//-----------------------------------------------------------------------
		//copy over the archived KAVs that do not exist as an online article
		//expect a small number there - since we have to use an individual query to accessed archived KAV
		
		for(Id archivedKaToCopy : archiveKaToBeMergedIdSet){
			mergeArchiveKnowledgeArticleNotOnline(archivedKaToCopy, kavType);
		}
	}
	
	public static void mergeArchiveKnowledgeArticleNotOnline(id archivedKaToCopy, String kavType) {
		
		
		//get a list of ArticlePDF with OriginalKnowledgeArticleId = archivedKaToCopy
		List<ArticlePDF__c> articlePDFs = [
			select PublishStatus__c, ArchivedDate__c, ArticleNumVersion__c, id, Article_Number__c, ArticleTypeAPI__c
			from ArticlePDF__c
			where OrginalArticleId__c = :archivedKaToCopy
		];
		
		//create a map - articlePdfMapByArticleNumVersion
		Map<String, ArticlePDF__c> articlePdfMapByArticleNumVersion = new Map<String, ArticlePDF__c>();
		for (ArticlePDF__c articlePdf : articlePDFs) {
			articlePdfMapByArticleNumVersion.put(articlePdf.ArticleNumVersion__c, articlePdf);
		}
	
		String SOQL = kaSoqlSelect(kavType) +
			'from  ' + kavType + ' ' +
			'where (PublishStatus = \'Archived\' and Language = \'en_US\') '+
			'and isLatestVersion = false and knowledgeArticleId = \'' + archivedKaToCopy +'\'';
			
			
		System.Debug(SOQL);
		list<sObject> archivedKavs = Database.query(SOQL);	
		
		
		list<ArticlePDF__c> articlePdfUpsertList = new List<ArticlePDF__c>();
		for (sObject archivedKav : archivedKavs ) {
		
			String articleNumVersion = KmModel.getArticleNumVersion(archivedKav);
			
			if (articlePdfMapByArticleNumVersion.containsKey(articleNumVersion)) {
				ArticlePDF__c articlePdfToUpdate = articlePdfMapByArticleNumVersion.get(articleNumVersion);
				articlePdfToUpdate.PublishStatus__c = (String)archivedKav.get('PublishStatus');
				articlePdfToUpdate.ArchivedDate__c = (DateTime)archivedKav.get('ArchivedDate');
				
				articlePdfUpsertList.add(articlePdfToUpdate);
			} else {
				//create a new arcitlePDF record for one that does not exit
				articlePdfUpsertList.add(copyKavToArticlePDF(archivedKav, kavType));
			}
		}
		upsert articlePdfUpsertList;
	}
		
	private static ArticlePDF__c copyKavToArticlePDF(sObject kav, String kavType) {	
		ArticlePDF__c article = new ArticlePDF__c();
		
		//standard Knowledge Article Fields
		article.Title__c = (String)kav.get('Title');
		article.Summary__c = (String)kav.get('Summary');
		article.Article_Number__c = (String)kav.get('ArticleNumber');
		article.VersionNumber__c = (Decimal)kav.get('VersionNumber');  
		article.publishStatus__c = (String)kav.get('PublishStatus');
		article.PublishedDate__c = (DateTime)kav.get('LastModifiedDate');
		article.FirstPublishedDate__c = (DateTime)kav.get('FirstPublishedDate');
		article.LastPublishedDate__c = (DateTime)kav.get('LastPublishedDate');
		article.ArchivedDate__c = (DateTime)kav.get('ArchivedDate');
		
		
		article.Article_Created_By__c = (String)kav.get('CreatedById');  
		article.ArticleCreatedDate__c = (DateTime)kav.get('CreatedDate');  
		article.Article_Last_Modified_By__c = (String)kav.get('LastModifiedById');  
		article.ArticleLastModifiedDate__c = (DateTime)kav.get('LastModifiedDate');  
		
		article.OrginalArticleId__c = (String)kav.get('KnowledgeArticleId');
		article.OrginalArticleVersionId__c = (String)kav.get('id');
		
		//convert api name to Article Type Label Name  
		String apiName = (String)kav.get('ArticleType');
		article.ArticleTypeAPI__c = apiName.tolowercase();
		article.ArticleType__c = KmArticleTypeModel.SObjectApiToLabelName(apiName);
		
		if (article.ArticleTypeAPI__c.endsWith('ka')) {
				article.ArticleTypeAPI__c += 'v';
		}
		
		article.UrlName__c =  (String)kav.get('UrlName');
		
		//article.ArticleNumVersion__c = article.Article_Number__c + ':' + article.VersionNumber__c;
		article.ArticleNumVersion__c = KmModel.getArticleNumVersion(article.Article_Number__c,article.VersionNumber__c);
		
		
		//get a map of all dynamic fields
		Map<String, Schema.SobjectField> sObjectFieldMap = KmArticleTypeModel.getSObjectFieldMap(kavType);
		
		//copy all custom fields over to the article archive
		SObject articleSObj = article;
		for(String sObjectField : sObjectFieldMap.keySet()) {
			if (sObjectField.toLowerCase().endsWith('__c')) {
				articleSObj.put(sObjectField, kav.get(sObjectField));
			}
		}
		
		//special request from review with Keith and Ben
		//copy the FOPP_text to FOPP - do not want to see the HTML tag in FOPP
		articleSObj.put('FOPP__c', kav.get('FOPP_Text__c'));
		
		return article;
	}
	
	private static List<ArticlePDF__c> copyOnlineKavToDepot(String kavType, integer maxCount) {		
		
		System.Debug('\n\ncopyKavToDepot - checking '+kavType);		
		
		//find a list of published FAQ kav that has not been copied to Article Depot 
		list<id> articlesToCopy = findListOfNewOnlineArticle(kavType, maxCount);
	
		//make a copy in articlePDFs
		List<ArticlePDF__c> newArticlePDFs = copyNewOnlineArticleToArticlePDF(articlesToCopy, kavType);	
			
		//for this setup of newly inserted record
		//let's go back 1 version and adjust the archived date
		adjustArchivedDateOfPrevious(newArticlePDFs);
		
		return newArticlePDFs;
	}
	
	private static List<id> findListOfNewOnlineArticle( String kavType, integer maxCount) {
		//load all published articles for this KAV
		String SoqlPublished = 'select id, ArticleNumber, VersionNumber ' +
		 	'from ' + kavType + ' ' +
		 	'where (PublishStatus = \'online\' and Language = \'en_US\') ' +
		 	'order by LastPublishedDate ';
		 	
		List<sObject> publishedArticles = Database.query(SoqlPublished);
		
		//create a set of what is currently published
		Set<String> kavArticleNumberVersionSet = new Set<String>();
		for(sObject kav : publishedArticles) {
			kavArticleNumberVersionSet.add( KmModel.getArticleNumVersion(kav) );
		}
		
		System.Debug('kavArticleNumberVersionSet : '+kavArticleNumberVersionSet);
		
		//check the articleDepot to see if we have a copy of each
		List<ArticlePDF__c> ArticlePdfs= [
			select ArticleNumVersion__c
			from ArticlePDF__c 
			where ArticleNumVersion__c in :kavArticleNumberVersionSet
		];   
		
		//now construct a set of ArticleNumVersion of what we have in the articlePdf
		set<String> articlePdfArticleNumVersionSet = new set<String>();
		for(ArticlePDF__c articlePdf : ArticlePdfs) {
			articlePdfArticleNumVersionSet.add(articlePdf.ArticleNumVersion__c);
		}
		
		System.Debug('articlePdfArticleNumVersionSet : '+articlePdfArticleNumVersionSet);
		
		//take the records in the articlePdf list away
		kavArticleNumberVersionSet.removeAll(articlePdfArticleNumVersionSet);

		//what is left in kavArticleNumberVersionSet is what we want to copy over 
		list<id> articlesToCopy = new List<Id>();
		
		for(sObject publishedArticle : publishedArticles) {
			String publishedArticleNumberVersion = KmModel.getArticleNumVersion(publishedArticle);
			
			if (kavArticleNumberVersionSet.contains(publishedArticleNumberVersion) ) {
				articlesToCopy.add((Id)publishedArticle.get('Id'));
			}
			
		}
		
		return articlesToCopy;
	}
	
	private static List<ArticlePDF__c> copyNewOnlineArticleToArticlePDF(list<id>  articlesToCopy, String kavType) {
				
		String fieldList = kaSoqlSelect(kavType);	
		String SOQL = fieldList +
			'from  ' + kavType + ' ' +
			'where (PublishStatus = \'online\' and Language = \'en_US\') ' +
			'and id in :articlesToCopy';
			
		list<sObject> kavs = Database.query(SOQL);	
		
		//create a list of ArticlePDF records
		List<ArticlePDF__c> newArticlePDFs = new List<ArticlePDF__c>();
		for(sObject kav : kavs) {
			ArticlePDF__c article = new ArticlePDF__c();
			
			//standard knowledge article fields
			article.Title__c = (String)kav.get('Title');
			article.Summary__c = (String)kav.get('Summary');
			article.Article_Number__c = (String)kav.get('ArticleNumber');
			article.VersionNumber__c = (Decimal)kav.get('VersionNumber');  
			article.publishStatus__c = (String)kav.get('PublishStatus');
			article.PublishedDate__c = (DateTime)kav.get('LastModifiedDate');
			article.FirstPublishedDate__c = (DateTime)kav.get('FirstPublishedDate');
			article.LastPublishedDate__c = (DateTime)kav.get('LastPublishedDate');
			//article.ArchivedDate__c = (DateTime)kav.get('ArchivedDate');
			
			article.Article_Created_By__c = (String)kav.get('CreatedById');  
			article.ArticleCreatedDate__c = (DateTime)kav.get('CreatedDate');  
			article.Article_Last_Modified_By__c = (String)kav.get('LastModifiedById');  
			article.ArticleLastModifiedDate__c = (DateTime)kav.get('LastModifiedDate');  
			
			article.OrginalArticleId__c = (String)kav.get('KnowledgeArticleId');
			article.OrginalArticleVersionId__c = (String)kav.get('id');
			
			//convert api name to Article Type Label Name  
			String apiName = (String)kav.get('ArticleType');
			article.ArticleTypeAPI__c = apiName.tolowercase();
			article.ArticleType__c = KmArticleTypeModel.SObjectApiToLabelName(apiName);
			if (article.ArticleTypeAPI__c.endsWith('ka')) {
				article.ArticleTypeAPI__c += 'v';
			}
			
			article.UrlName__c =  (String)kav.get('UrlName');
			
			//article.ArticleNumVersion__c = article.Article_Number__c + ':' + article.VersionNumber__c;
			article.ArticleNumVersion__c = KmModel.getArticleNumVersion(article.Article_Number__c,article.VersionNumber__c);
			
			
			//get a map of all dynamic fields
			Map<String, Schema.SobjectField> sObjectFieldMap = KmArticleTypeModel.getSObjectFieldMap(kavType);
			
			//copy all custom fields over to the article archive
			SObject articleSObj = article;
			for(String sObjectField : sObjectFieldMap.keySet()) {
				if (sObjectField.toLowerCase().endsWith('__c')) {
					articleSObj.put(sObjectField,kav.get(sObjectField));
				}
			}
			
			//special request from review with Keith and Ben
			//copy the FOPP_text to FOPP - do not want to see the HTML tag in FOPP
			
			if ( sObjectFieldMap.containsKey('FOPP_Text__c') &&  sObjectFieldMap.containsKey('FOPP__c')) {
				try {
					articleSObj.put('FOPP__c', kav.get('FOPP_Text__c'));
				} catch(System.SObjectException SE) {
					//not all article type has FOPP_Text__c - just ignore if it is not available.
				}
			}
			newArticlePDFs.add(article);
		}
		
		//set save point to start transaction 
		Savepoint sp = Database.setSavepoint();
		try {
			database.insert(newArticlePDFs);
		} catch(Exception ex) {
			Database.rollback(sp);
			return new List<ArticlePDF__c>();
		}
		
		return newArticlePDFs;
	}
	
	private static integer adjustArchivedDateOfPrevious(List<ArticlePDF__c> newArticlePDFs) {
		
		//create a list of ArticleNumVersion to retrieve
		Set<String> archivedArticleNumVersionSet = new Set<String>();
		Map<String, ArticlePDF__c> onlineArticlePdfMap = new Map<String, ArticlePDF__C>();
		
		for(ArticlePDF__c newArticlePDF : newArticlePDFs) {
			if ( newArticlePDF.VersionNumber__c > 1.0) {
				//String archivedArticleNumVersion = newArticlePDF.Article_Number__c + ':' + Integer.ValueOf(newArticlePDF.VersionNumber__c - 1.0);
				String archivedArticleNumVersion = KmModel.getArticleNumVersion(newArticlePDF.Article_Number__c,Integer.ValueOf(newArticlePDF.VersionNumber__c - 1.0));
				archivedArticleNumVersionSet.add(archivedArticleNumVersion);
			}
			
			onlineArticlePdfMap.put(newArticlePDF.ArticleNumVersion__c, newArticlePDF);
		}
		
		System.Debug('adjustArchivedDateOfPrevious - archivedArticleNumVersionSet '+archivedArticleNumVersionSet);
		
		
		// retrieve all previous articles
		List<ArticlePDF__c> archivedArtickePDFS = [
			select id, Article_Number__c, VersionNumber__c
			from ArticlePDF__c
			where ArticleNumVersion__c in :archivedArticleNumVersionSet
		];   
		
		//process each record - set the published date of the online version as the expiration date
		for(ArticlePDF__c archivedArticlePDF : archivedArtickePDFS) {
			//String OnlineArticleNumVersion = archivedArticlePDF.Article_Number__c + ':' + Integer.ValueOf(archivedArticlePDF.VersionNumber__c + 1.0);
			String OnlineArticleNumVersion = KmModel.getArticleNumVersion(archivedArticlePDF.Article_Number__c,Integer.ValueOf(archivedArticlePDF.VersionNumber__c + 1.0));
			
			ArticlePDF__c onlineArticlePdf = onlineArticlePdfMap.get(OnlineArticleNumVersion);
			
			if (onlineArticlePdf <> null) {
				archivedArticlePDF.ArchivedDate__c = onlineArticlePdf.LastPublishedDate__c.addSeconds(-1);
				archivedArticlePDF.PublishStatus__c = 'Archived';
			} else {
				System.Debug('cannot locate '+ OnlineArticleNumVersion);
			}
		}
		
		update archivedArtickePDFS;
		
		return archivedArtickePDFS.size();
	}

	//webservice for the ArticleDepot Object List Button to start the BatchJob onDemand
  	webservice static void OnDemandCopyArticlesToArticleDepot() {
		ArticleDepotJob.runNow();
		return;
	}
	
}