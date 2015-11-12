trigger TFSC_CaseTrigger on Case (before insert, before update, after insert, after update) {

    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new TFSC_WebToCaseHandler())
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new TFSC_CaseOutComeHandler())
        .bind(TFSC_TriggerDispatcher.Evt.beforeupdate, new TFSC_CaseOutComeHandler())
        
		// NOTE: Performance enhancements to improve ETL job execution time.    
		// The following section of code commented because Collection_Recourse_Code__c
		// is no longer synced up to FA via. trigger. 
		// Instead this field is populated by ETL directly both to FA and Case object. 
		// Since collections cases are primarily readonly in SFDC as agents do not edit 
		// cases sourced from collection host, Collection_Recourse_Code__c values 
		// are pushed by source system (Collection host) it is ideal to get this data pushed via. ETL
		// Also it was observed that synchronously populating this attribute to FA via. Case trigger is 
		// blocking and impacts performance of ETL jobs pushing Cases, especially when dealing with
		// closed cases. 
		// 
        // Trigger code commented by Emma 
        // Test method from TFSC_CollectionsCaseHandlerTest that validates this functionality commented 
        // Prakash Dandapani, 14-Jul-2015
        
        /*start-------------------------------Emma P- 7/6/15 - Removed - ETL will populate the FA. Collection_Recourse_Code__c
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_CollectionsCaseHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_CollectionsCaseHandler())
        
        -------------------end*/
        
        .manage();

}