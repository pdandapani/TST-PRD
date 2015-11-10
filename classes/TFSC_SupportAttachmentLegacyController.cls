public with sharing class TFSC_SupportAttachmentLegacyController {
    private Case supportRequest;

    public TFSC_SupportAttachmentLegacyController(ApexPages.StandardController stdController) {
        supportRequest = (Case)(stdController.getRecord());
    }
    
    public static Id ChatterNetworkId {
        get {
            return TFSC_CommunitySettings.getNetworkId();
        }
    }
    
    private transient FeedItem pNewFeedItem = null;
    public FeedItem NewFeedItem {
        get {
            if (pNewFeedItem == null) {
                pNewFeedItem = new FeedItem();
                pNewFeedItem.ParentId = supportRequest.Id;
                pNewFeedItem.NetworkScope = 'AllNetworks';
                pNewFeedItem.Body = 'Support Request Attachment';
                pNewFeedItem.Type = 'ContentPost';
                pnewFeedItem.Visibility = 'AllUsers';
            }
            return pNewFeedItem;
        }
        set; 
    }
    
    public PageReference InsertAttachment() {
        //Database.DMLOptions dlo = new Database.DMLOptions();
        //dlo.EmailHeader.triggerUserEmail = true;
        
        //database.insert(NewFeedItem, dlo);
        insert NewFeedItem;

        PageReference pr = Page.TFSC_SupportRequest;
        pr.getParameters().put('id', supportRequest.Id);
        return pr;  
    }
}