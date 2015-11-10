@IsTest
public class KmWebServicesTest {

	@IsTest
	public static void KmArticleWebServiceTest() {

		KmArticleTypeTest.createTestData();
		string articleType = 'FAQ_A__kav';
		string publishStatus = 'Online';
		string  articleRef = '1234';
		
		
		KmArticleWebService.KmArticleWebServiceReply reply = KmArticleWebService.post(articleType, articleRef, publishStatus);
		
		//this is unit test - this statement will not delete data
		KmArticleWebService.deleteAllArticleDepotPdf();
	}

	@IsTest
	public static void TestKmArticleWebServiceReply() {  
		
		ArticlePDF__c a = new ArticlePDF__c();
		KmArticleWebService.KmArticleWebServiceReply reply = new KmArticleWebService.KmArticleWebServiceReply(a);
	}   


	@IsTest
	public static void EchoWebServiceTest() {
		string msg = 'Hello World';
		System.assertEquals(msg, EchoWebService.post(msg));
	}

	@IsTest(SeeAllData=true)
	public static void KmArticleDepotWebServiceTest() {
		KmArticleDepotWebService.KmArticleDepotReply reply = KmArticleDepotWebService.post();
		System.AssertNotEquals(null, reply);
	}
	
  
	@IsTest
	public static void KmPrintWebServiceTest() {
		
		id binderId = PrintWebServiceCreateData();
		
		//then create the printjob
		PrintJob__c pj = new PrintJob__c();
		pj.binder__c = binderId;
		insert pj;
		
		pj = [select name from PrintJob__c where id = :pj.id];
		System.assertNotEquals(null, pj.name);
		
		KmPrintWebService.post(pj.name, 'Online', true, 0, 0);
		KmPrintWebService.patch(pj.name,'outputURL','This is the title');
	}

	public static id PrintWebServiceCreateData() {
		//create the binder
		Binder__c binder = new Binder__c();	
		insert binder;
		
		//now insert the page
		List<BinderPage__c> pages = new List<BinderPage__c>();
		return binder.id;
	}
	
	
	@IsTest
	public static void TestKmPrintWebServiceReplyDetail() {
		BinderPage__c page = new BinderPage__c();
		
		KmPrintWebService.KmPrintWebServiceReplyDetail detail = new KmPrintWebService.KmPrintWebServiceReplyDetail(page);
	}
	
	


	@IsTest
	public static void KmValidateLinksWebServiceTest() {
		
		ValidateLinkCreateData();
		
		KmValidateLinksWebService.KmValidateLinksWebServieReply postReply = KmValidateLinksWebService.post();
		System.AssertNotEquals(null,postReply);
		
		List<String> brokenLinkIds = new List<String>();
		List<String> connectionRefusedIds = new List<String>();
		for(KmValidateLinksWebService.KmValidateLinksWebServieReplyDetail detail : postReply.details) {
			if ( connectionRefusedIds.size() == 0) {
				connectionRefusedIds.add(detail.validateLinkId);
			} else {
				brokenLinkIds.add(detail.validateLinkId);
			}
		}
		
		
		KmValidateLinksWebService.patch(brokenLinkIds,connectionRefusedIds);
	
	}
	
	public static void ValidateLinkCreateData() {
		List<LinkValidation__c > lvSet = new List<LinkValidation__c >();
		
		ValidateLinkCreateDataDetails(lvSet,'Internet','test1','http://www.google.com');
		ValidateLinkCreateDataDetails(lvSet,'SF Document','test2','http://www.google.com');
		
		insert lvSet;
	}
	
	private static void ValidateLinkCreateDataDetails(List<LinkValidation__c > lvSet, String LinkType, String LinkLabel, String link) {
		LinkValidation__c lv = new LinkValidation__c();
		lv.Link_Type__c = LinkType;
		lv.Article_Type_Label__c = LinkLabel;
		lv.Link__c = link;
		lvSet.add(lv);	
	}
	
	
}