/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  Schedule a hourly job to copy article from kav to articlePdf custom object for archival   
*
**/
global class ArticleDepotJob implements Schedulable {
	public static String schedDaily = '0 00 00 * * ?';  //Every Day at Midnight 
	public static String schedHourly = '0 0 * * * ?';  //Every Hour

	//ArticleDepotJob.scheduleArticleDepotJob('ArticleDepotJob');
    global static String scheduleArticleDepotJob(String jobName) {
        ArticleDepotJob adj = new ArticleDepotJob(); 
        return System.schedule(jobName, schedHourly, adj);
    }

    global void execute(SchedulableContext sc) {
		execute();
    }
      
    global void execute() {
    	//index all reusable content
    	ReusableContentIndexBatch.runNow();
    	
    	//refresh ArticleType to avoid error
    	KmArticleTypeModel.refreshKaTypeObject();
    	
    	//copy / archive 1000 articles per hour
    	ArticleDepotModel.copyToDepot();
    	
    	//generate PDF for these newly created articles 
    	ArticleDepotModel.startPdfConversion();    	
    }
    
    //ArticleDepotJob.runNow();
    global static void runNow() {
    	ArticleDepotJob job = new ArticleDepotJob();
    	job.execute(); 
    }
   
}