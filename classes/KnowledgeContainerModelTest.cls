@IsTest
public class KnowledgeContainerModelTest {

	@IsTest
	public static void unitTest() {
		Id parentId = createData();
		
		KnowledgeContainerModel.RunMe(parentId);
		set<String> result = KnowledgeContainerModel.findContainerNamesWithChildren(parentId);
		System.AssertNotEquals(null, result);
		System.Assert(result.size() > 0);
		
		set<id> result2 = KnowledgeContainerModel.findIdSetWithChildren(parentId);
		System.AssertNotEquals(null, result2);
		System.Assert(result2.size() > 0);
		
		set<id> result3 = KnowledgeContainerModel.findIdSetWithChildren(null);
		System.AssertNotEquals(null, result3);
		System.Assert(result3.size() == 0);
	
	}

	public static id createData() {
		KnowledgeContainer__c kc1 = createKc('kc1','kc1','true', null);
		insert kc1;
		
		KnowledgeContainer__c kc1_1 = createKc('kc1.1','kc1.1','true', kc1.id);
		insert kc1_1;
		
		KnowledgeContainer__c kc1_2 = createKc('kc1.2','kc1.2','false', kc1.id);
		insert kc1_2;
		
		KnowledgeContainer__c kc1_1_1 = createKc('kc1.1.1','kc1.1.1','false', kc1_1.id);
		insert kc1_1_1;
		
		return kc1.id;
	}
	
	public static KnowledgeContainer__c createKc(String container, String containerName, String hasChild, id parentId) {
		KnowledgeContainer__c kc1 = new KnowledgeContainer__c();
		kc1.container__c = container;
		kc1.containername__c = containerName;
		kc1.hasChild__c = hasChild;
		kc1.Parent_Container_Lookup__c = parentId;
		
		return kc1;
	}
	

}