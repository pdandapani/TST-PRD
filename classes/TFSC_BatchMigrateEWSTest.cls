@IsTest
public class TFSC_BatchMigrateEWSTest {
	@IsTest
	public static void test () {
		Account acct = new Account(name = 'testAcct1');
        insert acct;
        
		Financial_Account__c financialAccount2 = new Financial_Account__c(Name = '123', Financial_Account_Number__c = '123');
        insert financialAccount2;
        generateAndInsertFAC(financialAccount2.Id, '0', 'Open', acct.Id, TFSC_TestUtils.generateRandomString(4));
        generateAndInsertFAC(financialAccount2.Id, '6', 'Open', acct.Id, TFSC_TestUtils.generateRandomString(4));
		
		EWS_User__c ewsUser = new EWS_User__c();
		ewsUser.SGUID__c = 'abc';
		ewsUser.User_Id__c = 'test';
		ewsUser.AcctMgmtEmail__c = 'test@test.com';
		insert ewsUser;
		
		List<EWS_Account__c> accountsToAdd = new List<EWS_Account__c>();
		EWS_Account__c ewsAccount = new EWS_Account__c();
		
		accountsToAdd.add(new EWS_Account__c(EWS_User__c=ewsUser.Id, FA_Num__c='123', FA_Role__c='0'));
		accountsToAdd.add(new EWS_Account__c(EWS_User__c=ewsUser.Id, FA_Num__c='123', FA_Role__c='6'));
		insert accountsToAdd;
		
		TFSC_BatchMigrateEWS batchClass = new TFSC_BatchMigrateEWS('122', 100);
		batchClass.execute(null, accountsToAdd);
	} 
	
	private static Financial_Account_Customer__c generateAndInsertFAC(Id FAId, String borrowerPosition, String openOrClosed, Id AcctId, String randString) {
        Financial_Account_Customer__c fac = new Financial_Account_Customer__c();
        fac.Borrower_Position__c = borrowerPosition;
        fac.Financial_Account__c = FAId;
        fac.Account__c = acctId;
        fac.Home_Phone_Garage__c = '4063775090';
        fac.Mobile_Phone__c = '4063775091';
        fac.Work_Phone_Garage__c = '4063775092';
        fac.Borrower_Status__c = 'Active';
        fac.Customer_Role_Type__c = borrowerPosition;
        fac.FA_Role_Status__c = 'test';
        fac.Financial_Account_Customer__c = 'test' + randString;
        //fac.Finance_Account_Status__c = openOrClosed;
        insert fac;
        
        return fac;
    }
	
	
}