/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  BinderModel - methods to insert / retrieve pages into binder for printing articles by Search functions
*
* - upgraded to work with dynamic ArticleTypes
* - add without sharing keyword so that all KM team members can refresh binder pages / queries created by another KM team member
**/

public without sharing class BinderModel {
	
	public static Binder__c getBinderById(id BinderId) {
		List<Binder__c> binders = [
			select id, Article_Type__c, Comment__c,
				FOPP__c, From_Date__c, Include_children__c,  Include_Archived__c,
				Knowledge_Container__c,Knowledge_Container__r.name, recordType.name, To_Date__c,
				SOQL_Online__c, SOQL_DG_Pack__c,
				SOQL_Archive_1__c, SOQL_Archive_2__c, SOQL_Archive_3__c
			from binder__c
			where id = :binderId
		];
		
		if ( binders.size() <> 1) {
			return null;
		} else {
			return binders[0];
		}
	}


	//returns a list of binder page element based on filter criteria 1	
	public static List<BinderPage__c> getAllBinderPagesPrint1 (id BinderId) {
		List<BinderPage__c> pages = [
			select id
			from BinderPage__c
			where Binder__c = :BinderId
			order by FOPP__c,Hierarchy__c, First_Published_Date__c desc
		];
		
		return pages;
	}
	
	//returns a list of binder page element based on filter criteria 1	
	public static List<BinderPage__c> getAllBinderPagesPrint2 (id BinderId) {
		List<BinderPage__c> pages = [
			select id
			from BinderPage__c
			where Binder__c = :BinderId
			order by Article_Number__c, Title__c, First_Published_Date__c desc
		];
		
		return pages;
	}
	
	public static void clearAllBinderPages(id BinderId) {
		List<BinderPage__c> pages = getAllBinderPagesPrint1(BinderId);
		
		Delete pages;
	}  
	
	    
    public static void PrintJobTriggerHandler(List<PrintJob__c> jobs) {
    	for(PrintJob__c job : jobs ) {
   			BinderModel.processPrintJob(job.name);
   		}
    }
	
	//BinderModel.processPrintJob ('PJ-0000000');
	@future(callout=true)
    public static void processPrintJob(String printJobName) {
		Http h = new Http();
	
		// Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
		HttpRequest req = new HttpRequest();
		
		String endPointURL = '';
		
		try{
    		endPointURL = 'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmPdfMerger?printJobName=';
    		//endPointURL = 'http://75.85.65.144:8080/SFDCweblinkKM/kmPdfMerger?printJobName=';

    		KB_App_Settings__c kmEnginePrintBinderUrl = KB_App_Settings__c.getInstance('kmEnginePrintBinderUrl');
    		
    		if ( kmEnginePrintBinderUrl != null) {
    			endPointURL = kmEnginePrintBinderUrl.Value__c;
    		} 
    	}
    	catch(Exception e){
    		endPointURL = 'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmPdfMerger?printJobName=';
    	}
		
		req.setEndpoint(endPointURL+printJobName);
		req.setMethod('GET');
	 
		// Send the request, and return a response
		if (!Test.isRunningTest()) {
			HttpResponse res = h.send(req);
		}  
    }  

    
    
    /*
    ProcessPrintJob End Points
    
    PC Server at Benjamin's home office
    'http://76.95.105.179:8088/TfsKmPdfMerger?printJobName='
    
    OSX Server at Benjamin's home office
    'http://76.95.105.179:8082/SFDCweblinkKM/kmPdfMerger?printJobName='
    'http://76.95.105.179:8082/SFDCweblinkKM/kmPdfMerger?printJobName='
    'http://24.86.162.36:8080/SFDCweblinkKM/kmPdfMerger?printJobName=PJ-0000063'
    
    TFS - Test Server
    'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmPdfMerger?printJobName='
    
    */
    
    
	

}