@IsTest
public class KmSoqlSearchModelTest {

	@IsTest
	public static void TestSearchArticles() {
		
		KmArticleTypeTest.createTestData();
		KmArticleTypeModelTest.createTestDataActiveKa();
		
		List<String> kavApiNames = KmArticleTypeModel.activeKavApiNames;	
		System.Assert(kavApiNames.size() > 0);
		
		List<KmSearchModel.FindKavResult> articles = (new KmSoqlSearchModel()).SearchArticles('Testing');
		System.AssertNotEquals(null, articles);
		System.Assert(articles.size() > 0);
	}
	
	@IsTest
	public static void TestFindKavResult() {
		
		KmArticleTypeTest.createTestData();
		
		List<FAQ_A__kav> faqs = [
			select Title, Id, PublishStatus, ArticleType, ArticleNumber, KnowledgeArticleId, VersionNumber, Language
			from FAQ_A__kav
			where PublishStatus = 'Online' 
			and Language = 'en_US'
			limit 1
		];
		
		KmSearchModel.FindKavResult fkr = new KmSearchModel.FindKavResult(faqs[0], 'test', 'test2');
		System.AssertNotEquals(null, fkr);
	}
}