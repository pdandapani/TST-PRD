global class BrokenLinksJob implements Schedulable {
	public static String schedDaily = '0 15 00 * * ?';  //Every Day at 15 minutes after Midnight 
	public static String schedHourly = '0 0 * * * ?';  //Every Hour

    //BrokenLinksJob.scheduleBrokenLinkExtractorChecker();
    global static String scheduleBrokenLinkExtractorChecker(String jobName) {
        BrokenLinksJob blj = new BrokenLinksJob(); 
        return System.schedule(jobName, schedDaily, blj);
    }

    global void execute(SchedulableContext sc) {
    	//Populate links into the LinkValidationObject
        new BrokenLinksWorker().findLinks();           
        
        //Now initiate the Java process to flag broken links
        startBrokenLinksJavaProcess('Broken Link Job');
    }
    
    //BrokenLinksJob.RunBrokenLinksJob();
    global static void RunBrokenLinksJob() {
    	new BrokenLinksWorker().findLinks();  
    	startBrokenLinksJavaProcess('Broken Link Job');
    }
    
    
    @future(callout = true)
    public static void startBrokenLinksJavaProcess(String jobName) {
    	Http h = new Http();
    	HttpRequest req = new HttpRequest();
    	
    	String endpoint;
    	try {
    		if (Test.isRunningTest()) {
    			endpoint = 'https://servlet.url.com/servlet';
    		} else {
    			Broken_Links_Job__c brokenLinkJob = Broken_Links_Job__c.getInstance(jobName);
    			if (brokenLinkJob != null ) {
    				endpoint = brokenLinkJob.Link_Checker_Servlet__c;
    				// for testing 
    				// https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/validateLinks
    			}    			
    		}
    		req.setEndpoint(endpoint);
    		req.setMethod('GET');
    		HttpResponse res = h.send(req);
    	} catch (QueryException qe) {
    		System.debug('****** Could not initiate Link Checker Java process. Please check and fix. ******');
    	}
    }
}