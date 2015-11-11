@IsTest
public class KmSoslSearchModelTest {

	@IsTest
	public static void TestSearchArticles() {
		
		KmArticleTypeTest.createTestData();
		KmArticleTypeModelTest.createTestDataActiveKa();
		
		List<KmSearchModel.FindKavResult> articles = (new KmSOSLSearchModel()).SearchArticles('*function*');

	}
	
	//KmSoslSearchModel.testFind();
	public static void testFind() {
		
		String queryStr = 'Find \'*div*\' IN ALL FIELDS RETURNING ' +
			'how_to_a__kav (process_steps__c WHERE PublishStatus = \'Online\' AND Language = \'en_US\')'; //', ' +
			//'faq_a__kav (answer__c WHERE PublishStatus = \'Online\' AND Language = \'en_US\'), ' ;
		
		//String queryStr = 'Find \'tfs\' IN ALL FIELDS RETURNING user(name) '; 
		
		System.Debug(queryStr);
		List<List<sObject>> myQueryResult = search.query(queryStr);
		
		
	}

	//KmSoslSearchModel.testFind2();
	public static void testFind2() {
		
		String queryStr = 'Find \'*div*\' IN ALL FIELDS RETURNING ' +
			'how_to_a__kav (process_steps__c WHERE PublishStatus = \'Online\' AND Language = \'en_US\'), ' +
			'faq_a__kav (answer__c WHERE PublishStatus = \'Online\' AND Language = \'en_US\') ' ;
	
		
		System.Debug(queryStr);
		List<List<sObject>> myQueryResult = search.query(queryStr);
		
		
	}
}