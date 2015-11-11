public with sharing class TFSC_NewSupportRequestController {

    private Case newCase;

	public List<SelectOption> tfsAccts {
        get {
            return TFSC_CommunitySettings.tfsAccounts();
        }
    }

    public TFSC_NewSupportRequestController(ApexPages.StandardController stdController) {

        //set default values
        this.newCase = (Case)stdController.getRecord();
        this.newCase.AccountId = TFSC_CommunitySettings.PERSONID;
        this.newcase.RecordTypeId = TFSC_CommunitySettings.RECTYPEID_SUPPORTREQ;

    }

    public PageReference create() {
        
        PageReference pr;

        if (this.newCase.Financial_Account_Customer__c != null) {

            Database.SaveResult sr = TFSC_CommunitySettings.createCase(this.newCase);
            if (sr.isSuccess()) {
                pr = Page.TFSC_SupportRequest;
                pr.getParameters().put('id', sr.getId());
            }
            else {
                pr = Page.TFSC_SupportRequests;
            }

        }
        else {
            //add error?
        }

        return pr;
    }

}