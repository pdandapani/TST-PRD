public with sharing class TFSC_SupportCommentController {

    private Id parentCaseId {get;private set;}
    public CaseComment newComment {get;private set;}
    
    public TFSC_SupportCommentController(ApexPages.StandardController stdController) {

        this.parentCaseId = stdController.getId();
        this.newComment = new CaseComment(
            ParentId = this.parentCaseId
        );

    }

    public PageReference createComment() {
		
		Database.DMLOptions dlo = new Database.DMLOptions();
		dlo.EmailHeader.triggerUserEmail = true;
		
		database.insert(this.newComment, dlo);

        PageReference pr = Page.TFSC_SupportRequest;
        pr.getParameters().put('id', this.parentCaseId);
        return pr;

    }

}