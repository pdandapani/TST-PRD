trigger TFSC_FinancialAccountContactTrigger on Financial_Account_Customer__c (before insert, before update, after insert, after update) {
    
    
    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.beforeupdate, new TFSC_TriggerVariableHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_DeactivateBorrowerHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_DeactivateBorrowerHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_FinancialActEditCaseCreateHandler())
        .manage();
    
    
}