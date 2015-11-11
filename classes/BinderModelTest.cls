/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  Unit Test for BinderModel
*
**/
@IsTest
public class BinderModelTest {

	public static String testBinderId1 = null;
	public static String testBinderId1a = null;
	public static String testBinderId2 = null;
	public static String testBinderIdInvalid = null;

	@IsTest
	public static void TestGetBinderById() {
		createData();
		Test.StartTest();
		
		System.assertEquals(null, BinderModel.getBinderById(null));
		
		System.assertNotEquals(null, testBinderId1);
		Binder__c binder = BinderModel.getBinderById(testBinderId1);
		System.assertNotEquals(null, binder);
		
		System.assert(BinderModel.getAllBinderPagesPrint1(testBinderId1).size() > 0);
		System.assert(BinderModel.getAllBinderPagesPrint2(testBinderId1).size() > 0);
		
		BinderModel.clearAllBinderPages(testBinderId1);
		System.assert(BinderModel.getAllBinderPagesPrint1(testBinderId1).size() == 0);
		System.assert(BinderModel.getAllBinderPagesPrint2(testBinderId1).size() == 0);
	
		testBinderId1 = null;  // all pages deleted. reset createData

		Test.StopTest();
	}
	
	@IsTest
	public static void TestOrderBy() {
		createData();
		Test.StartTest();
		BinderPageFilter2.OrderByArticleNumVersionThenTitleForDeskGuides(testBinderId1);
		BinderPageFilter2.OrderByKnowledgeContainerArticleNumVersion(testBinderId1);
		BinderPageFilter2.OrderByFoppArticleNumVersion(testBinderId1);
		BinderPageFilter2.OrderByArticleTypeNumberVersionDesc(testBinderId1);
		BinderPageFilter2.OrderByPublishedDate(testBinderId1);
		
		Test.StopTest();
	}
	
	@IsTest
	public static void TestWebServices() {
		createData();
		BinderPageFilter2.ClearAllBinderPages(testBinderId1);
		BinderPageFilter2.RenumberAllBinderPages(testBinderId1);
	}
	
	@IsTest
	public static void TestUtils() {
		Set<id> ids = new Set<id>();
		Set<String> names = new Set<String>();
		
		for(User u : [select id from user limit 5]) {
			ids.add(u.id);
			names.add(u.id);
		}

		Test.StartTest();
		BinderPageFilter2.getDateTimeEOD(Date.today());
		BinderPageFilter2.getDateTimeEOD(null);
		BinderPageFilter2.idSetToString(ids);
		BinderPageFilter2.stringSetToString(names);
		
		Test.StopTest();  
	}
	
	@IsTest 
	public static void TestBinderTrigger() {
		createData();
		List<Binder__c> binders = [ select id from Binder__c];
		delete binders;
	}
	  
	
	@IsTest
	public static void TestProcessPrintJob() {
		createData();
		
		PrintJob__c job = new PrintJob__c();
		job.Binder__c = testBinderId1;
		insert job;
		
		//@future(callout=true)
		BinderModel.processPrintJob('PJ-0000000');		
	}
	
	// unit test for BinderPageFilter2
	@IsTest
	public static void TestQueryForArticles() {
		CreateData();
		BinderPageFilter2.QueryForArticles(null);
		BinderPageFilter2.QueryForArticles(testBinderId1);
		BinderPageFilter2.QueryForArticles(testBinderId1a);
		BinderPageFilter2.QueryForArticles(testBinderId2);
		BinderPageFilter2.QueryForArticles(testBinderIdInvalid);
	}
	
	
	public static void createData() {
		KnowledgeContainer__c kc = createKnowledgeContainer();
		createDataBinder1(kc);
		createDataBinder1a(kc);
		createDataBinder2(kc);
		createDataBinderInvalid(kc);
	}
	
	public static KnowledgeContainer__c createKnowledgeContainer() {
		KnowledgeContainer__c kc = new KnowledgeContainer__c();
		kc.containername__c = 'testContainer';
		insert kc;
		return kc;
	}
	
	
	//no children / archived
	public static void createDataBinder1(KnowledgeContainer__c kc) {
		if (testBinderId1 <> null ) {
			return;
		}
		
		// 1 - create binder
		Binder__c binder = new Binder__c();
		binder.Article_Type__c = 'FAQ_A__kav';
		binder.Comment__c = 'Test Binder';
		binder.FOPP__c = '1';
		binder.From_Date__c = Date.today().addMonths(-1);
		binder.To_Date__c = Date.today();
		binder.Knowledge_Container__c = kc.id;
		binder.Include_children__c = false;
		binder.Include_Archived__c = false;
		
		binder.RecordTypeId = RecordTypeModelKm.BinderPrint1RecTypeId;
		insert binder;
		
		System.assert(binder.id <> null);
		testBinderId1 = binder.id;
		
		// 2 - create binder pages
		List<BinderPage__c> pages = new List<BinderPage__c>();
		
		BinderPage__c page1 = new BinderPage__c();
		pages.add(page1);
		page1.Binder__c = testBinderId1;
		page1.Title__c = 'Title1';
		
		BinderPage__c page2 = new BinderPage__c();
		pages.add(page2);
		page2.Binder__c = testBinderId1;
		page2.Title__c = 'Title2';
		
		BinderPage__c page3 = new BinderPage__c();
		pages.add(page3);
		page3.Binder__c = testBinderId1;
		page3.Title__c = 'Title3';
		
		
		insert pages;
		
	}
	
	//include children / archived
	public static void createDataBinder1a(KnowledgeContainer__c kc) {
		if (testBinderId1a <> null ) {
			return;
		}
		
		// 1 - create binder
		Binder__c binder = new Binder__c();
		binder.Article_Type__c = 'FAQ_A__kav';
		binder.Comment__c = 'Test Binder';
		binder.FOPP__c = '1a';
		binder.From_Date__c = Date.today().addMonths(-1);
		binder.To_Date__c = Date.today();
		binder.Knowledge_Container__c = kc.id;
		binder.Include_children__c = true;
		binder.Include_Archived__c = true;
		
		binder.RecordTypeId = RecordTypeModelKm.BinderPrint1RecTypeId;
		insert binder;
		
		System.assert(binder.id <> null);
		testBinderId1a = binder.id;
		
		// 2 - create binder pages
		List<BinderPage__c> pages = new List<BinderPage__c>();
		
		BinderPage__c page1 = new BinderPage__c();
		pages.add(page1);
		page1.Binder__c = testBinderId1;
		page1.Title__c = 'Title1';
		
		BinderPage__c page2 = new BinderPage__c();
		pages.add(page2);
		page2.Binder__c = testBinderId1;
		page2.Title__c = 'Title2';
		
		BinderPage__c page3 = new BinderPage__c();
		pages.add(page3);
		page3.Binder__c = testBinderId1;
		page3.Title__c = 'Title3';
		
		
		insert pages;
		
	}
	
	public static void createDataBinder2(KnowledgeContainer__c kc) {
		
		if (testBinderId2 <> null) {
			return;
		}
		
		Binder__c binder2 = new Binder__c();
		binder2.Article_Type__c = 'FAQ__kav';
		binder2.Comment__c = 'Test Binder2';
		binder2.FOPP__c = '2';
		binder2.From_Date__c = Date.today().addMonths(-1);
		binder2.To_Date__c = Date.today();
		binder2.RecordTypeId = RecordTypeModelKm.BinderPrint2RecTypeId;
		insert binder2;
		
		System.assert(binder2.id <> null);
		testBinderId2 = binder2.id;
		
		// 2 - create binder pages
		List<BinderPage__c> pages = new List<BinderPage__c>();
		
		BinderPage__c page1 = new BinderPage__c();
		pages.add(page1);
		page1.Binder__c = testBinderId2;
		page1.Title__c = 'Title1';
		
		BinderPage__c page2 = new BinderPage__c();
		pages.add(page2);
		page2.Binder__c = testBinderId2;
		page2.Title__c = 'Title2';
		
		BinderPage__c page3 = new BinderPage__c();
		pages.add(page3);
		page3.Binder__c = testBinderId2;
		page3.Title__c = 'Title3';
		
		
		insert pages;
	}
	
	
	public static void createDataBinderInvalid(KnowledgeContainer__c kc) {
		
		if (testBinderIdInvalid <> null) {
			return;
		}
		
		Binder__c binder3 = new Binder__c();
		binder3.Article_Type__c = 'FAQ__kav';
		binder3.Comment__c = 'Test BinderInvalid';
		binder3.FOPP__c = '2';
		binder3.From_Date__c = Date.today().addMonths(-1);
		binder3.To_Date__c = Date.today();
		binder3.RecordTypeId = RecordTypeModelKm.BinderPrint2RecTypeId;
		insert binder3;
		
	}
	
	@IsTest
	public static void utilTest() {
		List<User> users = [select id from user limit 5];
		Set<Id> ids = new Set<Id>();
		for(User u : users) {
			ids.add(u.id);
		}
		
		String idAsString = BinderPageFilter2.idSetToString(ids);
		System.assertNotEquals(null, idAsString);
		
		System.assertNotEquals(null, BinderPageFilter2.getDateTime(Date.Today()));
		System.assertEquals('', BinderPageFilter2.getDateTime(null));
		
		
	}
	
}