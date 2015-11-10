public class TFSC_Weblogin_Register extends TFSC_Weblogin_Base{
    
    public WebLoginWebServiceReply execute(String SGUID, String FinancialAccountNumber, String FinancialAccountBorrowerNumber) {
        
        Contact webloginContact = findWebloginContactBySGUID(SGUID);
        
        if (webloginContact == null) {
        	return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Register cannot match SGUID - '+SGUID);
        }
        
        //find the parent customerAccount
        Id parentCustomerAccount = webloginContact.CustomerPersonAccount__c;
          
          
        //find the FA
        List<Financial_Account__c> faList = [
            select id
            from Financial_Account__c
            where Financial_Account_Number__c = :FinancialAccountNumber
        ];
        
        if (faList.size()  <> 1) {
            return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Register cannot find FA to register - '+FinancialAccountNumber);
        }
        
        Id financialAccountId = faList[0].Id;
        
        //get the FAC record
        List<Financial_Account_Customer__c> facList = [
            select id, Account__c, Weblogin_Contact__c
            from Financial_Account_Customer__c
            where Financial_Account__c = :financialAccountId
            and Customer_Borrower_Number__c = :FinancialAccountBorrowerNumber
        ];
        
        if (facList.size() <> 1) {
            //cannot find the customerPersonAccount - data problem
            return new WebLoginWebServiceReply(-1,'cannot use FinancialAccountNumber & FinancialAccountBorrowerNumber to find Financial_Account_Customer__c. Aborting');
        }
        
        Financial_Account_Customer__c fac = facList[0];
        
        /*//check if FinancialAccountNumber & FinancialAccountBorrowerNumber belongs to the same parent customerAccount
        if ( fac.Account__c <> parentCustomerAccount) {
            // we have a data consistency issue - abort now
            return new WebLoginWebServiceReply(-1,'TFSC_Weblogin_Register : Data consistency issue for SGUID '+ SGUID);
        }   */
        
        //update the FAC record with the webloginPersonAccount.contactId
        fac.Weblogin_Contact__c = webloginContact.Id;
        System.Debug('TFSC_Weblogin_Register : SGUID = '+SGUID+'   webloginAccount.PersonContactId = '+ webloginContact.Id);
        update fac;
        
        return new WebLoginWebServiceReply(0,'TFSC_Weblogin_Register : register SGUID '+SGUID+' to FAC '+fac.id+' is successful' +
             '  webloginAccount.PersonContactId = '+ webloginContact.Id);
    }
}