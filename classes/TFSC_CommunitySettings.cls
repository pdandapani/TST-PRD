/**
* @author: Salesforce Services
* @date:    2014-08-06
* @description: Settings/Utility class for the TFS/LFS Communities
*               
* @log:
* -----------------------------------------------------------------------------
*    Developer                    Date                Description
* -----------------------------------------------------------------------------
*    Scott W	                2014-08-06          creation
*   
*/
public without sharing class TFSC_CommunitySettings {
	

	public static final String DEFAULT_PAGE; //the default page of the internal site
	public static final String REDIRECT_URL; //the url to redirect to if the user has broken out of the iframe
	public static final String CONTACTID; //the contact associated with the context user
	public static final String PERSONID; //the person account associated with the community user record

	public static final Id RECTYPEID_SUPPORTREQ; //Case Support Request recordtype id
	public static final Id RECTYPEID_DUEDATECHANGE; //Case Support Request recordtype id

	static {

		//guaranteed to return our own user record, + if not a community user we want personId to be null anyway
		User u = [select Id, ContactId, Contact.AccountId from User where Id = :UserInfo.getUserId()];
		CONTACTID = u.ContactId;
		PERSONID = u.Contact.AccountId;
		RECTYPEID_SUPPORTREQ = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support Request').getRecordTypeId();
		RECTYPEID_DUEDATECHANGE = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Due Date Change Request').getRecordTypeId();

		Community_Settings__c settings = Community_Settings__c.getInstance(Site.getName());
		if (settings != null) {
			DEFAULT_PAGE = settings.Default_VF_Page__c;
			REDIRECT_URL = settings.Redirect_Url__c;
		}
		else {
			DEFAULT_PAGE = '';
			REDIRECT_URL = '';
		}

	}

	private static Id CHATTERNETWORKID;
	public static Id getNetworkId() {
		if (CHATTERNETWORKID == null) {
			List<Network> networks = [select Id from Network where Name = :Site.getName()];
			if (!networks.isEmpty()) {
				CHATTERNETWORKID = networks[0].Id;
			}
		}
		return CHATTERNETWORKID;
	}

	private static List<SelectOption> tfsAccts;
	public static List<SelectOption> tfsAccounts() {

		if (tfsAccts == null) {
	        tfsAccts = new List<SelectOption>{};

	        if (PERSONID != null) {
		        //fetch financial account customers directly associated to person account
		        for(Financial_Account_Customer__c fac : findFinancialAccountCustomersForWeblogin()) {
		            tfsAccts.add(new SelectOption(
		                fac.Id, fac.Financial_Account__r.Name
		            ));
		        }

		    }

		    //prepend a select indicator if there is more than one associated financial account customer
	        if (tfsAccts.size() > 1) {
	            tfsAccts.add(0, new SelectOption(
	                '', '--None--'
	            ));
	        }
	        else if (tfsAccts.isEmpty()) {
	        	tfsAccts.add(new SelectOption(
	        		'', '--No Accounts Found--'
	        	));
	        }

	    }

	    return tfsAccts;

    }

    // Pass the resource name
    public static String GetResourceURL(String resourceName){

        // Fetching the resource
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

        // Checking if the result is returned or not
        if(resourceList.size() == 1){

           // Getting namespace
           String namespace = resourceList[0].NamespacePrefix;
           // Resource URL
           return '/tfs/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        else return '';
    }

    public static List<FeedItem> fetchSupportRequestAttachments(Id caseId) {
    	List<FeedItem> items = new List<FeedItem>{};
    	for(FeedItem item : [
            select RelatedRecordId, ContentFileName, ContentSize, CreatedBy.FirstName, LastModifiedDate
            from FeedItem
            where ParentId = :caseId
            and Type = 'ContentPost'
            and Visibility = 'AllUsers'
            order by CreatedDate desc
        ]) {
        	//RelatedRecordId cannot be filterd in a SOQL call
    		if (item.RelatedRecordId != null) {
                items.add(item);
            }
        }
        return items;
    }

    public static Database.SaveResult createCase(Case newCase) {

    	//get and assign the FACs FA
    	List<Financial_Account_Customer__c> facs = [
    		select Id, Financial_Account__c, Financial_Account_Customer__c
    		from Financial_Account_Customer__c 
    		where Id = :newCase.Financial_Account_Customer__c
    		limit 1
    	];
    	if (!facs.isEmpty()) {
    		newCase.Financial_Account__c = facs[0].Financial_Account__c;
    		newCase.Financial_Account_Customer_ID__c = facs[0].Financial_Account_Customer__c;
    	}

    	//sets which site the case was created from
    	String siteName = Site.getName();
    	if (String.isNotBlank(siteName)) {
    		newCase.Origin = siteName + ' Community';
    	}

    	//assign the correct rules
    	List<AssignmentRule> rules = [select Id from AssignmentRule where SObjectType = 'Case' and Active = true limit 1];
    	if (!rules.isEmpty()) {
	    	Database.DMLOptions dmlOpts = new Database.DMLOptions();
			dmlOpts.assignmentRuleHeader.assignmentRuleId = rules[0].Id;
			newCase.setOptions(dmlOpts);
		}

    	Database.SaveResult sr = Database.insert(newCase);
    	return sr;
    }


    private static List<Financial_Account_Customer__c> financialAcctCusts;
    public static List<Financial_Account_Customer__c> findFinancialAccountCustomersForWeblogin() {
		
		if (financialAcctCusts == null) {
			financialAcctCusts = new List<Financial_Account_Customer__c>{};
			if (CONTACTID != null) {
				financialAcctCusts.addAll(new List<Financial_Account_Customer__c>([
					SELECT Id, Name, Financial_Account__r.Name, Financial_Account__r.Payment_Date_Next__c, Financial_Account__r.RecordType.Name
					FROM Financial_Account_Customer__c 
					WHERE Weblogin_Contact__c = :CONTACTID
					and Visible_to_Customer__c = true
				]));
			}
		}
		return financialAcctCusts;

	}

}