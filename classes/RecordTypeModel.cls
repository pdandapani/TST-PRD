public class RecordTypeModel {
	  
	/////////////////////////////////////////////////////////////////////////
	private static List<RecordType> pRecordTypeList = null;
	public static List<RecordType> RecordTypeList {
		get {
			if (pRecordTypeList == null) {
				pRecordTypeList = [
		            select id, SobjectType,  Name, DeveloperName
		            from RecordType where isActive = true]; 
			}
			return pRecordTypeList;
		} 
	}
	
	private static Map<Id, RecordType> pRecordTypeMapById = null;
	public static Map<Id, RecordType> RecordTypeMapById {
		get {
			if ( pRecordTypeMapById == null) {
				pRecordTypeMapById = new Map<Id, RecordType>();
				for(RecordType rt : RecordTypeList) {
					pRecordTypeMapById.put(rt.id, rt);
				}
			}
			return pRecordTypeMapById;			
		}
	}
	
	public static string findRecordTypeNameById(Id recordTypeId) {
		if (RecordTypeMapById.containsKey(recordTypeId) ) {
			return RecordTypeMapById.get(recordTypeId).DeveloperName;
		} else {
			return 'Unknown RecordTypeId : ' + recordTypeId;
		}
	}
	
	
	
	private static Map<String,RecordType> pRecordTypeMap = null;
	public static Map<String,RecordType> recordTypeMap {
		get {
			if ( pRecordTypeMap == null){
				pRecordTypeMap = new Map<String,RecordType>(); 
		
				for(RecordType rt : RecordTypeList){
					pRecordTypeMap.put(rt.SobjectType+':'+rt.Name, rt);
					//System.Debug(rt.SobjectType+':'+rt.Name);
					if ( rt.Name <> rt.DeveloperName){
						pRecordTypeMap.put(rt.SobjectType+':'+rt.DeveloperName, rt);
						//System.Debug(rt.SobjectType+':'+rt.DeveloperName);
					}
				} 
			}
			return pRecordTypeMap;
		}
	}
    
    public static RecordType LookupRecordType(string sObjectName, string RecordTypeName){
        if(recordTypeMap.containsKey(sObjectName+':'+RecordTypeName)){        	
        	return recordTypeMap.get(sObjectName+':'+RecordTypeName);
        }else { 
            //unable to locate
            System.Debug('RecordTypeModel::LookupRecordType unable to locate '+sObjectName+':'+RecordTypeName);
            return null;
        }
        
        
    }
    

	public static Id LookupRecordTypeId(string sObjectName, string RecordTypeName){
        if(recordTypeMap.containsKey(sObjectName+':'+RecordTypeName)){
        	return recordTypeMap.get(sObjectName+':'+RecordTypeName).Id;
        } else { 
            //unable to locate
            System.Debug('RecordTypeModel::LookupRecordType unable to locate '+sObjectName+':'+RecordTypeName);
            return null;
        }
    }
    

	//PersonAccount
    public static RecordType PersonAccountCustomerRecType {
    	get {
    		return LookupRecordType('Account','Customer');
    	}
    }
    
    public static id PersonAccountCustomerRecTypeId {
    	get {
    		return LookupRecordTypeId('Account','Customer');
    	}
    }
    
	//Weblogin
    public static RecordType ContactWebLoginRecType {
    	get {
    		return LookupRecordType('Contact','Weblogin');
    	}
    }
    
    public static id ContactWebLoginRecTypeId {
    	get {
    		return LookupRecordTypeId('Contact','Weblogin');
    	}
    }

	//FinancialAccount
    public static RecordType FinancialAccountRetailRecType {
    	get {
    		return LookupRecordType('Financial_Account__c','Retail');
    	}
    }
    public static id FinancialAccountRetailRecTypeId {
    	get {
    		return LookupRecordTypeId('Financial_Account__c','Retail');
    	}
    }

    public static RecordType FinancialAccountLeaseRecType {
    	get {
    		return LookupRecordType('Financial_Account__c','Lease');
    	}
    }     
    public static id FinancialAccountLeaseRecTypeId {
    	get {
    		return LookupRecordTypeId('Financial_Account__c','Lease');
    	}
    }

}