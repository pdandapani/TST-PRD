@IsTest
public class ArticleFeedbackModelTest {

	@IsTest
	public static void unitTest() {
		KmArticleTypeTest.createTestData();
	
		List<knowledgeArticle> kaList = [
			select id
			from knowledgeArticle
		];
		
		
		List<Id> inputIds = new List<Id>();
		for(knowledgeArticle ka : kaList){
			inputIds.add(ka.id);
		}
			
		Map<Id, ArticleFeedbackModel.kavDetails> kavDetailsMap = ArticleFeedbackModel.FindKnowledgeArticleDetails(inputIds);
		
		for(Id kavId : inputIds) {
			System.assertNotEquals(null, kavDetailsMap.get(kavId));
			
			System.Debug(kavDetailsMap.get(kavId).toString());
			
			
			ArticleFeedbackModel.kavDetails articleDetail = kavDetailsMap.get(kavId);
			System.Debug(articleDetail.articleTitle);
		} 
	}  
	
	
}