public with sharing class TFSC_RequestDueDateChangeController {
	
	private Case newCase;

	public List<DueDate> dueDates {get;private set;}
	public List<AcctType> acctTypes {get;private set;}
	public String dateDue {get;set;}
	public String acctType {get;set;}
	public Integer requestDate {get;set;}
	public List<SelectOption> tfsAccts {
        get {
            return TFSC_CommunitySettings.tfsAccounts(); 
        }
    }

	public TFSC_RequestDueDateChangeController(ApexPages.StandardController stdController) {

		//set default values
        this.newCase = (Case)stdController.getRecord();
        this.newCase.AccountId = TFSC_CommunitySettings.PERSONID;
        this.newcase.RecordTypeId = TFSC_CommunitySettings.RECTYPEID_DUEDATECHANGE;
        this.newCase.Service_Request_Subject__c = 'Due Date Change Request';

        this.dueDates = new List<DueDate>{};
        this.acctTypes = new List<AcctType>{};
        for(Financial_Account_Customer__c fac : TFSC_CommunitySettings.findFinancialAccountCustomersForWeblogin()) {
        	this.dueDates.add(new DueDate(fac.Id, fac.Financial_Account__r.Payment_Date_Next__c));
        	this.acctTypes.add(new AcctType(fac.Id, fac.Financial_Account__r.RecordType.Name));
        }

        this.requestDate = 1;
        this.dateDue = '';
        this.acctType = '';
        //this.tfsAccts = TFSC_CommunitySettings.tfsAccounts();
        if (this.tfsAccts.size() == 1 && String.IsNotBlank(this.tfsAccts[0].getValue())) {
        	this.dateDue = dueDates[0].dateDue;
        	this.acctType = acctTypes[0].type;
        }

	}

	public PageReference create() {
        //TODO: need to validate
        if (!this.newCase.I_Agree_to_Terms_and_Conditions__c) {
        	this.newCase.I_Agree_to_Terms_and_Conditions__c.addError('You must agree to the Terms & Conditions');
        	return null;
        }

        PageReference pr;
        //try {
            Database.SaveResult sr = TFSC_CommunitySettings.createCase(this.newCase);
            pr = Page.TFSC_SupportRequest;
            pr.getParameters().put('id', sr.getId());
        //}
        //catch(System.DmlException de) {}

        return pr;
    }

	public class DueDate {

		public Id facId {get;private set;}
		public String dateDue {get;private set;}

		public DueDate(Id facId, Date dateDue) {
			this.facId = facId;
			if (dateDue != null) {
				this.dateDue = String.valueOf(dateDue.day());
				if (this.dateDue.endsWith('1')) {
					this.dateDue += 'st';
				}
				else if (this.dateDue.endsWith('2')) {
					this.dateDue += 'nd';
				}
				else if (this.dateDue.endsWith('3')) {
					this.dateDue += 'rd';
				}
				else {
					this.dateDue += 'th';
				}
			}
			else {
				this.dateDue = '';
			}
		}

	}

	public class AcctType {

		public Id facId {get;private set;}
		public String type {get;private set;}

		public AcctType(Id facId, String type) {
			this.facId = facId;
			this.type = type;
		}

	}

}