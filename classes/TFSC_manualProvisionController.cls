public class TFSC_manualProvisionController {

	public String SGUID{get;set;}
	public String AccountNumber{get;set;}
	public String BorrowerPosition{get;set;}
	public String ManagementEmail{get;set;}
	public String userid{get;set;}
	
	public String commandExecuted{get;set;}
	public String resultCode{get;set;}
	public String resultMessage{get;set;}
	
	public PageReference doProvisionWebAccount() {
		TFSC_Weblogin_Provision provision = new TFSC_Weblogin_Provision();
		WebLoginWebServiceReply reply = provision.execute(SGUID, AccountNumber, BorrowerPosition,ManagementEmail, userid,'','','');
		
		setLastCommanand('Provision WebAccount');
		setReply(reply);
		return null;
	}
	
	public PageReference doRegisterWebAccountToFinancialAccountCustomer() {
		ManagementEmail = null;
		userid = null;
		
		TFSC_Weblogin_Register register = new TFSC_Weblogin_Register();
		WebLoginWebServiceReply reply = register.execute(SGUID, AccountNumber, BorrowerPosition);
		
		
		setLastCommanand('Register WebAccount');
		setReply(reply);
		return null;
	}
	
	public PageReference doUnRegisterWebAccountToFinancialAccountCustomer() {
		BorrowerPosition = null;
		ManagementEmail = null;
		userid = null;
		
		TFSC_Weblogin_Unregister unregister = new TFSC_Weblogin_Unregister();
		WebLoginWebServiceReply reply = unregister.execute(SGUID, AccountNumber);
		
		setLastCommanand('Unregister WebAccount');
		setReply(reply);
		return null;
	}
	
	public PageReference doDeProvisionWebAccount() {
		AccountNumber = null;
		BorrowerPosition = null;
		ManagementEmail = null;
		userid = null;

		TFSC_Weblogin_Unprovision deprovision = new TFSC_Weblogin_Unprovision();
		WebLoginWebServiceReply reply = deprovision.execute(SGUID);

		setLastCommanand('Deprovision WebAccount');
		setReply(reply);
		return null;
	}
	
	public PageReference doChangeWebAccountProfile() {
		AccountNumber = null;
		BorrowerPosition = null;

		TFSC_Weblogin_ProfileUpdate profileUpdate = new TFSC_Weblogin_ProfileUpdate();
		WebLoginWebServiceReply reply = profileUpdate.execute(SGUID,ManagementEmail,userid,'','','');
		
		setLastCommanand('ChangeProfile');
		setReply(reply);
		return null;
	}
	
	public PageReference doUnReadMessageCountSinceLastLogin() {
		AccountNumber = null;
		BorrowerPosition = null;
		ManagementEmail = null;
		userid = null;
		
		TFSC_Weblogin_UnreadMsgCount unreadMsgCount = new TFSC_Weblogin_UnreadMsgCount();
		WebLoginWebServiceReply reply = unreadMsgCount.execute(SGUID);
		
		setReply(reply);
		return null;
	}
  
  	private void setLastCommanand(String command) {
  		commandExecuted =  String.format('Command={0} ', new List<String>{command});
  		
  		if (SGUID <> null && SGUID.length() > 0) {
  			commandExecuted += String.format('SGUID={0} ', new List<String>{SGUID});
  		}

  		if (AccountNumber <> null && AccountNumber.length() > 0) {
  			commandExecuted += String.format('AccountNumber={0} ', new List<String>{AccountNumber});
  		}
  		
  		if (BorrowerPosition <> null && BorrowerPosition.length() > 0) {
  			commandExecuted += String.format('BorrowerPosition={0} ', new List<String>{BorrowerPosition});
  		}
  		
  		if (ManagementEmail <> null && ManagementEmail.length() > 0) {
  			commandExecuted += String.format('ManagementEmail={0} ', new List<String>{ManagementEmail});
  		}
  		
  		  		if (BorrowerPosition <> null && BorrowerPosition.length() > 0) {
  			commandExecuted += String.format('userid={0} ', new List<String>{userid});
  		}  		
  	}
	
	private void setReply(WebLoginWebServiceReply reply) {
		resultCode = reply.resultCode;
		resultMessage = reply.message;
	}

}