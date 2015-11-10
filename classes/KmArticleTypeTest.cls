@IsTest
public class KmArticleTypeTest {
	
	@IsTest
	public static void TestArticleType() {
		createTestData();
	}
	
	public static void createTestData() {
		    	
		//Add  FAQ article
        FAQ_A__kav faq1 = new FAQ_A__kav(
        	Escalation_Notes__c = 'This is test FAQ 1 to be used in controller search function testing. <a href="/articles/How_To/Agreement-to-Provide-Insurance-Exists">Click here.</a>. There are some instructions in this article.', 
    		Internal_Notes__c = 'Testing FAQ 1 - Instruction',
    		Language = 'en_US', Title = 'Test FAQ 1', UrlName = 'TestFAQ1');
    	insert (faq1);
    	faq1 = [select KnowledgeArticleId from FAQ_A__kav where id = :faq1.id];
    	System.debug('>>>>>>>>' + faq1.knowledgeArticleId + '<<<<<<<<');
    	System.assert(faq1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(faq1.knowledgeArticleId, true);
    	System.assert([select id from FAQ_A__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);
    	
    	//Add 2 Collections Pass Strategy articles
    	CollectionsPassStrategy__kav cps1 = new CollectionsPassStrategy__kav(
    		Details__c = 'This is test Collections Pass Strategy 1 to be used in controller search function testing. <a href="/articles/CollectionPass/Agreement-to-Provide-Insurance-Exists">Click here.</a>There are some instructions in this article.', 
    		Summary = 'Testing Collections Pass Strategy 1 - Instruction',
    		Language = 'en_US', Title = 'Test Collections Pass Strategy 1', UrlName = 'TestCollectionsPassStrategy1');
    	insert (cps1);
    	cps1 = [select knowledgeArticleId from CollectionsPassStrategy__kav where id = :cps1.id];
    	System.assert(cps1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(cps1.knowledgeArticleId, true);
		System.assert([select id from CollectionsPassStrategy__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);

		//Add 2 How To articles
        How_To_A__kav ht1 = new How_To_A__kav(
        	Process_Steps__c = 'This is test How To 1 to be used in controller search function testing. <a href="http://www.toyotafinancial.com/pub/home/">Click here.</a>There are some instructions in this article.', 
			Key_Information__c = 'Testing How To 1 - Instruction',
			Language = 'en_US', Title = 'Test How To 1', UrlName = 'TestHowTo1');
    	insert (ht1);
    	ht1 = [select KnowledgeArticleId from How_To_A__kav where id = :ht1.id];
    	System.assert(ht1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(ht1.knowledgeArticleId, true);
    	System.assert([select id from How_To_A__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);

		//Add Product Description
        Product_Program_A__kav pd1 = new Product_Program_A__kav(
        	Description__c = 'This is test Product Description 1 to be used in controller search function testing. <a href="http://stellent/intradoc/groups/bopp/documents/boppform/bopp-f3361.pdf">Click here.</a>There are some instructions in this article.', 
			Escalation_Notes__c = 'Testing Product Description 1 - Instruction',
			Language = 'en_US', Title = 'Test Product Description 1', UrlName = 'TestProductDescription1');
    	insert (pd1);
    	pd1 = [select KnowledgeArticleId from Product_Program_A__kav where id = :pd1.id];
    	System.assert(pd1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(pd1.knowledgeArticleId, true);
    	System.assert([select id from Product_Program_A__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);

		//Add Tutorial
        Tutorial_A__kav tut1 = new Tutorial_A__kav(
        	Details__c = 'This is test Tutorial 1 to be used in controller search function testing. <a href="http://intradoc/intradoc/groups/bopp/documents/boppform/bopp-f3400.pdf">Click here.</a> There are some instructions in this article.', 
    		Key_Information__c = 'Testing Tutorial 1 - Instruction',
    		Language = 'en_US', Title = 'Test Tutorial 1', UrlName = 'TestTutorial1');
    	insert (tut1);
    	tut1 = [select KnowledgeArticleId from Tutorial_A__kav where id = :tut1.id];
    	System.assert(tut1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(tut1.knowledgeArticleId, true);
    	System.assert([select id from Tutorial_A__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);
		    	  
		//Add Collections Talking Point
        Collections_Talking_Point__kav ctp1 = new Collections_Talking_Point__kav(
        	Details__c = 'This is test CTP 1 to be used in controller search function testing. <a href="http://intradoc/intradoc/groups/bopp/documents/boppform/bopp-f3400.pdf">Click here.</a>There are some instructions in this article.', 
    		Summary = 'Testing CTP 1 - Instruction',
    		Language = 'en_US', Title = 'Test CTP 1', UrlName = 'TestCTP1');
    	insert (ctp1);
    	ctp1 = [select KnowledgeArticleId from Collections_Talking_Point__kav where id = :ctp1.id];
    	System.assert(ctp1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(ctp1.knowledgeArticleId, true);
    	System.assert([select id from Collections_Talking_Point__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);
		    	
		//Add Troubleshooting
        Troubleshooting_A__kav trb1 = new Troubleshooting_A__kav(
        	Cause_Solution__c = 'This is test Troubleshooting 1 to be used in controller search function testing. <a href="https://cs1.salesforce.com/sfc/#version?selectedDocumentId=069S00000008CPm">Click here.</a>There are some instructions in this article.', 
    		Escalation_Notes__c = 'Testing Troubleshooting 1 - Instruction',
    		Language = 'en_US', Title = 'Test Tutorial 1', UrlName = 'TestTroubleshooting1');
    	insert (trb1);
    	trb1 = [select KnowledgeArticleId from Troubleshooting_A__kav where id = :trb1.id];
    	System.assert(trb1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(trb1.knowledgeArticleId, true);
    	System.assert([select id from Troubleshooting_A__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);
		    	
		//Add Reference
        Reference_A__kav ref1 = new Reference_A__kav(
        	Details__c = 'This is test Reference 1 to be used in controller search function testing. <a href="/articles/How_To/Locate-Damage-Vehicle-and-Customer-s-Insurance-Carrier">Click here.</a>There are some instructions in this article.', 
    		Escalation_Notes__c = 'Testing Reference 1 - Instruction',
    		Language = 'en_US', Title = 'Test Reference 1', UrlName = 'TestReference1');
    	insert (ref1);
    	ref1 = [select KnowledgeArticleId from Reference_A__kav where id = :ref1.id];
    	System.assert(ref1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(ref1.knowledgeArticleId, true);
    	System.assert([select id from Reference_A__kav  where PublishStatus = 'Online' and Language = 'en_US' ].size() > 0);
    	
    	System.Debug('\r\n\r\n completed test data setup \r\n\r\n');
	}
}