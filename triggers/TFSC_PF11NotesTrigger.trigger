trigger TFSC_PF11NotesTrigger on PF11_Notes__c (after insert, after update) {
    
    
    
    new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_PF11NotesSkipTraceSyncHandler())
        .bind(TFSC_TriggerDispatcher.Evt.afterupdate, new TFSC_PF11NotesSkipTraceSyncHandler())
        .manage();
    
    
    
    
}