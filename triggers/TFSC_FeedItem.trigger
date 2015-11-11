trigger TFSC_FeedItem on FeedItem (after insert) {

	new TFSC_TriggerDispatcher()
        .bind(TFSC_TriggerDispatcher.Evt.afterinsert, new TFSC_FeedItemHandler())
        .manage();

}