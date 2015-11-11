trigger TFSC_CaseComment on CaseComment (after insert, before insert) {

	new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_CaseCommentHandler())
        .manage();
        
    if (Trigger.isInsert && Trigger.isBefore) {
    	for (CaseComment comment : (List<CaseComment>)trigger.new) {
    		if (comment.CommentBody != null && comment.CommentBody.length() > 3960) {
    			comment.CommentBody.addError('Please restrict comments to a maximum of 3960 characters.');
    		}
    	}
    }

}