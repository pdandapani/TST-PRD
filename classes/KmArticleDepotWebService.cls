@RestResource(urlMapping='/KmArticleDepotWebService/v1/*')
global class KmArticleDepotWebService {

	//return ArticleDepotRecords without PDF
	@httpPost
	global static KmArticleDepotReply post() {
		List<ArticlePDF__c> articles = [ 
				select a.id, a.ArticleType__c, a.ArticleTypeAPI__c, a.Article_Number__c, a.OrginalArticleId__c, OrginalArticleVersionId__c,
					a.ArticleNumVersion__c, a.VersionNumber__c, a.ArticlePdfContentVersionId__c, a.ArticleHtml__c, a.Title__c, a.Summary__c
				from ArticlePDF__c a
				where ( a.ArticlePdfContentVersionId__c = null ) 
				limit 1000
		];
		
		return new KmArticleDepotReply(articles);
	}

	global class KmArticleDepotReply {
	
		global List<KmArticleDepotReplyDetail> details;	
		
		global KmArticleDepotReply(List<ArticlePDF__c> articlesPdfs) {
			details = new List<KmArticleDepotReplyDetail>();
			
			for(ArticlePDF__c articlePdf : articlesPdfs) {
				details.add(new KmArticleDepotReplyDetail(articlePdf) );
			}
			
		}
	}
	
	global class KmArticleDepotReplyDetail {
	
		public String Id;
		public String ArticleType;
		public String ArticleTypeAPI;
		public String Article_Number;
		public String OrginalArticleId;
		public String OrginalArticleVersionId;
		public String ArticleNumVersion;
		public String VersionNumber;
		public String ArticlePdfContentVersionId;
		public String ArticleHtml;
		public String Title;
		public String Summary;
		
		global KmArticleDepotReplyDetail(ArticlePDF__c articlePdf) {
			Id = articlePdf.Id;
			ArticleType = articlePdf.ArticleType__c;
			ArticleTypeAPI = articlePdf.ArticleTypeAPI__c;
			Article_Number = articlePdf.Article_Number__c;
			OrginalArticleId = articlePdf.OrginalArticleId__c;
			OrginalArticleVersionId = articlePdf.OrginalArticleVersionId__c;
			ArticleNumVersion = articlePdf.ArticleNumVersion__c;
			VersionNumber = String.valueOf(articlePdf.VersionNumber__c);
			ArticlePdfContentVersionId = articlePdf.ArticlePdfContentVersionId__c;
			ArticleHtml = articlePdf.ArticleHtml__c;
			Title = articlePdf.Title__c;
			Summary = articlePdf.Summary__c;  
		}
	}  

}