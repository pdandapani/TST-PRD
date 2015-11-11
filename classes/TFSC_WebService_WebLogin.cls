/**
* @author: Salesforce Services
* @date:    2014-08-06
* @description: REST based webservice end point for 
* 1. Provision  -- create PersonAccount of RecType weblogin
* 2. Registration -- add the Weblogin-PersonAccount's contact id to FAC to give visibility
* 3. Unregistration -- remove the Weblogin-PersonAccount's contact id from FAC
* 4. Deprovision -- deactivate and return community user license to pool
* 5. Change             ( Email or User Name)
* 6. UnreadCount -- new case or case comment since last login
*
*
* A single end point will be used to allow for JMS queue to deliver multiple messages in sequence
*               
* @log:
* -----------------------------------------------------------------------------
*    Developer                    Date                Description
* -----------------------------------------------------------------------------
*    Benjamin Lau	              2014-08-12          creation
*   
*/

@RestResource(urlMapping='/TFSC_WebService_WebLogin/v1/*')
global  class TFSC_WebService_WebLogin {

	@httpPost
	global Static WebLoginWebServiceReply post (string requestNum, string requestType, WebLoginParam param) {
		
		WebLoginWebServiceReply result = null;
		
		if (requestType == 'Provision') {
			System.Debug('*** Provision : '+requestNum +' ; '+ requestType +' ; '+ param.SGUID +' ; '+
				param.FinancialAccountNumber +' ; '+ param.FinancialAccountBorrowerNumber + ' ; '+ param.FirstName + ' ; '+ param.LastName+ ' ; '+ param.CompanyName);
			result = (new TFSC_Weblogin_Provision()).execute(param.SGUID, param.FinancialAccountNumber, param.FinancialAccountBorrowerNumber, 
				param.managementEmail, param.userName, param.FirstName, param.LastName, param.CompanyName);
			
		} else  if (requestType == 'Registration') { 
			System.Debug('*** Registration : '+requestNum +' ; '+ requestType +' ; '+ param.SGUID +' ; '+
				param.FinancialAccountNumber +' ; '+ param.FinancialAccountBorrowerNumber);  
			result = (new TFSC_Weblogin_Register()).execute(param.SGUID, param.FinancialAccountNumber, param.FinancialAccountBorrowerNumber);
			
		} else if (requestType == 'Unregistration') {
			System.Debug('*** Unregistration : '+requestNum +' ; '+ requestType +' ; '+ param.SGUID +' ; '+
				param.FinancialAccountNumber );
			result = (new TFSC_Weblogin_Unregister()).execute(param.SGUID, param.FinancialAccountNumber);
			 
		} else if (requestType == 'Deprovision') {
			System.Debug('*** Unregistration : '+requestNum +' ; '+ requestType +' ; '+ param.SGUID);
			result=(new TFSC_Weblogin_Unprovision()).execute( param.SGUID); 
			
		} else if (requestType == 'Change') {
			System.Debug('*** Change : '+requestNum +' ; '+ requestType +' ; '+ param.SGUID +' ; '+
				param.managementEmail +' ; '+ param.userName + ' ; '+ param.FirstName + ' ; '+ param.LastName+ ' ; '+ param.CompanyName);
			result=(new TFSC_Weblogin_ProfileUpdate()).execute(param.SGUID, param.managementEmail, param.userName, param.FirstName, param.LastName, param.CompanyName);
			
		} else if (requestType == 'Unread') {
			System.Debug('*** Unread : '+requestNum +' ; '+ requestType +' ; '+ param.SGUID);
			result = (new TFSC_Weblogin_UnreadMsgCount()).execute(param.SGUID);
			 
		} else{    
			System.Debug('*** Abort - unrecognize RequestType');
		}
		  
		return result;    
	}
	
	/////////////////////////////////////  inner classes for JSON data structure //////////////////////////////////////

	global class WebLoginParam {
		public String SGUID;
		public String FinancialAccountNumber;
		public String FinancialAccountBorrowerNumber;
		public String managementEmail;
		public String userName;
		public String FirstName;
		public String LastName;
		public String CompanyName;
	}
	


	/*
	public class ProvisionReq {
		public String SGUID;
		public String FinancialAccountNumber;
		public String FinancialAccountBorrowerNumber;
		managementEmail;
		userName;
	}   
	
	public class RegistrationReq {
		public String SGUID;
		public String FinancialAccountNumber;
		public String FinancialAccountBorrowerNumber;
	}
	
	public class UnregistrationReq {
		public String SGUID;
		public String FinancialAccountNumber;
	}
	
	global class ChangeReq {
		global String SGUID;
		global String managementEmail;
		global String userName;
	}
	
	global class UnreadReq {
		global String SGUID;
	}
	*/

}