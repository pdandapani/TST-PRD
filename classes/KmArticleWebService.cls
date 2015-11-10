/*

@httpPost - get the KM Article

*/

@RestResource(urlMapping='/KmArticleWebService/v1/*')
global class KmArticleWebService {
	
	@httpPost
	global Static KmArticleWebServiceReply post (string articleType, string articleRef, string publishStatus) {
	  	 
	  	System.debug('*** KmArticleWebService::post '+articleType + '  '+ articleRef); 
		KmArticleWebServiceReply reply = getArticleFromArticleDepot(articleRef, publishStatus);
		
		if ( reply == null) {
			System.debug('*** Error - return null for KmArticleWebService::post '+articleType + '  '+ articleRef + ' '+ publishStatus); 
		}
		
		return reply;
	}

	private static KmArticleWebServiceReply getArticleFromArticleDepot(string articleRef, string publishStatus) {
		List<ArticlePDF__c> articles = [ 
				select a.ArticleType__c, a.ArticleTypeAPI__c, a.Article_Number__c, a.OrginalArticleId__c,
					a.KnowledgeContainerName__c, a.Department_Role__c, a.Details__c, a.Title__c,
					a.DM_Forms__c, a.Expiration_Date__c, a.PublishedDate__c, a.FOPP_Text__c,
					a.VersionNumber__c, a.PublishStatus__c, a.UrlName__c, a.ArticleCreatedDate__c,
					a.ArticleCreatedBy__c, a.ArticleLastModifiedDate__c, a.ArticleLastModifiedBy__c
				from ArticlePDF__c a
				where ( a.OrginalArticleVersionId__c = :articleRef ) 
		];
		
		if ( articles.size() == 1) {
			return new KmArticleWebServiceReply(articles[0]);
		} else {
			return null;
		}
	} 
	
	//KmArticleWebService.deleteAllArticleDepotPdf();
	public static void deleteAllArticleDepotPdf () {
		List<ArticlePDF__c> articlePdfList = [
			select id, ArticlePdfContentVersionId__c
			from ArticlePDF__c
			where ArticlePdfContentVersionId__c <> null
		];
		
		List<Id> cvIdList = new List<Id>();
		for(ArticlePDF__c articlePdf : articlePdfList) {
			cvIdList.add(articlePdf.ArticlePdfContentVersionId__c);
			articlePdf.ArticlePdfContentVersionId__c = null;
		}
		
		List<ContentVersion> cvList = [
			select id
			from ContentVersion
			where id in :cvIdList
		];  
		
		//delete cvList;
		//delete not allowed on content
		update articlePdfList;
		
	}
	
	global class KmArticleWebServiceReply {
	
		public String articleTypeLabel = '';
		public String articleType = '';
	 	public String articleNumber = '';
	 	public String knowledgeArticleId = '';
	 	public String container = '';
	 	public String role = '';
	 	public String detail = '';
	 	public String title = '';
	 	public String dmforms = '';
	 	public Date expiration = Date.Today();
	 	public Datetime publishDate = DateTime.Now();
	 	public String fopp = '';
	 	public Integer version = -1;
	 	public String publishStatus = '';
	 	public String UrlName = '';
	 	
	 	public Datetime createdDate = DateTime.Now();
	 	public String createdBy = '';
	 	public Datetime lastModifiedDate = DateTime.Now();
	 	public String lastModifiedBy = '';
	 	
	 	//hierarchyId = a.Knowledge_Container__r.Name;
	 	//
	 	public KmArticleWebServiceReply( ArticlePDF__c a) {
	 		articleTypeLabel = a.ArticleType__c; 
	 		articleType = a.ArticleTypeAPI__c;
	 		articleNumber = a.Article_Number__c;
	 		knowledgeArticleId = a.OrginalArticleId__c;
	 		container = a.KnowledgeContainerName__c; 
	 		role = a.Department_Role__c;		
	 		detail = a.Details__c;
	 		title = a.Title__c;
	
	 		dmforms = a.DM_Forms__c;
	 		expiration = a.Expiration_Date__c;
	 		publishDate = a.PublishedDate__c;
	 		fopp = a.FOPP_Text__c;
	 		version = Integer.ValueOf(a.VersionNumber__c);  
	 		publishStatus = a.PublishStatus__c;
	 		UrlName = a.UrlName__c;
	 		
	 		createdDate = a.ArticleCreatedDate__c;
	 		createdBy = a.ArticleCreatedBy__c;
	 		lastModifiedDate = a.ArticleLastModifiedDate__c;
	 		lastModifiedBy = a.ArticleLastModifiedBy__c;
	 	}
	
	}
}