@isTest
private class RL_AuctionLocationAddressCtrlTest {
	
	
	static testmethod void testControllerMethods() {
		
		Case caseObj = setupData();
		String parsedString = caseObj.RL_Auction_Agency_Zip__c;
		
		Id auctionAcctId = RL_GenerateTestData.getRecordType('Account', 'Auction');
        Account auctionAcct = new Account(name = 'testAuction', RecordTypeId=auctionAcctId, BillingPostalCode='12345', BillingCity='Fort Collins', BillingState='CO', BillingStreet = '123 Street ST\nABC', phone='123-123-1234', Website='www.wonky.com');
        insert auctionAcct;
		
		PageReference pageRef = Page.RL_AuctionLocationAddressEdit;
        ApexPages.currentPage().getParameters().put('Id', caseObj.Id);
        ApexPages.StandardController standardCtrler = new ApexPages.StandardController(caseObj);
        
        Test.setCurrentPage(pageRef);
        
        RL_AuctionLocationAddressController controller = new RL_AuctionLocationAddressController(standardCtrler);
        
        controller.selectedAuctionAcct = auctionAcct.Id;
        controller.saveNewAuctionLocationAddress();
        
        system.assert(parsedString != controller.contextCase.RL_Auction_Agency_Zip__c);
	}
	
	
	
	
	static private Case setupData() {
		//Setup Data
		Case caseToReturn;
		
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        Id personAccountRT = RL_GenerateTestData.getRecordType('Account', 'Customer');
        List<Account> accList = new Account[]{new Account(FirstName='TEST1', LastName='ACCOUNT1', recordTypeId=personAccountRT), new Account(FirstName='TEST2', LastName='ACCOUNT2', recordTypeId=personAccountRT)};
        insert accList;

        List<Financial_Account_Customer__c> facs = new Financial_Account_Customer__c[] {
            new Financial_Account_Customer__c(Customer_Role_Type__c='0-Primary Borrower', Account__c = accList[0].Id, Borrower_Status__c = 'Active', Name = 'Test FAC1', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071'),
            new Financial_Account_Customer__c(Customer_Role_Type__c='6-Co-Borrower', Account__c = accList[1].Id, Borrower_Status__c = 'Active', Name = 'Test FAC2', Mailing_State_Garage__c = 'IL', Financial_Account__c = faRetail.Id, Garage_Zip_Code_Extn__c='2922', Mailing_Postal_Code_Garage__c='61071')
        };
        insert facs;
        
        Collateral__c collateral = new Collateral__c(Name='Test Collateral', Vehicle_Identification_Number__c='12345');
        insert collateral;
        
        faRetail.Collateral__c = collateral.Id;
        update faRetail;

        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        caseToReturn = RL_GenerateTestData.createCase(faRetail, caseRTId);  
        caseToReturn.Form_Rule__c = formRuleMap.get('4015MD').Id;
        caseToReturn.RL_System_Required_Notice_Date_Time__c = DateTime.now();
        caseToReturn.RL_Auction_Agency_Zip__c = 'xyz';
        update caseToReturn;
        
        Repossession__c repo = RL_GenerateTestData.createRepossessionMD(caseToReturn, faRetail);  
        
        Third_Party__c tp = new Third_Party__c(Repossession__c = repo.Id);
        insert tp;
        
        return caseToReturn;
	}
	
}