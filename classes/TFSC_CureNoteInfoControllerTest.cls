@isTest
private class TFSC_CureNoteInfoControllerTest {
    
    
    static testmethod void testController() {
    	
    	String cureString = TFSC_CureNoteInfoController.cureNoticeSent ;
    	
    	Account acct = TFSC_TestUtils.setupAndReturnNewAccount();
    	Financial_Account__c fa = TFSC_TestUtils.setupAndReturnNewFinancialAccount(acct, '199d7vf');
    	Task tsk = new Task(ActivityDate = Date.today(),
							 Collection_Activity_Code__c = 'CURE',
							 Description = cureString + ' $123.12 test expires 121215 ',
							 Financial_Account_Number__c = '1234',
							 Financial_Account__c = fa.Id,
							 Priority = 'Normal',
							 Source_System_Created_By__c = 'SFDC',
							 Status = 'Completed',
							 Subject = 'TEST' + ' - Test',
							 WhatId = fa.Id
							);
		insert tsk;
		
    	
    	test.startTest();
			ApexPages.StandardController standardController = new ApexPages.StandardController(fa);
			TFSC_CureNoteInfoController controllerExt = new TFSC_CureNoteInfoController(standardController);
    		
    		String cureAmnt = controllerExt.getCureAmount();
    		String cureExpDate = controllerExt.getCureExpDate();
    		String cureNote = controllerExt.getCureNote();
    		Date tempDt = Date.newInstance(2015, 12, 12);
            String controllerDate = tempDt.format();
            
            system.assertEquals(cureExpDate, controllerDate);
            system.assertEquals('$123.12', cureAmnt);
    		
    		
    	test.stopTest();
    	
    	
    }
    
    

}