/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  RecordTypeModelKm - provide a consistent way to access record type for Km
**/
public class RecordTypeModelKm  {
	//Binder__c
    public static RecordType BinderPrint1RecType {
    	get {
    		return RecordTypeModel.LookupRecordType('Binder__c','Print Function 1');
    	}
    }
    public static id BinderPrint1RecTypeId {
    	get {
    		return RecordTypeModel.LookupRecordTypeId('Binder__c','Print Function 1');
    	}
    }

    public static RecordType BinderPrint2RecType {
    	get {
    		return RecordTypeModel.LookupRecordType('Binder__c','Print Function 2');
    	}
    }
    public static id BinderPrint2RecTypeId {
    	get {
    		return RecordTypeModel.LookupRecordTypeId('Binder__c','Print Function 2');
    	}
    }
}