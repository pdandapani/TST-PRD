/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  KmArticleTypeModel provides a set of routines to work with dynamic article types   
*
* as of Winter 15 - the salesforce DescribeSObjectResult does not give access to the Deployed attribute
* the KmArticleTypeModel will be used to indicate which ArticleTypes should be part of the 
* - article archival
* - validate article links
* - print article PDF 
* 
* documentation for DescribeSObjectResult 
* https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_sobject_describe.htm#apex_methods_system_sobject_describe
**/

//erd - https://www.salesforce.com/developer/docs/api/index_Left.htm#CSHID=sforce_api_objects_list.htm|StartTopic=Content%2Fsforce_api_objects_list.htm|SkinName=webhelp
public class KmArticleTypeModel {

	//KmArticleTypeModel.refreshKaTypeObject();
	//refresh records in KmArticleType__c based on current Article Types defined 
	//
	//The hourly archive article job will invoke this before execution
    public static void refreshKaTypeObject() {
    	
    	
    	// 1 - remove kmArticleTypes that have been deleted
    	List<KmArticleType__c> toDelete = [
    		select id
    		from KmArticleType__c
    		where ArticleTypeApiName__c not in :allArticleTypesApiNames  
    	];
    	if ( toDelete.size() > 0) {
    		delete toDelete;
    	}
    	
    	// 2 - add new kmArticleTyps that have been added
    	// 2.1 get a set of the remaining records in KmArticleType__c
    	List<KmArticleType__c> remainingKaTypes = [
    		select ArticleTypeApiName__c, ArticleTypeLabel__c, id
    		from KmArticleType__c
    	];	
    
    	Map<String, KmArticleType__c> existingKaTypeMap = new Map<String, KmArticleType__c>();
    	for(KmArticleType__c kaType : remainingKaTypes) {
    		existingKaTypeMap.put(kaType.ArticleTypeApiName__c, kaType);
    	}
    	
    	// 2.2 check remaining list against the all KaTypes in the system
    	List<KmArticleType__c> toUpsert = new List<KmArticleType__c>();
    	for(String kaApiName : allArticleTypesApiNames) {
    		if (existingKaTypeMap.containsKey(kaApiName) ) {
    			KmArticleType__c existingKaArticleTypeRec = existingKaTypeMap.get(kaApiName);
    			existingKaArticleTypeRec.ArticleTypeLabel__c = knowledgeArticleTypesMap.get(kaApiName).getDescribe().getLabel();
    			
    			toUpsert.add(existingKaArticleTypeRec);
    		} else {
    			KmArticleType__c newKaArticleTypeRec = new KmArticleType__c();
    			newKaArticleTypeRec.ArticleTypeLabel__c = knowledgeArticleTypesMap.get(kaApiName).getDescribe().getLabel();
    			newKaArticleTypeRec.ArticleTypeApiName__c = kaApiName;
    			newKaArticleTypeRec.isActive__c = false;
    			
    			toUpsert.add(newKaArticleTypeRec);
    		}
    	}
    	if (toUpsert.size() > 0 ) {
    		upsert toUpsert;
    	}
    	
    	// 3 - validate KaTypeFieldWithArticleDepot
    	validateKaTypeFieldWithArticleDepot();
    }
	
	//KmArticleTypeModel.validateKaTypeFieldWithArticleDepot();
	public static List<String> validateKaTypeFieldWithArticleDepot() {
		List<String> result = new List<String>();
	
		//find a set of all custom fields available in the articleDepot
		//then check each articleType to make sure we have a field to archive the field 			
		for(String articleTypeApiName : activeKaApiNames) {
			for ( String customField : getArticleTypeCustomFields(articleTypeApiName)) {
 				if (!articleDepotCustomFields.contains(customField) ) {
 					String fieldErrorMsg = 'validateKaTypeFieldWithArticleDepot - '+
						articleTypeApiName+'::'+customField 
						+' need to be defined in articleDepot';
					System.Debug(fieldErrorMsg);
					result.add(fieldErrorMsg);
				}
			}
		}
		
		if ( result.size() == 0) {
			result.add('validateKaTypeFieldWithArticleDepot completed with no error.');
		}
		return result;
	}
	
	private static Set<String> pArticleDepotCustomFields = null;
	public static Set<String> articleDepotCustomFields {
		get {
			if (pArticleDepotCustomFields == null) {
				pArticleDepotCustomFields = new Set<String >();
				for( String fieldName : discoverAccessibleFields(articleDepotSchemaObj)) {
					if (fieldName.toLowerCase().endsWith('__c')) {
						pArticleDepotCustomFields.add(fieldName);
					}
				}
			}
			return pArticleDepotCustomFields;
		}
	}
	
	public static Set<String> getArticleTypeCustomFields(String articleTypeApiName) {
		Schema.SObjectType articleTypeSchema = globalDescribeSObjects.get(articleTypeApiName);
		if (articleTypeSchema <> null ) {
			List<String> allFields = discoverAccessibleFields(articleTypeSchema);
			Set<String> result = new Set<String>();
			for ( String field : allFields) {
				if (field.toLowerCase().endsWith('__c')) {
					result.add(field);
					//System.Debug(field+' is a custom field');
				} else {
					//System.Debug(field+' is not a custom field');
				}
			}
			return result;
		} else {
			//invalid articleTypeApiName - just return an empty set
			return new Set<String>();
		}
	}
	
	public static Map<String, Schema.SobjectField> getSObjectFieldMap(String articleTypeApiName) {
		Schema.SObjectType articleTypeSchema = knowledgeArticleVersionsMap.get(articleTypeApiName);
		
		if ( articleTypeSchema <> null ) {
			Map<String, Schema.SobjectField> sObjectFields = articleTypeSchema.getDescribe().fields.getMap();
			return sObjectFields;
		} else {
			System.Debug('getSObjectFieldMap could not find Schema.SObjectType for '+articleTypeApiName);
			for(String kavApiName : knowledgeArticleVersionsMap.keySet()) {
				System.Debug('kavApiName = ' + kavApiName);
			}
			
			return new Map<String, Schema.SobjectField>();
		}
	}
	
	//https://www.salesforce.com/us/developer/docs/pages/Content/pages_dynamic_vf_globals_objecttype.htm
	public static List<String>  discoverAccessibleFields(Schema.SObjectType newObjType) {
		
        List<String> accessibleFields = new List<String>();
        Map<String, Schema.SobjectField> fieldMap = 
            newObjType.getDescribe().fields.getMap();
            
        System.Debug('discoverAccessibleFields newObjType.getDescribe().fields.getMap() found '+ 
        	fieldMap.Values().size() + ' fields for '+ newObjType.getDescribe().getName()); 
            
        for (String s : fieldMap.keySet()) {
            if ((s != 'Name') && (fieldMap.get(s).getDescribe().isAccessible())) {
                accessibleFields.add(s);
                //System.Debug('discoverAccessibleFields '+s+' type is accessible' );
            } else {
            	//System.Debug('discoverAccessibleFields '+s+' type is not accessible' );
            }
        }
        System.Debug('KmArticleTypeModel::discoverAccessibleFields for '+ newObjType.getDescribe().getName() +
        	' found '+accessibleFields.size()+' accessibleFields.');
        return accessibleFields;
    }

	public static Set<String>  discoverAccessibleRichTextFields(Schema.SObjectType newObjType) {
		if (newObjType == null ) {
			System.Debug('**** discoverAccessibleRichTextFields - Schema.SObjectType newObjType is null');
			
			return new Set<String>();
		}
		
        Set<String> accessibleFields = new Set<String>();
        Map<String, Schema.SobjectField> fields = 
            newObjType.getDescribe().fields.getMap();
        for (String s : fields.keySet()) {
            if ((s != 'Name') && (s.endswith('__c')) && (fields.get(s).getDescribe().isAccessible()) ) {        	
            	if ( fields.get(s).getDescribe().getType() == Schema.DisplayType.TextArea ) {
                	accessibleFields.add(s);
                	//System.Debug('discoverAccessibleRichTextFields '+s+' type == Schema.DisplayType.TextArea' );
            	} else {
            		//System.Debug('discoverAccessibleRichTextFields '+s+' type <> Schema.DisplayType.TextArea' );
            	}
            } else {
            	//System.Debug('discoverAccessibleRichTextFields '+s+'is NOT an accessible field.');
            }
        }
        return accessibleFields;
    }

	
	public static Schema.SObjectType articleDepotSchemaObj {
		get {
			return globalDescribeSObjects.get('ArticlePDF__c');
		}
	}


	public static List<String> activeKaApiNames {
		get {
			List<String> result = new List<String>();
			for(KmArticleType__c kaType :  activeKaTypes) {
				result.add(kaType.ArticleTypeApiName__c);
			}

			return result;
		}
	}
	
	public static List<String> activeKavApiNames {
		get {
			List<String> result = new List<String>();
			for(String kaName : activeKaApiNames) {
				result.add(kaName+'v');
			}
			return result;
		}
	}
	public static List<KmArticleType__c> activeKaTypes {
		get {
			List<KmArticleType__c> activeKaTypes = [
				select ArticleTypeLabel__c, ArticleTypeApiName__c, isActive__c
				from KmArticleType__c
				where isActive__c = true
			];
			return activeKaTypes;
		}
	}  

	public static Set<String> allArticleTypesApiNames{
		get {
			return knowledgeArticleTypesMap.keySet();
		}
	}

	public static Set<String> allArticleTypeLabels{
		get {
			Set<String> labels = new Set<String>();
			for(Schema.SObjectType objType : knowledgeArticleTypesMap.values()) {
				labels.add(objType.getDescribe().getLabel());
			}
			return labels;
		}
	}	
	
	
	public static String getKnowledgeArticleLabelByApiName(String kaApiName) {
		if (kaApiName.endsWith('__kav')) {
			kaApiName = kaApiName.replace('__kav','__ka');
		}
		
		if (knowledgeArticleTypesMap.containsKey(kaApiName) ) {
			return knowledgeArticleTypesMap.get(kaApiName).getDescribe().getLabel();
		} else {
			return kaApiName;
		}
	}
	
	//a map of all ka
	private static Map<String, Schema.SObjectType> pKnowledgeArticleTypesMap = null;
	public static Map<String, Schema.SObjectType> knowledgeArticleTypesMap {
		get {
			if (pKnowledgeArticleTypesMap == null) {
				pKnowledgeArticleTypesMap = new Map<String, Schema.SObjectType>();		
				for(String sObjName : globalDescribeSObjects.keySet()) {
					Schema.SObjectType sObjType = globalDescribeSObjects.get(sObjName);
					//System.Debug(sObjName);
					
					if (sObjName.endsWith('__ka')) {
						pKnowledgeArticleTypesMap.put(sObjName, sObjType);
					}
				}
			}
			return pKnowledgeArticleTypesMap;
		}
	}
	
	//a map of all kav
	private static Map<String, Schema.SObjectType> pKnowledgeArticleVersionsMap = null;
	public static Map<String, Schema.SObjectType> knowledgeArticleVersionsMap {
		get {
			if (pKnowledgeArticleVersionsMap == null) {
				pKnowledgeArticleVersionsMap = new Map<String, Schema.SObjectType>();		
				for(String sObjName : globalDescribeSObjects.keySet()) {
					Schema.SObjectType sObjType = globalDescribeSObjects.get(sObjName);
					//System.Debug(sObjName);
					if (sObjName.endsWith('__kav')) {
						pKnowledgeArticleVersionsMap.put(sObjName, sObjType);
						pKnowledgeArticleVersionsMap.put(sObjName.toLowerCase(), sObjType);
					}
				}
			}
			return pKnowledgeArticleVersionsMap;
		}
	}
	
	
	private static Map<String, String> pKnowledgeLabelMap = null;
	public static String knowledgeLabelNameToKav(String knowledgeLabelName) {
		if (pKnowledgeLabelMap == null) {
			pKnowledgeLabelMap = new Map<String, String>();
			for(String sObjectApiName : globalDescribeSObjects.keySet()) {
				String sObjectLabel = globalDescribeSObjects.get(sObjectApiName).getDescribe().getLabel();
				pKnowledgeLabelMap.put(sObjectLabel,sObjectApiName);
			}
		}
		if ( pKnowledgeLabelMap.containsKey(knowledgeLabelName)) {
			return pKnowledgeLabelMap.get(knowledgeLabelName);
		} else {
			return knowledgeLabelName;
		}
	}
	
	public static String SObjectApiToLabelName(String SObjectApiName){
		if (globalDescribeSObjects.containsKey(SObjectApiName) ) {
			Schema.SObjectType sObjSchema = globalDescribeSObjects.get(SObjectApiName);
			String sObjLabelName = sObjSchema.getDescribe().getLabel();
			return sObjLabelName;
		} else {
			return SObjectApiName;
		}
	}

	private static Map<String, Schema.SObjectType> pGlobalDescribeSObjects = null;
	public static Map<String, Schema.SObjectType> globalDescribeSObjects {
		get {
			if (pGlobalDescribeSObjects == null) {
				pGlobalDescribeSObjects = Schema.getGlobalDescribe(); 
			}
			return pGlobalDescribeSObjects;
		}
	}

	public static String getArticleVersionType(SObject kavRecord) {
		if (kavRecord <> null) {
			Schema.DescribeSObjectResult  articleTypeDescribe = kavRecord.getSObjectType().getDescribe();
			
			String kavApiName = articleTypeDescribe.getName();
			if (kavApiName.endsWith('_kav')) {
				//got the kav at this point - remove the v from kav to get the ka
				String kaApiName = kavApiName.removeEnd('v');
				
				return kaApiName;
			} 
		}
		//error 
		return null;
		
	}
}