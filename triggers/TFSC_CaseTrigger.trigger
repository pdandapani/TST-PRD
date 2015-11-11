trigger TFSC_CaseTrigger on Case (before insert, before update, after insert, after update) {

	new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new TFSC_WebToCaseHandler())
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new TFSC_CaseOutComeHandler())
        .bind(TFSC_TriggerDispatcher.Evt.beforeupdate, new TFSC_CaseOutComeHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_CollectionsCaseHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_CollectionsCaseHandler())
        .manage();

}