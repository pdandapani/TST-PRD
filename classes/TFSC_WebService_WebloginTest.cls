@IsTest
public class TFSC_WebService_WebloginTest {


	@IsTest
	public static void UnitTest() {
		TFSC_Weblogin_ProvisionTest.createData(true);
		TFSC_WebService_WebLogin.WebLoginParam param = createData();
		
		TFSC_WebService_WebLogin.post('1','Provision',param);
		TFSC_WebService_WebLogin.post('2','Registration',param);
		TFSC_WebService_WebLogin.post('3','Unregistration',param);
		TFSC_WebService_WebLogin.post('4','Deprovision',param);
		TFSC_WebService_WebLogin.post('5','Change',param);
		TFSC_WebService_WebLogin.post('6','Unread',param);
		TFSC_WebService_WebLogin.post('7','Error',param);
	}
	
	
	public static TFSC_WebService_WebLogin.WebLoginParam createData() {
		TFSC_WebService_WebLogin.WebLoginParam param = new TFSC_WebService_WebLogin.WebLoginParam();
		param.SGUID =  TFSC_Weblogin_ProvisionTest.SGUID1;
		param.FinancialAccountNumber = TFSC_Weblogin_ProvisionTest.FaNum1;
		param.managementEmail = TFSC_Weblogin_ProvisionTest.email1;
		param.userName = TFSC_Weblogin_ProvisionTest.userId1;
		param.FirstName = 'FirstName';
		param.LastName = 'LastName';
		
		return param;
	}

}