public class KnowledgeContainerModel {


	public static void RunMe() {
		RunMe('a02S0000007EStN');
		System.Debug('\n\n\n');
		RunMe('a02S0000007EiRe');
		System.Debug('\n\n\n');
		RunMe('a02S0000007EiRo');
		System.Debug('\n\n\n');
		
	}
	
	//KnowledgeContainerModel.RunMe('');
	public static void RunMe(id testId) {
		Set<id> myIds = KnowledgeContainerModel.findIdSetWithChildren(testId);
		KnowledgeContainer__c container = KnowledgeContainerMapById.get(testId);
		System.debug('Children for '+ testId + ' ' + container.hiearchyid__c +' '+ container.name);
		for(id myId : myIds) {
			System.debug(KnowledgeContainerMapById.get(myId).Name);
		}		
	}
	
	
	public static set<String> findContainerNamesWithChildren(id containerId) {
		set<id> containerIds = findIdSetWithChildren(containerId);
		
		List<KnowledgeContainer__c> kcList = [
			select id, name
			from KnowledgeContainer__c 
			where id in :containerIds
		];
		
		Set<String> result = new Set<String>();
		for(KnowledgeContainer__c kc : kcList) {
			result.add(kc.name);
		}
		
		return result;
		
	}
	
	public static set<id> findIdSetWithChildren(id containerId) {
		//find the hierarchyId first
		if ( !KnowledgeContainerMapById.containsKey(containerId) ) {
			return new Set<id>();
		}
		KnowledgeContainer__c container = KnowledgeContainerMapById.get(containerId);
		System.Debug('FindIdSetWithChildren checking '+ container.name);
		Set<id> result = new Set<Id>();
		result.add(containerId);
		
		for(KnowledgeContainer__c kc : KnowledgeContainerModel.AllKnowledgeContainer) {
			if (kc.parent__c <> kc.hiearchyid__c && kc.parent__c == container.hiearchyid__c) {
				result.addAll(findIdSetWithChildren(kc.id));
			}
		}
		return result;
	}
	
	
	private static Map<id,KnowledgeContainer__c> pKnowledgeContainerMapById = null;
	public static Map<id,KnowledgeContainer__c> KnowledgeContainerMapById {
		get {
			if (pKnowledgeContainerMapById == null) {
				pKnowledgeContainerMapById = new  Map<id,KnowledgeContainer__c>();
				for(KnowledgeContainer__c kc : KnowledgeContainerModel.AllKnowledgeContainer) {
					pKnowledgeContainerMapById.put(kc.id,kc);
				}
			}
			return pKnowledgeContainerMapById;
		}
	}


	private static List<KnowledgeContainer__c> pAllKnowledgeContainer = null;
	public static List<KnowledgeContainer__c> AllKnowledgeContainer {
		get {
			if (pAllKnowledgeContainer == null) {
				pAllKnowledgeContainer = [
					select id, Name, container__c, containername__c, hasChild__c,
					hiearchyid__c, parent__c
					from KnowledgeContainer__c 
				];
			}
			return pAllKnowledgeContainer;
		}
	}

}