@IsTest
public class TFSC_BatchUpdateCasesTest {

	@IsTest
	public static void unitTest() {
		Map<Id, String> caseMap = createData();
		
		Test.startTest();
		TFSC_BatchUpdateCases batch = new TFSC_BatchUpdateCases(caseMap);
		Database.executeBatch(batch, 100);
		Test.stopTest();
		
	}
	
	public static Map<Id, String> createData() {
		Map<Id, String> caseMap = new Map<Id, String>();
		
		Case c = new Case();
		c.KM_Department__c = 'Km Department'; 
		c.KM_Change_Category__c  = 'Scorecard';
		c.KM_Documentation_Impacted__c = 'FOPP';
		insert c;
		
		caseMap.put(c.id, 'a comment');
		return caseMap;
	}
}