public with sharing class TFSC_PreformCaseController {

    private static final Id RECTYPEID_SUPPORTREQ = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support Request').getRecordTypeId();
    private static final Id RECTYPEID_DUEDATECHANGE = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Due Date Change Request').getRecordTypeId();
    private static final String CASE_PREFIX = Case.SObjectType.getDescribe().getKeyPrefix();
    
    private Financial_Account_Customer__c fac;

    public TFSC_PreformCaseController(ApexPages.StandardSetController stdSetController) {
        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            Id facId = (Id)ApexPages.currentPage().getParameters().get('id');
            List<Financial_Account_Customer__c> facs = new List<Financial_Account_Customer__c>([
                select 
                    Id, 
                    Name, 
                    Weblogin_Contact__c, 
                    Weblogin_Contact__r.Name,
                    Financial_Account__c,
                    Financial_Account__r.Name,
                    Shell_Case_ContactId__c,
                    Shell_Case_ContactId__r.Name,
                    Account__c
                    
                from Financial_Account_Customer__c
                where Id = :facId
            ]);
            if (!facs.isEmpty()) {
                this.fac = facs[0];
            }
        }
    }
    
    private transient Contact pNewShellCaseContact;
    public Contact NewShellCaseContact {
    	get{
	    	if (pNewShellCaseContact == null) {
	    		pNewShellCaseContact = new Contact();
	    	}
	    	return pNewShellCaseContact;
    	}
    }
    
    private Boolean pHasExistingContact = null;
    public Boolean HasExistingContact {
    	get{
    		if (pHasExistingContact == null) {
    			pHasExistingContact = (fac != null && (fac.Weblogin_Contact__c != null || fac.Shell_Case_ContactId__c != null));
    		}
    		
    		return pHasExistingContact;
    	}
    }
    
    public PageReference preformCaseWithNewContact() {
    	boolean hasError = false;
    	if (NewShellCaseContact.FirstName == null) {
    		NewShellCaseContact.FirstName.addError('First Name is required.');
    		hasError = true;
    	}
    	if (NewShellCaseContact.LastName == null) {
    		NewShellCaseContact.LastName.addError('Last Name is required.');
    		hasError = true;
    	}
    	if (NewShellCaseContact.Email == null) {
    		NewShellCaseContact.Email.addError('Email is required.');
    		hasError = true;
    	}
    	if (hasError) {
    		return null;
    	}
    	TFSC_CommunityAccountUtil autil = new TFSC_CommunityAccountUtil();
    	newShellCaseContact.AccountId = autil.acctId;
    	newShellCaseContact.CustomerPersonAccount__c = fac.Account__c;   //link webloginPersonAccount to parent customerPersonAccount
    	insert newShellCaseContact;
    	
        PageReference pr = new PageReference('/home/home.jsp');
        if (this.fac != null) {
        	fac.Shell_Case_ContactId__c = newShellCaseContact.Id;
        	update fac;

            String cancelUrl = (new ApexPages.StandardController(new Financial_Account_Customer__c(Id = this.fac.Id))).view().getUrl();
            String pageUrl = ApexPages.currentPage().getUrl().toLowerCase();
            Id recordType = RECTYPEID_SUPPORTREQ;
            if (pageUrl.contains('preformduedatechangerequest')) {
                recordType = RECTYPEID_DUEDATECHANGE;
            }
            
            Id webloginContactId = newShellCaseContact.Id;
            String webLoginName = newShellCaseContact.Name;

            pr = new PageReference('/' + CASE_PREFIX + '/e');
            pr.getParameters().putAll(new Map<String,String> {
                'RecordType' => recordType,
                'cancelURL' => cancelUrl,
                //'cas21' => '1', //uncomment to autocheck 'Assign using active assignment rules'
                //contact
                'cas3' => webLoginName,
                'cas3_lkid' => webloginContactId,
                //FAC
                'CF00N70000003Cj6c' => this.fac.Name,
                'CF00N70000003Cj6c_lkid' => this.fac.Id,
                //FA
                'CF00N70000003Cj6d' => this.fac.Financial_Account__r.Name,
                'CF00N70000003Cj6d_lkid' => this.fac.Financial_Account__c
            });
        }
        return pr;
    }

    public PageReference preformCase() {
    	if (!HasExistingContact) {
    		return null;
    	}
        PageReference pr = new PageReference('/home/home.jsp');
        if (this.fac != null) {

            String cancelUrl = (new ApexPages.StandardController(new Financial_Account_Customer__c(Id = this.fac.Id))).view().getUrl();
            String pageUrl = ApexPages.currentPage().getUrl().toLowerCase();
            Id recordType = RECTYPEID_SUPPORTREQ;
            if (pageUrl.contains('preformduedatechangerequest')) {
                recordType = RECTYPEID_DUEDATECHANGE;
            }
            
            Id webloginContactId = fac.Weblogin_Contact__c != null ? fac.Weblogin_Contact__c : fac.Shell_Case_ContactId__c;
            String webLoginName = fac.Weblogin_Contact__c != null ? fac.Weblogin_Contact__r.Name : fac.Shell_Case_ContactId__r.Name;

            pr = new PageReference('/' + CASE_PREFIX + '/e');
            pr.getParameters().putAll(new Map<String,String> {
                'RecordType' => recordType,
                'cancelURL' => cancelUrl,
                //'cas21' => '1', //uncomment to autocheck 'Assign using active assignment rules'
                //contact
                'cas3' => webLoginName,
                'cas3_lkid' => webloginContactId,
                //FAC
                'CF00N70000003Cj6c' => this.fac.Name,
                'CF00N70000003Cj6c_lkid' => this.fac.Id,
                //FA
                'CF00N70000003Cj6d' => this.fac.Financial_Account__r.Name,
                'CF00N70000003Cj6d_lkid' => this.fac.Financial_Account__c
            });
        }
        return pr;
    }

}