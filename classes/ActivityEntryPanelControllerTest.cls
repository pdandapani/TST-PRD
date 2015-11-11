@isTest
private class ActivityEntryPanelControllerTest {

	@isTest static void test_method_one() {
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
        
        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);        
		faRetail.Financial_Account_Number__c = '7419510107';
        update faRetail;

        ActivityEntryPanelController controller = new ActivityEntryPanelController();
        controller.financialAccount = faRetail;
        List<SelectOption> aList = new List<SelectOption>();
        aList.add(new SelectOption('1', '1'));

        ActivityEntryPanelController.NoteTabWrapper wrapper = new ActivityEntryPanelController.NoteTabWrapper('None', '');
        wrapper.activityList = aList;
        controller.noteTab1Wrapper = wrapper;
        controller.firstNoteActivitiesWhereClause = 'Id != null';
        controller.saveNote1();

        System.assert(controller.pageHasErrorMessages);

        Activity_Code__c ac = new Activity_Code__c(Name='1');
        insert ac;

        wrapper.selectedActivityCode = '1';
        controller.noteTab1Wrapper = wrapper;
        controller.saveNote1();

        System.assert(controller.pageHasErrorMessages);

        Activity_Code__c ac2 = new Activity_Code__c(Name='2');
        insert ac2;

        wrapper.note = 'testing';
        controller.noteTab1Wrapper = wrapper;
        controller.saveNote1();

        System.assert(!controller.pageHasErrorMessages);

        controller.errorStringUsedForErrorMessageSetting = 'TEST';
        controller.setPageErrorMsg();

        System.assert(controller.pageHasErrorMessages);
    }
}