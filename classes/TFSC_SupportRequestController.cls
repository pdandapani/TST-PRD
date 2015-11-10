public with sharing class TFSC_SupportRequestController {

    private Case supportReq;
    private Case_LastViewed__c lastViewed;

    public List<PublicComment> publicComments {get;private set;}
    public List<FileAttachment> fileAttachments {get;private set;}

    public Boolean hasComments {
        get {
            return !this.publicComments.isEmpty();
        }
    }

    public Boolean hasAttachments {
        get {
            return !this.fileAttachments.isEmpty();
        }
    }
    
    public Boolean isSupportRequest {
        get {
            return this.supportReq.RecordTypeId == TFSC_CommunitySettings.RECTYPEID_SUPPORTREQ;
        }
    }
    public Boolean isDueDateChangeRequest {
        get {
            return this.supportReq.RecordTypeId == TFSC_CommunitySettings.RECTYPEID_DUEDATECHANGE;
        }
    }

    public TFSC_SupportRequestController(ApexPages.StandardController stdController) {

        this.supportReq = (Case)stdController.getRecord();

        fetchLastViewed();
        fetchPublicComments();
        fetchFileAttachments();
    }

    public void touchCase() {
        if (this.lastViewed != null) {
            this.lastViewed.Last_Viewed_Date__c = System.now();
            update this.lastViewed;
        }
        else {
            insert (this.lastViewed = new Case_LastViewed__c(
                Case__c = this.supportReq.Id,
                User__c = UserInfo.getUserId(),
                Last_Viewed_Date__c = System.now()
            ));
        }
    }

    private void fetchLastViewed() {
        List<Case_LastViewed__c> views = new List<Case_LastViewed__c>([
            select Id, Has_Viewed__c
            from Case_LastViewed__c
            where Case__c = :this.supportReq.Id
            and User__c = :UserInfo.getUserId()
            limit 1
        ]);
        if (!views.isEmpty()) {
            this.lastViewed = views[0];
        }
    }

    private void fetchPublicComments() {
        this.publicComments = new List<PublicComment>{};
        for(CaseComment cc : [
            select Id, CreatedDate, LastModifiedDate, CommentBody, CreatedBy.FirstName, LastModifiedBy.FirstName
            from CaseComment
            where ParentId = :this.supportReq.Id
            and IsPublished = true
            order by CreatedDate desc
        ]) {
            this.publicComments.add(new PublicComment(cc));
        }
    }

    private void fetchFileAttachments() {
        this.fileAttachments = new List<FileAttachment>{};
        for(FeedItem file : TFSC_CommunitySettings.fetchSupportRequestAttachments(this.supportReq.Id)) {
            this.fileAttachments.add(new FileAttachment(file));
        }
    }

    public PageReference addComment() {
        PageReference pr = Page.TFSC_SupportComment;
        pr.getParameters().put('id', this.supportReq.Id);
        return pr; 
    }

    public PageReference addAttachment() {
        PageReference pr = Page.TFSC_SupportAttachment;
        pr.getParameters().put('id', this.supportReq.Id);
        return pr;
    }

    public PageReference addAttachmentLegacy() {
        PageReference pr = Page.TFSC_SupportAttachmentLegacy;
        pr.getParameters().put('id', this.supportReq.Id);
        return pr;
    }

// Added by Sandeep For First Name NUll Issue 
 public class PublicComment {

        public String CommentLabel {get;set;}
        public String CommentBody {get;set;}
        public CaseComment CommentObject {get;set;}

        public PublicComment(CaseComment cc) {
          this.CommentObject = cc;
            this.CommentBody = cc.CommentBody;
           if(cc.CreatedBy.FirstName == NULL)
            {
           		User user=[SELECT Contact.FirstName,Contact.Web_CompanyName__c from User Where ID=: cc.createdById];              
       			if (user.Contact != null) {
           			if(User.Contact.firstname == NULL){                         
          				this.CommentLabel = String.format('Created By: {0} ({1})', new List<String> {
             				User.Contact.Web_CompanyName__c,
             				cc.CreatedDate.format()
                      	});
      				}
             		ELSE if(User.Contact.firstname != NULL){
              			this.CommentLabel = String.format('Created By: {0} ({1})', new List<String> {
                  			User.Contact.firstname,                  
                  			cc.CreatedDate.format()
                      	});
          			}
           		}
            }
            
            else{
            this.CommentLabel = String.format('Created By: {0} ({1})', new List<String> {
                  cc.CreatedBy.FirstName,                  
                  cc.CreatedDate.format()
                      });
            }
            if (cc.LastModifiedDate > cc.CreatedDate) {
                this.CommentLabel += String.format(' | Last Modified By: {0} ({1})', new List<String> {
                    cc.LastModifiedBy.FirstName,
                    cc.LastModifiedDate.format()
                });
            }
        }

    } 
    /*
    //Below PublicCommnent Class commented after sandeep's change and merge with Brandon
    public class PublicComment {

        public String CommentLabel {get;set;}
        public String CommentBody {get;set;}
        public CaseComment CommentObject {get;set;}

        public PublicComment(CaseComment cc) {
            this.CommentObject = cc;
            this.CommentBody = cc.CommentBody;
            this.CommentLabel = String.format('Created By: {0} ({1})', new List<String> {
                cc.CreatedBy.FirstName,
                cc.CreatedDate.format()
            });
            if (cc.LastModifiedDate > cc.CreatedDate) {
                this.CommentLabel += String.format(' | Last Modified By: {0} ({1})', new List<String> {
                    cc.LastModifiedBy.FirstName,
                    cc.LastModifiedDate.format()
                });
            }
        }

    }
    */

   public class FileAttachment {
 
        private Double SPACE_KB = 1024;
        private Double SPACE_MB = 1024 * SPACE_KB;
        private Double SPACE_GB = 1024 * SPACE_MB;
 
        public String id {get;private set;}
        public String name {get;private set;}
        public String creator {get;private set;}
        public String len {get;private set;}
        public String lastModified {get;private set;}
 
        public FileAttachment(FeedItem file) {
            this.id = file.RelatedRecordId;
            this.name = file.ContentFileName;
            //New lines 140 - 152 added by Sandeep File attachment CreatedBy NUll
            //this.creator = file.CreatedBy.FirstName;
            if(file.createdby.FirstName == NULL)
            {
                User user=[SELECT Contact.FirstName,Contact.Web_CompanyName__c from User Where ID=: file.createdById];             
                if (user.Contact != null) {
	             if(User.Contact.firstname == NULL)
	               this.creator = User.Contact.Web_CompanyName__c;
	                
	             ELSE if(User.Contact.firstname != NULL)
	           
	              this.creator =  User.Contact.firstname;
               }
            }
            else{this.creator = file.CreatedBy.FirstName;}           
            this.lastModified = file.LastModifiedDate.format();
 
            //format file length
            if (file.ContentSize < SPACE_KB) {
                this.len = file.ContentSize.format() + ' Byte(s)';
            }
            else if (file.ContentSize < SPACE_MB) {
                this.len = (file.ContentSize / SPACE_KB).round().format() + ' KB';
            }
            else if (file.ContentSize < SPACE_GB) {
                this.len = (file.ContentSize / SPACE_MB).round().format() + ' MB';
            }
            else {
                this.len = (file.ContentSize / SPACE_GB).round().format() + ' GB';
            }       
    
        }
 
 
    }

}