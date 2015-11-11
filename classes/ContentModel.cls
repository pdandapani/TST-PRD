public class ContentModel {
	//ContentModel.moveContentToLibrary('069S0000000CT62','KnowledgeArticles');
	public static void moveContentToLibrary(Id contentVersionId, String libraryName) {

		//1. find the library aka ContentWorkspace
		List<ContentWorkspace> libraries = [
			select id, name
			from ContentWorkspace
			where Name = :libraryName
		];  
		
		if (libraries.size() <> 1) {
			return;
		}
		Id libraryId = libraries[0].Id;
		
		
		//2. find the contentDoc for the contentVersion
		List<ContentVersion> contentVersions = [
			select id, ContentDocumentId
			from ContentVersion
			where id = :contentVersionId
		];
		
		if ( contentVersions.size() <> 1) {
			return;
		}
		Id contentDocumentId = contentVersions[0].ContentDocumentId;
		
		
		//3. find the library doc / junction object - ContentWorkspaceDoc
		List<ContentWorkspaceDoc> cwdList = [
			select id
			from ContentWorkspaceDoc
			where ContentDocumentId = :contentDocumentId
			and ContentWorkspaceId = :libraryId
		];
		
		if (cwdList.size() > 0 ) {
			return;
		}
		
		//4. if not found - create the junction 
		ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
		cwd.ContentDocumentId = contentDocumentId;
		cwd.ContentWorkspaceId = libraryId;
		
		insert cwd;
		
	}

}