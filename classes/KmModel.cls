public with sharing class KmModel {


	public static List<KnowledgeArticleVersion> getAllPublishedArticles() {
		List<KnowledgeArticleVersion> kavs = [
			SELECT Id, PublishStatus, ArticleType, ArticleNumber, KnowledgeArticleId, Title, VersionNumber, Language
			FROM KnowledgeArticleVersion
			WHERE (PublishStatus = 'online' and Language = 'en_US')
		];
		return kavs;
	}

	public static String getArticleNumVersion(sObject obj) {
		return getArticleNumVersion((String)obj.get('ArticleNumber'), (Integer)obj.get('VersionNumber'));
	}
	public static String getArticleNumVersion(String articleNumber, Decimal versionNumber) {
		return getArticleNumVersion(articleNumber, Integer.ValueOf(versionNumber));
	}
	
	//add padding to versionNumber to create an articleNumber / versionNumber key
	//articleNumber will not be padded only the versionNumber will be padded
	//articleNumber will be padded by Salesforce
	public static String getArticleNumVersion(String articleNumber, Integer versionNumber) {
		
		String paddingSeed = '0';    
		String padding = ''; 
		
		try {  
			Integer paddingLength = 6-((String.ValueOf(versionNumber)).length());
			padding = paddingSeed.repeat(paddingLength);
		} catch (Exception ex) {
			System.Debug('*****  Exception in getArticleNumVersion '+articleNumber+'  '+ versionNumber);
		}  
		return articleNumber + ':' + padding+ versionNumber;
	}

}