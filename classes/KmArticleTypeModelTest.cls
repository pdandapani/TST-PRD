/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  Unit Tests for KmArticleTypeModel   
*
**/
@IsTest
public class KmArticleTypeModelTest {

	@IsTest
	public static void TestAllArticleTypes() {
		System.assert(KmArticleTypeModel.globalDescribeSObjects.size() > 0);
		System.assert(KmArticleTypeModel.knowledgeArticleVersionsMap.size() > 0);
		System.assert(KmArticleTypeModel.knowledgeArticleTypesMap.size() > 0);
		
		
		System.assert(KmArticleTypeModel.allArticleTypesApiNames.size() > 0);
		System.debug(KmArticleTypeModel.allArticleTypesApiNames);
		
		System.assert(KmArticleTypeModel.allArticleTypeLabels.size() > 0);
		System.debug(KmArticleTypeModel.allArticleTypeLabels);		
		System.assert(KmArticleTypeModel.articleDepotCustomFields.size() > 0);		
		
		KmArticleType__c testKaType = new KmArticleType__c();
		testKaType.ArticleTypeLabel__c = 'label';
		testKaType.ArticleTypeApiName__c = 'testApiName';
		testKaType.isActive__c = true;
		
		insert testKaType;
		System.assert(KmArticleTypeModel.activeKaApiNames.size() > 0);
		
	}  
	
	@IsTest
	public static void TestRefresh() {
		KmArticleTypeModel.refreshKaTypeObject();
	}
	
	@IsTest
	public static void TestArticleDepot() {
		System.assert(KmArticleTypeModel.articleDepotSchemaObj <> null);
		System.assert(KmArticleTypeModel.articleDepotCustomFields.size() > 0);
		
		for(String fieldName : KmArticleTypeModel.articleDepotCustomFields) {
			System.Debug(fieldName);
		}
	}   
	
	@IsTest
	public static void TestKnowledgeArticleVersionsMap(){
		Map<String, Schema.SObjectType> kavMap = KmArticleTypeModel.knowledgeArticleVersionsMap;
		
		for(String kavApiName : kavMap.keySet()) {
			System.Debug(kavApiName);
			System.assert(kavMap.get(kavApiName) <> null);
		}
	}
	
	@IsTest
	public static void TestGetArticleTypeCustomFields() {
		createTestDataActiveKa();
		for(String activeKaApiName : activeKaApiNames) {
			System.Assert(KmArticleTypeModel.getArticleTypeCustomFields(activeKaApiName+'v').size() > 0 );
		}
	}
	

	public static List<String> activeKaApiNames {
		get {
			List<String> activeKaApiNames = new List<String>();
			activeKaApiNames.add('FAQ_A__ka');
			activeKaApiNames.add('CollectionsPassStrategy__ka');
			activeKaApiNames.add('How_To_A__ka');
			activeKaApiNames.add('Product_Program_A__ka');
			activeKaApiNames.add('Tutorial_A__ka');
			activeKaApiNames.add('Collections_Talking_Point__ka');
			activeKaApiNames.add('Troubleshooting_A__ka');
			activeKaApiNames.add('Reference_A__ka');		
			return 	activeKaApiNames;
		}
	}
	public static void createTestDataActiveKa() {		
    	KmArticleTypeModel.refreshKaTypeObject();
    	KmArticleTypeModelTest.markAllKaTypeObjectsActive();		
	}


	public static void markKaTypeObjectsActive(List<String> kaTypesToMarkActive) {
		List<KmArticleType__c> kaTypes = [
			select IsActive__c
			from KmArticleType__c
			where ArticleTypeApiName__c in :kaTypesToMarkActive
		];
		
		System.Assert(kaTypes.size() > 0);
		
		for (KmArticleType__c kaType : kaTypes) {
			kaType.IsActive__c = true;
		}
		update kaTypes;
	}
	
	public static void markAllKaTypeObjectsActive() {
		List<KmArticleType__c> kaTypes = [
			select IsActive__c
			from KmArticleType__c
		];
		System.Assert(kaTypes.size() > 0);
		
		for (KmArticleType__c kaType : kaTypes) {
			kaType.IsActive__c = true;
		}
		update kaTypes;
	}
}