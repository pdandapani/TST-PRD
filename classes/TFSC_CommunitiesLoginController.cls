public with sharing class TFSC_CommunitiesLoginController {

	public String redirectUrl {
		get {
			return TFSC_CommunitySettings.REDIRECT_URL;
		}
	}

	public TFSC_CommunitiesLoginController() {
		
	}

	public PageReference redirect() {
		return new PageReference(this.redirectUrl);
	}
	
}