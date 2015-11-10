@isTest
private class TFSC_WS_GetPaymentTransactionHistoryTest {
    
    
    
    public static testMethod void testForGettersSettersCodeCoverage() {
		
		Test.startTest();
		TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_ResponseRecord resp = new TFSC_WS_GetPaymentTransactionHistory.PaymentTransactionHistory_ResponseRecord();
		resp.AccountNumber = '';
		resp.AccoutId = '';
		resp.Bank = '';
		resp.CustomerNumber = '';
		resp.EffectiveDate = '';
		resp.Id = '';
		resp.InterestAmount = 0;
		resp.LateCharge = 0;
		resp.LeaseBranchNumber = '';
		resp.LoanBalanceAmount = 0;
		resp.MiscellaneousPaymentAmount = 0;
		resp.PaymentAmount = 0;
		resp.PaymentTypeCode = '';
		resp.PaymentDescription = '';
		resp.PrincipleAmount = 0;
		resp.ProcessedDate = '';
		resp.RegionNumber = '';
		resp.RetailBranchNumber = '';
		resp.TransactionAmount = 1;
		resp.Type_x = '';
		resp.TransactionType = '';
		resp.TransactionDescription = '';
		
		TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResSync_element elem = new TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResSync_element();
		//TFSC_WS_GetPaymentTransactionHistory.parseResponse(elem);
		
		Test.stopTest();
	}
    
}