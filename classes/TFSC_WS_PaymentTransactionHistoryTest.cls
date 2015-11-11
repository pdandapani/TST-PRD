/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
public class TFSC_WS_PaymentTransactionHistoryTest {

	@IsTest
	public static void testPaymentTransactionHistory() {

	    String AccountNumber = '010272DZ690';
        String AccountType = 'L';
        String Branch = ''; 
        String Region = '';	
 
		//TFSC_WS_PaymentTransactionHistoryResSync.ProcessService_element response = 
		//	TFSC_WS_PaymentTransactionHistory.getPaymentTxHistory(AccountNumber, AccountType, Branch, Region);
        
        TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_RequestParams request = 
            new TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_RequestParams();
        request.AccountNumber = '010272DZ690';
        request.AccountType = 'L';
        request.Branch = '';
        request.Region = '';
        request.NoOfRecords = 30;
            
        TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_ResponseParams response;
        response = TFSC_WS_GetPaymentTransactionHistory.getPaymentTransactionHistory(request);
        
		
		System.assertNotEquals(null, response);	
	}
}