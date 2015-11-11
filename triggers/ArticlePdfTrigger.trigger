trigger ArticlePdfTrigger on ArticlePDF__c (after update) {

	//this trigger is not bulkifed sicne insert 1 pdf at a time.
	for(ArticlePDF__c artPdf : Trigger.new) {
		if ( artPdf.ArticlePdfContentVersionId__c <> null) {
			ContentModel.moveContentToLibrary(artPdf.ArticlePdfContentVersionId__c,
				'KnowledgeArticles');
		}
	}

}