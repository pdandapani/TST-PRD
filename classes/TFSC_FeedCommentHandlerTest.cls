@IsTest
public class TFSC_FeedCommentHandlerTest {


    @IsTest
    public static void testFeedCommentHandler(){
        
        FAQ_A__kav testArticle = TFSC_TestUtils.setupAndReturnArticle();
        //User u = createStandardUser();
  
        Test.startTest();
        PermissionSet param = PermissionSetModel.findPermissionSet('Standalone_Knowledge');
        //PermissionSetModel.addPermissionSetToUser(param,UserInfo.getUserId());
        User u = findUserWithPermissionSet(param);
        System.RunAs(u) {
            FeedItem feedbackPost = new FeedItem(ParentId = testArticle.KnowledgeArticleId, Body = 'Test #feedback', Type = 'TextPost');
            insert feedbackPost;
            
            FeedComment comment = new FeedComment();
            comment.FeedItemId = feedbackPost.Id;
            comment.CommentBody = 'Enter your comment here';
             
            insert comment;
        }
        
        Test.stopTest();  
        
        
        List<Case> testCases = [
            SELECT ID 
            FROM Case 
            Where Subject = 'Article Feedback: Test Article'
        ];
        
        System.AssertNotEquals(null,testCases);
    }
        

    public static User findUserWithPermissionSet(PermissionSet permission ) {
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        List<PermissionSetAssignment> psaList = [
            select AssigneeId
            from PermissionSetAssignment
            where PermissionSetId = :permission.id
        ];
                
        if ( psaList.size() > 0) {
            User u = [
                select id,name
                from User 
                where id = :psaList[0].AssigneeId AND IsActive = True
            ];
            return u; 
        } else {
            return null;
        }
        
    }
    
    
    /*
        User u = new User(Alias = 'utstandt', Email='unitTestStandardUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='utStandarduser@testorg.com');
        insert u;
    */   
}