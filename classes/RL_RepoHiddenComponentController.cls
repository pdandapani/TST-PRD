public with sharing class RL_RepoHiddenComponentController {
    
    private Repossession__c contextRepo;
    public Boolean needToSetProposedNoticeDate{get;set;}
    private Date newProposedNoticeDate;
    
    public BusinessHours businessHrs;
    
    public Boolean allowRefreshAfterAttemptedUpdate{get;set;}
    public String errorStringOnUpdate{get;set;}
    
    public RL_RepoHiddenComponentController(ApexPages.StandardController stdController) {
        this.contextRepo = (Repossession__c)stdController.getRecord();
        needToSetProposedNoticeDate = false;
        if(contextRepo.Proposed_Notice_Date_Override__c) {
        	return;
        }
        initVariables();
    }
    
    private void initVariables() {
    	//if(contextRepo != null) {
    		
    		try {
    			if(contextRepo.Case__r.BusinessHoursId != null) {
                    businessHrs = [select id from BusinessHours where id = :contextRepo.Case__r.BusinessHoursId];
                }
    		}catch(Exception e) {
    			errorStringOnUpdate = e.getMessage();
    		}
    		
    		updateProposedNoticeDateFlag();
    	//}
    }
    
    private Boolean isPastHourCutoffTime(Integer intCurrentHour0To23) {
    	Boolean boolToReturn = false;
    	
    	String cutoffString = Label.RL_Mail_Cutoff_Standard; //string of 14
    	Integer cutoffInt = 14; //re-evaluated below to cutoffString
    	if(contextRepo.Case__c != null 
	       && contextRepo.Case__r.Form_Rule__c != null 
	       && contextRepo.Case__r.Form_Rule__r.Certified__c != null
	       && contextRepo.Case__r.Form_Rule__r.Certified__c == true)
	     {
             cutoffString = Label.RL_Mail_Cutoff_Certified;
         }
    			
        
        if(cutoffString != null) {
        	cutoffInt = Integer.valueOf(cutoffString);
        }
        
    	if(intCurrentHour0To23 >= cutoffInt)
    	    boolToReturn = true;
    	
    	return boolToReturn;
    }
    
    private void updateProposedNoticeDateFlag() {
    	
    	String currentHour0To23 = currentUserTime();
    	Integer intCurrentHour0To23 = Integer.valueOf(currentHour0To23);
    	Boolean isPastCutoffTime = isPastHourCutoffTime(intCurrentHour0To23);
    	Date todaysDate = Date.today();
    	Date todaysBusinessDay = Date.today();
    	DateTime nowDateTime = DateTime.now();
        Date nextBusinessDay = addBusinessDays(Date.today(), 1);
        Date yesterdaysDate = Date.today().addDays(-1);
        Date requiredNoticeDate = nextBusinessDay;
        
        //change to US699 Proposed Notice Date calculation
        //if(contextRepo.Case__r != null && contextRepo.Case__r.RL_System_Required_Notice_Date_Time__c != null) {
        //	requiredNoticeDate = contextRepo.Case__r.RL_System_Required_Notice_Date_Time__c.date() ;
        //}
        
        Boolean nowIsWithinBusinessHours = true;
        
        if(businessHrs != null) {
        	nowIsWithinBusinessHours = BusinessHours.isWithin(businessHrs.id, nowDateTime);
        	//BusinessHours.nextStartDate() will return TODAY if still within hours-of-operation.  +16 is the safest alternative (since we should only hit the 'nextBusinessDay' block after 2pm today).
        	nextBusinessDay = BusinessHours.nextStartDate( businessHrs.id, DateTime.now().addHours(16) ).date();
        	todaysBusinessDay = BusinessHours.nextStartDate( businessHrs.id, DateTime.now() ).date(); //should return today if within or before today's business hours.
        }
        
        
        if(contextRepo.Proposed_Notice_Date__c == null) {
        	contextRepo.Proposed_Notice_Date__c = yesterdaysDate; 
        	system.debug('************* contextRepo.Proposed_Notice_Date__c == null' );
        }
        
        system.debug('currentHour0To23 = '+ currentHour0To23 );
        system.debug('intCurrentHour0To23 = '+ intCurrentHour0To23 );
        system.debug('todaysDate = '+ todaysDate );
        system.debug('todaysBusinessDay = '+ todaysBusinessDay );
        system.debug('nowDateTime = '+ nowDateTime );
        system.debug('nextBusinessDay = '+ nextBusinessDay );
        system.debug('contextRepo.Proposed_Notice_Date__c = ' + contextRepo.Proposed_Notice_Date__c);
        system.debug('yesterdaysDate = '+ yesterdaysDate );
        system.debug('requiredNoticeDate = '+ requiredNoticeDate );
    	
    	if(isPastCutoffTime) {
    	    //it is after 2pm
    	    system.debug('isPastCutoffTime ' );
    	    if(requiredNoticeDate <= todaysBusinessDay) {
    	    	//REQ'D date is today or earlier (but probably set to today).
    	    	system.debug('requiredNoticeDate <= todaysBusinessDay ' );
    	    	if(contextRepo.Proposed_Notice_Date__c == todaysBusinessDay) {
    	    		//no need to update -- it's already set to today.
    	    		needToSetProposedNoticeDate = false;
    	    	}else{
    	    		needToSetProposedNoticeDate = true;
    	    		newProposedNoticeDate = todaysBusinessDay;
    	    	}
    	    }else{
    	    	//REQ'D date is set to tomorrow or later.
    	    	system.debug('not requiredNoticeDate <= todaysBusinessDay ' );
    	    	if(contextRepo.Proposed_Notice_Date__c == nextBusinessDay) {
    	    		needToSetProposedNoticeDate = false;
    	    	}else{
    	    		needToSetProposedNoticeDate = true;
    	    		newProposedNoticeDate = nextBusinessDay;
    	    	}
    	    }
    	    
    	}else{
    		//it is prior to 2pm
    		system.debug('not isPastCutoffTime ' );
    		if(contextRepo.Proposed_Notice_Date__c == todaysBusinessDay) {
                //no need to update -- it's already set to today.
                needToSetProposedNoticeDate = false;
            }else{
                needToSetProposedNoticeDate = true;
                newProposedNoticeDate = todaysBusinessDay;
            }
    	}
    	
    	
    }
    
    /**
    * returns hour in day as string.
    * 'k' = Hour in day (1-24)  Number  24
    * 'H' = Hour in day (0-23)  Number  0
    */
    public String currentUserTime() {
	    Datetime cDT = System.now();
	    String timeToReturn = cDT.format('H'); //format() evaluates users timezone.
	    return timeToReturn;
    }
    
    private Boolean isWeekendDay(Date dateParam)
    {
    	Boolean result    = false;
    	Date startOfWeek  = dateParam.toStartOfWeek();
    	Integer dayOfWeek = dateParam.day() - startOfWeek.day();
    	result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
    	return result;
    }
    
    private Date addBusinessDays(Date StartDate, integer BusinessDaysToAdd )
    {
    	//Add or decrease in BusinessDaysToAdd days
    	Date finalDate = StartDate;
    	integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
    	while(BusinessDaysToAdd != 0)
    	{
    		finalDate = finalDate.AddDays(direction);
    		if (!isWeekendDay(finalDate))
    		{
    			BusinessDaysToAdd -= direction;
    		}
    	}
    	
    	return finalDate;
   }
    
    
    public PageReference updateProposedStartDate() {
    	
    	system.debug('**** newProposedNoticeDate= ' + newProposedNoticeDate );
    	
    	allowRefreshAfterAttemptedUpdate = true;
    	errorStringOnUpdate = '';
    	
    	try{
    		contextRepo.Proposed_Notice_Date__c = newProposedNoticeDate;
            update contextRepo;
    	}catch(Exception e){
    		errorStringOnUpdate = String.valueOf(e.getCause());
    		allowRefreshAfterAttemptedUpdate = false;
    	}
    	
    	return null;
    }
}