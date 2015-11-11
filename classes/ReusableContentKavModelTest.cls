@IsTest
public class ReusableContentKavModelTest {

	@IsTest
	public static void unitTest() {
		
		KmArticleTypeTest.createTestData();
		KmArticleTypeModelTest.createTestDataActiveKa();
		id rcId = createData();
		
		List<String> kavApiNames = KmArticleTypeModel.activeKavApiNames;	
		System.Assert(kavApiNames.size() > 0);
		
		Test.startTest();
		ReusableContentKavModel.updateArticlesAssociatedWithThisContentTag(rcId);
		ReusableContentKavModel.findReusableContentArticleForTag(rcId);
		
		ReusableContentKavModel.createReusableContentArticleJuntion('Testing', rcId);
		
		
		ReusableContentKavModel.reindexAllReusableContentTags();
		ReusableContentKavModel.startReusableContentIndexBatch();
		
		
		List<KmSearchModel.FindKavResult> articles = (new KmSoqlSearchModel()).SearchArticles('Testing');
		System.assertNotEquals(null, articles);
		System.assert(articles.size() > 0);
		ReusableContentKav__c rcKav = ReusableContentKavModel.createReusableContentKav(articles[0],rcId,'Testing');
		
		List<ReusableContentKav__c> rcKavList = new List<ReusableContentKav__c>();
		rcKavList.add(rcKav);
		
		ReusableContentKavModel.updateDraftVersionURL(rcKavList);
		Test.stopTest();
		
	}
	  
	
	public static Id createData() {
		Reusable_Content__c rc = new Reusable_Content__c();
		rc.Title__c = 'test';
		insert rc;
		
		return rc.id;
	}
}