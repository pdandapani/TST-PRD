global with sharing class TFSC_CommunitiesIntermediateController {

    public String defaultPage {
        get {
            return TFSC_CommunitySettings.DEFAULT_PAGE;
        }
    }

    global TFSC_CommunitiesIntermediateController() {

    }

    @RemoteAction
    global static void noop() {
        return;
    }

}