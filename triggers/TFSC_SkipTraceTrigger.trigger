trigger TFSC_SkipTraceTrigger on Skip_Trace__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    
    
    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_SkipTraceUpdateSyncPF11Handler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_SkipTraceUpdateSyncPF11Handler())
        .manage();
    
    
    
}