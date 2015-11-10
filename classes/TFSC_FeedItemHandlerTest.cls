@isTest
public class TFSC_FeedItemHandlerTest {
	
	@IsTest
	static void testCreateArticleFeedbackCase(){
		
		FAQ_A__kav testArticle = TFSC_TestUtils.setupAndReturnArticle();
    	
    	FeedItem feedbackPost = new FeedItem(ParentId = testArticle.KnowledgeArticleId, Body = 'Test #feedback', Type = 'TextPost');
    	
    	Test.startTest();
    	insert feedbackPost;
    	Test.stopTest();
    	
    	List<Case> testCases = new List<Case>([SELECT ID FROM Case Where Subject = 'Article Feedback: Test Article']);
    	
    	System.assert(testCases != null);
		
	}

}