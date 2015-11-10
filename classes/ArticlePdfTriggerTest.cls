@IsTest
public with sharing class ArticlePdfTriggerTest {

	@IsTest
	public static void unitTest() {
		ContentVersion cv = new ContentVersion();
		cv.Title = 'test content';
		cv.PathOnClient = '/tmp/testContent.docx';
		cv.VersionData = EncodingUtil.base64Decode('asdfasdfasdfasdfasdfadsfdas');
		insert cv;
		
		ArticlePDF__c aPdf = new ArticlePDF__c();
		aPdf.ArticleNumVersion__c = 'adfsad';
		aPdf.ArticleType__c='dfasd';
		aPdf.Article_Number__c='1234';
		aPdf.FirstPublishedDate__c=Date.Today();
		aPdf.OrginalArticleId__c='123123123';
		aPdf.OrginalArticleVersionId__c='123123';
		aPdf.PublishStatus__c='Online';
		aPdf.Title__c='asdfasafsdf';
		aPdf.VersionNumber__c = 4;
		
		
		insert aPdf;
		
		aPdf.ArticlePdfContentVersionId__c = cv.id;
		update aPdf;
		
		
	}

}