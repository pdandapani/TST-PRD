public with sharing class TFSC_SupportAttachmentController {

    public static Id ChatterNetworkId {
        get {
            return TFSC_CommunitySettings.getNetworkId();
        }
    }

    public TFSC_SupportAttachmentController(ApexPages.StandardController stdController) {

    }

}