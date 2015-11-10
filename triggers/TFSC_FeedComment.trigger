trigger TFSC_FeedComment on FeedComment (after insert) {

	new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_FeedCommentHandler())
        .manage();

}