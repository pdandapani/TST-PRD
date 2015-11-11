/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  Unit Test for ArticleDepotModel
*  
**/
@isTest
public class ArticleDepotModelTest {

	@IsTest
	public static void TestScheduleArticleDepotJob() {
		ArticleDepotJob.scheduleArticleDepotJob('ArticleDepotJobUnitTest');
	}
 
	@isTest
	public static void testArticleDepotModel() {
		
		List<FAQ_A__kav> insertedFaqs = createData();
   		
		Test.startTest();
	
   		boolean unpublishArticle = true;
		String editingDraftId = KbManagement.PublishingService.editOnlineArticle(insertedFaqs[0].KnowledgeArticleId, unpublishArticle);
		
		FAQ_A__kav editingDraft = [
			SELECT Title, Id, KnowledgeArticleId, PublishStatus, VersionNumber 
			FROM FAQ_A__kav 
			where id =:editingDraftId
		];
		
		//system.assertequals(insertedFaqs[0].KnowledgeArticleId,editingDraftId);
		boolean publishAsMajorVersion = true;
		KbManagement.PublishingService.publishArticle(editingDraft.KnowledgeArticleId, publishAsMajorVersion);	
   		
		System.AssertEquals(13, ArticleDepotModel.copyToDepot()); 
		
		
		ArticleDepotModel.copyToDepot(2000);
		Test.stopTest();
		
		  
	}
	
	public static List<FAQ_A__kav> createData() {
		//setup KmArticleType Object
		KmArticleTypeModelTest.createTestDataActiveKa();
    	KmArticleTypeTest.createTestData();
	
		ArticleDepotModel.clearDepot('ReallyWantToClear');
		
		//Create Data
 		Set<id> faqIds = new Set<id>();
 		List <FAQ_A__kav> faqs = new List<FAQ_A__kav>();
      	for(integer i = 0; i<5; i++) {
         	FAQ_A__kav faq = new FAQ_A__kav(
               	Title = 'FAQ Article '+i,
				UrlName = 'faq-article'+i
			); 
        	faqs.add(faq);
      	}
   		insert faqs;
   		
   		for(FAQ_A__kav faqKav : faqs) {
   			faqIds.add(faqKav.Id);
   		}
   		
   		List<FAQ_A__kav> insertedFaqs = [
   			SELECT Title, Id, KnowledgeArticleId, PublishStatus, VersionNumber 
   			FROM FAQ_A__kav 
   			where id in :faqIds
   		];
   		
   		
   		boolean publishAsMajorVersion = true;
   		for(FAQ_A__kav insertedFaq : insertedFaqs) {
   			KbManagement.PublishingService.publishArticle(insertedFaq.KnowledgeArticleId, publishAsMajorVersion);
   		}
   		
   		return insertedFaqs;
	}
	
	public static void createTestDataActiveKa() {
		List<String> activeKaApiNames = new List<String>();
		activeKaApiNames.add('FAQ_A__ka');
		activeKaApiNames.add('CollectionsPassStrategy__ka');
		activeKaApiNames.add('How_To_A__ka');
		activeKaApiNames.add('Product_Program_A__ka');
		activeKaApiNames.add('Tutorial_A__ka');
		activeKaApiNames.add('Collections_Talking_Point__ka');
		activeKaApiNames.add('Troubleshooting_A__ka');
		activeKaApiNames.add('Reference_A__ka');
		
    	KmArticleTypeModel.refreshKaTypeObject();
    	KmArticleTypeModelTest.markKaTypeObjectsActive(activeKaApiNames);		
	}
}