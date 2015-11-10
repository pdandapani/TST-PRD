@isTest
public class TFSC_SupportAttachLegacyControllerTest {
    @isTest
    private static void TestAddAttachment() {
        TFSC_TestUtility testUtil = new TFSC_TestUtility();
        System.runAs(testUtil.testAdmin) {
	        TFSC_SupportAttachmentLegacyController controller = new TFSC_SupportAttachmentLegacyController(
	            new ApexPages.StandardController(testUtil.Cases[0])
	        );
	        
	        controller.NewFeedItem.ContentData = blob.valueOf('Test');
	        controller.NewFeedItem.ContentFileName = 'TestAttachment.txt';
	        
	        System.AssertNotEquals(null, controller.InsertAttachment());
	        
	        TFSC_SupportRequestController srCon = new TFSC_SupportRequestController(
	            new ApexPages.StandardController(testUtil.cases[0])
	        );
	        
	        System.AssertNotEquals(null, srCon.AddAttachmentLegacy());
        }
    }
}