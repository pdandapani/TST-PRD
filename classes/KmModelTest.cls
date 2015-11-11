@IsTest
public class KmModelTest {
	@IsTest
	public static void TestGetAllPublishedArticles() {
		List<KnowledgeArticleVersion> kavs = KmModel.getAllPublishedArticles();
		System.assertNotEquals(null,kavs);
	}
	
	@IsTest
	public static void TestGetArticleNumVersion() {
		//good case
		String result1 = KmModel.getArticleNumVersion('000001234', 12);
		System.assertEquals('000001234:000012', result1);
		
		//edge case
		String result2 = KmModel.getArticleNumVersion('000000000', -1);
		System.assertEquals('000000000:0000-1', result2);
	
		//bad case - will cause exception
		String result3 = KmModel.getArticleNumVersion('000001234', 1234567);
		System.assertEquals('000001234:1234567', result3);	
	}
}