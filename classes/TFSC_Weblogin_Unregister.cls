public class TFSC_Weblogin_Unregister extends TFSC_Weblogin_Base {

	public  WebLoginWebServiceReply execute(String SGUID, String FinancialAccountNumber) {
	
		//get the weblogin PersonAccount contact id
		Contact webloginContact = findWebloginContactBySGUID(SGUID);
		
		if (webloginContact == null) {
			return new WebLoginWebServiceReply(-1, SGUID + ' is not a valid SGUID on Contact of RecType Weblogin');
		}
		
		
		//find the FA
		List<Financial_Account__c> faList = [
			select id
			from Financial_Account__c
			where Financial_Account_Number__c = :FinancialAccountNumber
		];
		
		if (faList.size()  <> 1) {
			return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Unregister cannot find FA to unregister - '+FinancialAccountNumber);
		}
		
		Id financialAccountId = faList[0].Id;
		
			
		List<Financial_Account_Customer__c> facList = [
			select id, Weblogin_Contact__c
			from Financial_Account_Customer__c
			where Financial_Account__c = :financialAccountId
			and Weblogin_Contact__c = :webloginContact.Id
		];
		
		
		//update the FAC record by removing the weblogin contact id
		if ( facList.size() <> 1) {
			return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Unregister cannot find FAC with SGUID to unregister - '+FinancialAccountNumber+' : '+SGUID);
		}
		
		Financial_Account_Customer__c fac = facList[0];
		fac.Weblogin_Contact__c = null;
		update fac;
		
		return new WebLoginWebServiceReply(0,'TFSC_Weblogin_Unregister completed  - '+FinancialAccountNumber+' : '+SGUID);
	}
}