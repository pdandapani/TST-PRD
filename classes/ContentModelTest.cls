@IsTest
public class ContentModelTest {

	@IsTest
	public static void unitTest() {		
		
		id contentId = CreateData();
		
		ContentModel.moveContentToLibrary(contentId,'DoesNotExists');
		ContentModel.moveContentToLibrary(contentId,'KnowledgeArticles');
	}
	
	public static id createData(){
		
		ContentVersion c = new ContentVersion();
		c.Title = 'testContent';
		c.ContentUrl = 'http://www.google.com';
		insert c;
		
		return c.id;
	}

}