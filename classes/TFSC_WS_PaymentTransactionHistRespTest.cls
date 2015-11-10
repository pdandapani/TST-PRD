@isTest
private class TFSC_WS_PaymentTransactionHistRespTest {

    static testMethod void testResponseClasses() {
        
        String testString;
        String[] testStringList;
        
        Test.startTest();
            
            TFSC_WS_PaymentTransactionHistoryResp.ResultBODType bodType;
            bodType = new TFSC_WS_PaymentTransactionHistoryResp.ResultBODType();
            bodType.ResultCode = 1;
            bodType.ResultDesc = '';
            bodType.ResultString = '';
            //testStringList = bodType.ResultCode_type_info;
            //testStringList = bodType.ResultDesc_type_info;
            //testStringList = bodType.field_order_type_info;
            //testStringList = bodType.ResultString_type_info;
            //testStringList = bodType.apex_schema_type_info;
            
            
            TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResBODType resBodType;
            resBodType = new TFSC_WS_PaymentTransactionHistoryResp.PaymentTransactionHistoryResBODType();
            //testStringList = resBodType.field_order_type_info;
            //testStringList = resBodType.apex_schema_type_info;
            //testStringList = resBodType.ListOfTransactions_type_info;
            
            
            TFSC_WS_PaymentTransactionHistoryResp.TransactionType transType;
            transType = new TFSC_WS_PaymentTransactionHistoryResp.TransactionType();
            transType.AccountNumber = '';
            transType.AccoutId = '';
            transType.Bank = '';
            transType.CustomerNumber = '';
            transType.EffectiveDate = '';
            transType.Id = '';
            transType.InterestAmount = 0;
            transType.LateCharge = 0;
            transType.LeaseBranchNumber = '';
            transType.LoanBalanceAmount = 0;
            transType.MiscellaneousPaymentAmount = 0;
            transType.PaymentAmount = 0;
            transType.PaymentDescription = '';
            transType.PaymentTypeCode = '';
            transType.PrincipleAmount = 0;
            transType.ProcessedDate = '';
            transType.RegionNumber = '';
            transType.RetailBranchNumber = '';
            transType.TransactionAmount = 0;
            transType.TransactionDescription = '';
            transType.TransactionType = '';
            transType.Type_x = '';
            /*
            testStringList = transType.AccountNumber_type_info ;
            testStringList = transType.AccoutId_type_info ;
            testStringList = transType.Bank_type_info ;
            testStringList = transType.CustomerNumber_type_info ;
            testStringList = transType.EffectiveDate_type_info ;
            testStringList = transType.Id_type_info ;
            testStringList = transType.InterestAmount_type_info ;
            testStringList = transType.LateCharge_type_info ;
            testStringList = transType.LeaseBranchNumber_type_info ;
            testStringList = transType.LoanBalanceAmount_type_info ;
            testStringList = transType.MiscellaneousPaymentAmount_type_info ;
            testStringList = transType.PaymentAmount_type_info ;
            testStringList = transType.PaymentDescription_type_info ;
            testStringList = transType.PaymentTypeCode_type_info ;
            testStringList = transType.PrincipleAmount_type_info ;
            testStringList = transType.ProcessedDate_type_info ;
            testStringList = transType.RegionNumber_type_info ;
            testStringList = transType.RetailBranchNumber_type_info ;
            testStringList = transType.TransactionAmount_type_info ;
            testStringList = transType.TransactionDescription_type_info ;
            testStringList = transType.TransactionType_type_info ;
            testStringList = transType.Type_x_type_info ;
            testStringList = transType.apex_schema_type_info ;
            testStringList = transType.field_order_type_info ;
            */
            
            TFSC_WS_PaymentTransactionHistoryResp.ListOfTransactionsType listTransType;
            listTransType = new TFSC_WS_PaymentTransactionHistoryResp.ListOfTransactionsType();
            /*
            testStringList = listTransType.Transaction_x_type_info;
            testStringList = listTransType.apex_schema_type_info;
            testStringList = listTransType.field_order_type_info;
            */
            
            TFSC_WS_PaymentTransactionHistoryResp.ProcessService_element processElem;
            processElem = new TFSC_WS_PaymentTransactionHistoryResp.ProcessService_element();
            /*
            testStringList = processElem.ResultBOD_type_info ;
            testStringList = processElem.PaymentTransactionHistoryResBOD_type_info ;
            testStringList = processElem.apex_schema_type_info ;
            testStringList = processElem.field_order_type_info ;
            */
            
        Test.stopTest();
    }
}