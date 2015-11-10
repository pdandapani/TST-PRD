@IsTest
public class ReusableContentUpdateModelTest {

	@IsTest
	public static void UnitTest(){
		Id tagId = ReusableContentKavModelTest.createData();
		
		KmArticleTypeTest.createTestData();
		KmArticleTypeModelTest.createTestDataActiveKa();
		
		List<String> kavApiNames = KmArticleTypeModel.activeKavApiNames;	
		System.Assert(kavApiNames.size() > 0);
		
		ReusableContentUpdateModel.UpdateArticlesFromAllTags();
		ReusableContentUpdateModel.UpdateArticlesByTag(tagId);
	}

	@IsTest
	public static void TestReplacement1() {
		//create reusable content
		Reusable_Content__c rc = new Reusable_Content__c();
		rc.Description__c = 'This is a piece of test content';
		insert rc;		
		rc = [select name from Reusable_Content__c where id = :rc.id];
		
		System.Debug('Content tag = '+rc.name);
		
		FAQ_A__kav faq1 = new FAQ_A__kav(
        	Escalation_Notes__c = 'escalaction_Note <div id="' +rc.name+'"></div>. a bit of test after', 
    		Internal_Notes__c = 'Testing FAQ 1 - Instruction',
    		Language = 'en_US', Title = 'Test FAQ 1', UrlName = 'TestFAQ1');
    	insert (faq1);
    	faq1 = [select id, KnowledgeArticleId from FAQ_A__kav where id = :faq1.id];
    	
    	Set<Id> kavIds= new Set<Id>();
    	kavIds.add(faq1.id);
    	boolean toPublishDraft = false;
    	boolean toSubmitForApproval = false;
    	
    	Test.startTest();
		ReusableContentUpdateModel.ReplaceContent('faq_a__kav', kavIds, toPublishDraft);
		Test.stopTest();
		
		FAQ_A__kav faq2 = [
			select Escalation_Notes__c, Internal_Notes__c
			from FAQ_A__kav
			where id = :faq1.id
		];
		
		System.Debug(faq2.Escalation_Notes__c);
	}
	
	@IsTest
	public static void TestCreateDraftAndReplaceContentFuture() {
		KmArticleTypeTest.createTestData();
		KmArticleTypeModelTest.createTestDataActiveKa();
		
		List<SObject> objects = [
			select  id, knowledgeArticleId 
			from FAQ_A__kav
			where PublishStatus = 'Online'
			and Language = 'en_US'
		];  
		
		Set<Id> kaIds = new Set<Id>();
  		for (SObject kav : objects) {
  			kaIds.add((Id)kav.get('knowledgeArticleId'));
  		}
		
		ReusableContentUpdateModel.CreateDraftAndReplaceContentFuture('FAQ_A__kav',kaIds,true);
		
	}
	
	
	@IsTest
	public static void TestSortOnlineArticlesForChange() {
		createArticlesForSort();
		
		Map<String, ReusableContentKav__c> rckMapForOnline = new Map<String, ReusableContentKav__c>();
		
		Test.startTest();
		Map<String, List<ReusableContentKav__c>> mapOfListOfOnlineArticles = ReusableContentUpdateModel.sortKnowledgeArticleByType(rckMapForOnline);
		ReusableContentUpdateModel.sortOnlineArticlesForChange(mapOfListOfOnlineArticles);
		Test.stopTest();
		
	}	
	
	public static void createArticlesForSort() {
		
	}
}