trigger TFSC_UserTrigger on User(before insert) {

    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.beforeinsert, new TFSC_UserHandlerJIT())
        .manage();

}