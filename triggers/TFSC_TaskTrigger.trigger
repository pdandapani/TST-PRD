trigger TFSC_TaskTrigger on Task (after insert, after update) {
    
    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_TaskTriggerHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_TaskTriggerHandler())
        .manage();

}