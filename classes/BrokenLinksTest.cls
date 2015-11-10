/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest 
global class BrokenLinksTest implements HttpCalloutMock {
	
	@IsTest
    public static void testBrokenLinksJob() {
    	// This causes a fake response to be generated
        Test.setMock(HttpCalloutMock.class, new BrokenLinksTest());
    	Test.startTest();
    	//BrokenLinksJob.scheduleBrokenLinkExtractorChecker();
    	BrokenLinksJob.RunBrokenLinksJob();
    	Test.stopTest();
    }
    
    @IsTest
    public static void testScheduleBrokenLinkExtractorChecker() {
    	// This causes a fake response to be generated
        Test.setMock(HttpCalloutMock.class, new BrokenLinksTest());
    	Test.startTest();
    
    	
    	//BrokenLinksJob.scheduleBrokenLinkExtractorChecker();
    	BrokenLinksJob.scheduleBrokenLinkExtractorChecker('Broken Links Job UnitTest');
    	  
    	/*
		BrokenLinksJob blj = new BrokenLinksJob();
		SchedulableContext sc = new SchedulableContext();  	
    	blj.execute(sc);
    	*/
    	
    	Test.stopTest();
    }
      
    @IsTest 
    public static void testJobLastRunTime() {
    	Test.startTest();
     	System.assertEquals(DateTime.newInstance(2000,1,1,0,0,0), BrokenLinksWorker.getJobLastRunTime());
    	DateTime testDateTime = DateTime.now();
    	BrokenLinksWorker.updateJobLastRunTime(testDateTime);
    	System.assertEquals(testDateTime, BrokenLinksWorker.getJobLastRunTime());  
    	System.assertEquals(testDateTime, BrokenLinksWorker.getJobLastRunTime());    
    	Test.stopTest(); 	
    }
    
    @IsTest
    public static void TestGetCustomTextFieldsToCheckforLinks() {
    	List<String>  customTextfields = BrokenLinksWorker.getCustomTextFieldsToCheckForLinks('faq_a__kav');
    	System.Assert(customTextfields.size() > 0);
    	
    }
      
    @IsTest
    public static void testBrokenLinksWorker() {
    	KmArticleTypeModelTest.createTestDataActiveKa();
    	KmArticleTypeTest.createTestData();
    	    	
    	BrokenLinksWorker.updateJobLastRunTime(DateTime.newInstance(2000,1,1,0,0,0));
    	
    	Test.startTest();         	
    	//test scan links
        BrokenLinksWorker.getInstance().findLinks();
        Test.stopTest();   
        
        //sort the links alphabetically with Link__c
        List<LinkValidation__c> links = [
        	select id, Link__c, Link_Type__c, Article_Type_API__c, Article_Number__c 
        	from LinkValidation__c 
        	order by Link__c, Article_Type_API__c
        ];
        
        System.assert(links.size() > 0);
        System.debug('\r\n\r\n');
        
        for (LinkValidation__c link : links) {
        	System.debug ('>>>>>> ' + link.Link__c + ', ' + link.Link_Type__c + ', ' + link.Article_Type_API__c + ', ' + link.Article_Number__c+'\r\n\r\n');
        }  
        
        System.assertEquals('http://intradoc/intradoc/groups/bopp/documents/boppform/bopp-f3400.pdf', links.get(0).Link__c);
        System.assertEquals('Intranet Doc', links.get(0).Link_Type__c);
        System.assertEquals('Collections_Talking_Point__kav', links.get(0).Article_Type_API__c);
               
        System.assertEquals('http://intradoc/intradoc/groups/bopp/documents/boppform/bopp-f3400.pdf', links.get(1).Link__c);
        System.assertEquals('Intranet Doc', links.get(1).Link_Type__c);
        System.assertEquals('Tutorial_A__kav', links.get(1).Article_Type_API__c);

        
        System.assertEquals('http://stellent/intradoc/groups/bopp/documents/boppform/bopp-f3361.pdf', links.get(2).Link__c);
        System.assertEquals('Intranet Doc', links.get(2).Link_Type__c);
        System.assertEquals('Product_Program_A__kav', links.get(2).Article_Type_API__c);
        
        System.assertEquals('http://www.toyotafinancial.com/pub/home/', links.get(3).Link__c);
        System.assertEquals('Internet', links.get(3).Link_Type__c);
        System.assertEquals('How_To_A__kav', links.get(3).Article_Type_API__c);
        
        
        System.Debug('Link 4 - Link__c = ' + links.get(4).Link__c);
        System.assert(links.get(4).Link__c.endsWith('/sfc/#version?selectedDocumentId=069S00000008CPm'));
        System.assertEquals('SF Document', links.get(4).Link_Type__c);
        System.assertEquals('Troubleshooting_A__kav', links.get(4).Article_Type_API__c);
        
        System.Debug('Link 5 - Link__c = ' + links.get(5).Link__c);
        System.assert(links.get(5).Link__c.endsWith('/articles/CollectionPass/Agreement-to-Provide-Insurance-Exists'));
        System.assertEquals('Article', links.get(5).Link_Type__c);
        System.assertEquals('CollectionsPassStrategy__kav', links.get(5).Article_Type_API__c);
        
        System.Debug('Link 6 - Link__c = ' + links.get(6).Link__c);
        System.assert(links.get(6).Link__c.endsWith('/articles/How_To/Agreement-to-Provide-Insurance-Exists'));
        System.assertEquals('Article', links.get(6).Link_Type__c);
        System.assertEquals('FAQ_A__kav', links.get(6).Article_Type_API__c);
        

        
        new BrokenLinksWorker().findLinks();
    }

    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/html');
        res.setBody('OK');
        res.setStatusCode(200);
        return res;
    }



	
	public static void createTestData1() {
		//Add  FAQ article
        FAQ_A__kav faq1 = new FAQ_A__kav(Escalation_Notes__c = 'This is test FAQ 1 to be used in controller search function testing. <a href="/articles/How_To/Agreement-to-Provide-Insurance-Exists">Click here.</a>. There are some instructions in this article.', 
    							     Internal_Notes__c = 'Testing FAQ 1 - Instruction',
    								 Language = 'en_US', Title = 'Test FAQ 1', UrlName = 'TestFAQ1');
    	insert (faq1);
    	faq1 = [select KnowledgeArticleId from FAQ_A__kav where id = :faq1.id];
    	System.debug('>>>>>>>>' + faq1.knowledgeArticleId + '<<<<<<<<');
    	System.assert(faq1.knowledgeArticleId <> null );
    	KbManagement.PublishingService.publishArticle(faq1.knowledgeArticleId, true);		
	}


}