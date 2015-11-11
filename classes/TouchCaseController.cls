/**
* @author: Salesforce Services
* @date:    2014-09-10
* @description: Helper class for the TouchCase VF Page.
*
*  Each User who views a case (where this page/controller are loaded) touches an 
*  "last viewed" child object to the case which records their presence
*               
* @log:
* -----------------------------------------------------------------------------
*    Developer                    Date                Description
* -----------------------------------------------------------------------------
*    Scott W	                2014-09-10          creation
*   
*/public with sharing class TouchCaseController {

	private Id caseId;
	private Case_LastViewed__c lastViewed;

	public TouchCaseController(ApexPages.StandardController stdController) {
		this.caseId = stdController.getId();
		if (this.caseId != null) {
			//find the lastviewed record of the current user
			List<Case_LastViewed__c> views = new List<Case_LastViewed__c>([
				select Id
				from Case_LastViewed__c
				where Case__c = :this.caseId
				and User__c = :UserInfo.getUserId()
			]);
			if (!views.isEmpty()) {
				this.lastViewed = views[0];
			}
		}
	}

	public PageReference touchCase() {
		
		if (this.caseId != null) {
			if (this.lastViewed == null) {
				this.lastViewed = new Case_LastViewed__c(
					Case__c = this.caseId,
					User__c = UserInfo.getUserId()
				);
			}

			this.lastViewed.Last_Viewed_Date__c = System.now();
			upsert this.lastViewed;
		}

		return null;
	}
	
}