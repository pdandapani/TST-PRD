public with sharing class TFSC_SupportRequestsController {

    private final List<String> orderBys = new List<String> {
        ' ORDER BY CreatedDate desc',
        ' ORDER BY LastModifiedDate desc',
        ' ORDER BY CaseNumber',
        ' AND ClosedDate = NULL ORDER BY LastModifiedDate desc',
        ' AND ClosedDate != NULL ORDER BY LastModifiedDate desc'
    };

    public List<SupportRequest> supportReqs {get;private set;}
    public Integer orderBy {get;set;}

    public Boolean hasSupportRequests {
        get {
            return !(this.supportReqs == null || this.supportReqs.isEmpty());
        }
    }

    public TFSC_SupportRequestsController() {
        this.orderBy = 1; //last updated
        fetchSupportRequests();
    }

    public PageReference fetchSupportRequests() {

        if (TFSC_CommunitySettings.PERSONID != null ) {
            
            String contactId = TFSC_CommunitySettings.CONTACTID;
            String userId = UserInfo.getUserId();
            Set<Id> facIds = new Set<Id>{};


            for(Financial_Account_Customer__c fac : TFSC_CommunitySettings.findFinancialAccountCustomersForWeblogin()) {
                facIds.add(fac.Id);
            }

            String query = 
                'select Id, CaseNumber, Status, Financial_Account_Customer_Name__c, Service_Request_Subject__c, LastModifiedDate ' +
                'from Case where ContactId = :contactId and Financial_Account_Customer__c in :facIds';
            
            //how to sort
            query += this.orderBys[this.orderBy];

            //this feeds into a pageblocktable which is limited to 1000 items
            query += ' limit 1000';
            
            List<Case> reqs = Database.query(query);
            
            List<id> caseIds = new List<id>();
            for(Case req : reqs) {
                caseIds.add(req.id);
            }
            
            List<Case_LastViewed__c> clvList = [
                select Has_Viewed__c, Case__c
                from Case_LastViewed__c 
                where User__c = :userId 
                and Case__c in :caseIds
                and Has_Viewed__c = true  
            ];  
            
            set<Id> hadViewedCaseIds = new set<Id>();
            for(Case_LastViewed__c clv : clvList) {
                hadViewedCaseIds.add(clv.Case__c);
            } 
            
            
            this.supportReqs = new List<SupportRequest>{};
            for(Case req : reqs ) {
                
                this.supportReqs.add(new SupportRequest(req, !hadViewedCaseIds.contains(req.id)));
            }
        }

        return null;
    }
    //caseData.Case_LastViews__r.isEmpty() ? true : !caseData.Case_LastViews__r[0].Has_Viewed__c;

    public class SupportRequest {

        public Boolean hasUpdate {get;private set;}
        public Case details {get;private set;}
        public String style {get { return this.hasUpdate ? 'font-weight:bold;' : ''; }}

        public SupportRequest(Case caseData, boolean hasUpdate) {
            //the user has an update if:  they have never seen the case, or if Has_Viewed [Last Update] is false
            this.hasUpdate = hasUpdate;
            this.details = caseData;
        }

    }

}