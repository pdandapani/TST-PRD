@isTest(SeeAllData=true)
private class RL_ConsoleMessengerControllerTest {
	
	
	static testmethod void testInitializingPushTopic() {
		
		User testUser = TFSC_TestUtils.generateTestUser(RL_Constants.RL_AGENT_PROFILE_NAME, true);
		
		PageReference pageRef = Page.RL_ConsoleMessenger;
        RL_ConsoleMessengerController controller = new RL_ConsoleMessengerController();
        Test.setCurrentPage(pageRef);
        
        String messageText = 'test message';
        
        System.runAs(testUser) {
        	//this will cause a caught error where PushTopic doesn't exist for current user.
	        controller.initVars();
	        
	        //this will cover the non-error selection of PushTopic for current user
	        controller.initVars();
	        System_Message__c msg = generateTestMessage(testUser, messageText);
	        
	        controller.selectedMessageId = msg.Id;
	        controller.getMessageText();
        }
        
        System.assert(controller.topicString != null);
        
        System.assertEquals(controller.selectedMessageText, messageText);
	}
	
	private static System_Message__c generateTestMessage(User testUser, String messageText) {
		System_Message__c msgToInsert = new System_Message__c();
		msgToInsert.OwnerId = testUser.Id;
		msgToInsert.Notify_User__c = true ;
		msgToInsert.Source__c = 'SFDC';
		msgToInsert.Title__c = 'Document Generated in LiveCycle';
		msgToInsert.Type__c = 'test';
		msgToInsert.Description__c = messageText;
		insert msgToInsert;
		return msgToInsert;
	}
	
	
	
	
}