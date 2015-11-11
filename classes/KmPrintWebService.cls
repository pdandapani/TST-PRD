/*

@httpPost - update status of printjob, optionally return 
@httpPatch - update final output link

*/

@RestResource(urlMapping='/KmPrintWebService/v1/*')
global class KmPrintWebService {
	
	@httpPost
	global Static KmPrintWebServieReply post (string printJobName, string status, boolean returnPages, integer startPage, integer pageCount) {
	  	
	  	List<PrintJob__c> printJobs = [
	  		select Binder__c, Binder__r.name, EndTime__c, OutputLink__c, StartTime__c, Status__c, name, id
	  		from PrintJob__c 
	  		where Name = :printJobName
	  	];
	  	
	  	KmPrintWebServieReply reply = new KmPrintWebServieReply();
	  	reply.printJobName = printJobName;
	  	if ( printJobs.size() == 0) {
	  		reply.message = 'cannot locate printjob : '+ printJobName;
	  		return reply;
	  	}
	  	
	  	
  		PrintJob__c printJob = printJobs[0];
  		reply.binderName = printJob.Binder__r.name;
  		reply.binderId = printJob.Binder__c;
  		reply.printJobName = printJob.name;
  		reply.printJobId = printJob.id;
  		reply.userName = UserInfo.getFirstName() + '.' + UserInfo.getLastName();
  		reply.totalBinderPageCount = 0;
	  	
	  	reply.basedir = '';
	  	KB_App_Settings__c kmEnginePrintBinderBaseDir = KB_App_Settings__c.getInstance('kmEnginePrintBinderBaseDir');
	  	if (kmEnginePrintBinderBaseDir != null ) {
	  		reply.basedir = kmEnginePrintBinderBaseDir.Value__c;
	  	}
	  	
	  	reply.kmEngineReadBinderURL = '';
	  	KB_App_Settings__c kmEngineReadBinderURL = KB_App_Settings__c.getInstance('kmEngineReadBinderURL');
	  	if (kmEngineReadBinderURL != null ) {
	  		reply.kmEngineReadBinderURL = kmEngineReadBinderURL.Value__c;
	  	}
	  	
	  	//update status if necessary
	  	if (status <> null && status.length() > 0) {
	  		printJob.Status__c = status;
	  		update printJob;
	  	}
	  	
	  	//get details if necessary
	  	if ( returnpages ) {
	  		List<BinderPage__c> pages = [
	  			select sequence__c, PageRef__c, articleDepotId__c, articleDepotId__r.ArticlePdfContentVersionId__c, pageType__c
	  			from BinderPage__c
	  			where Binder__c = :printJob.Binder__c
	  			order by sequence__c
	  		];
	  		
	  		if ( pages.size() > 0 ){
	  			reply.totalBinderPageCount = pages.size();
	  			reply.details = new List<KmPrintWebServiceReplyDetail>();
	  			for(BinderPage__c page : pages) {
	  				KmPrintWebServiceReplyDetail detail = new KmPrintWebServiceReplyDetail(page);  
	  				reply.details.add(detail);
	  			}
	  			
	  			//now add the articleDepotId and articleContentVersionId
	  		}
	  	}
	 
		return reply;
	} 
  
	
	@httpPatch
	global Static void patch (string printJobName, string outputURL, string title) {	  
		List<PrintJob__c> printJobs = [
	  		select EndTime__c, OutputLink__c, Status__c, Title__c
	  		from PrintJob__c 
	  		where Name = :printJobName
	  	];
	  	if ( printJobs.size() == 0) {
	  		System.Debug('KmPrintWebService::patch - cannot locate printjob : '+ printJobName) ;
	  		return;
	  	}
	  	
	  	PrintJob__c printJob = printJobs[0];
  		printJob.OutputLink__c = outputURL;
  		printJob.Status__c = 'Completed';
  		printJob.EndTime__c = DateTime.Now();
  		printJob.Title__c = title;
	  	
	  	update printJob;
	  	
		return;
	} 	

	
	///////////////////////////////////////////////////////////////
	
	global class KmPrintWebServieReply {
	
		public string binderName;
		public string binderId;
		public string printJobName;
		public string printJobId;
		public string userName;
		public integer totalBinderPageCount;
		public string kmEngineReadBinderURL;
		public string basedir;
		
		public string message;
	
		public List<KmPrintWebServiceReplyDetail> details;	
		
		public KmPrintWebServieReply() {
			totalBinderPageCount = 0;
			message = '';
			details = new List<KmPrintWebServiceReplyDetail>();
		}
	}  

	public class KmPrintWebServiceReplyDetail {
	
		public Integer seq;
		public String ref;  //OrginalArticleVersionId__c
		public String articleDepotId;
		public String articlePdfContentVersionId;
		public String pageType;
		
		public KmPrintWebServiceReplyDetail(BinderPage__c page) {
			this.seq = Integer.valueOf(page.sequence__c);
			this.ref = page.PageRef__c;
			this.articleDepotId = page.articleDepotId__c;
			if (page.articleDepotId__c <> null ) {
				this.articlePdfContentVersionId = page.articleDepotId__r.ArticlePdfContentVersionId__c;
			}
			this.pageType = page.PageType__c;
		}
	}
	
  
}