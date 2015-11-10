public abstract class KmSearchModel {
	
	public Map<String, Set<String>> buildKavApiNameFieldsMap(List<String> kavApiNames) {
		
		Map<String, Set<String>> result = new Map<String, Set<String>>();
		for(String kavApiName : kavApiNames) {
			Schema.SObjectType sObjectType = KmArticleTypeModel.knowledgeArticleVersionsMap.get(kavApiName);
			Set<String> fieldSet = KmArticleTypeModel.discoverAccessibleRichTextFields(sObjectType);
			fieldSet.add('Title');
			fieldSet.add('id');
			fieldSet.add('PublishStatus');
			fieldSet.add('ArticleType');
			fieldSet.add('ArticleNumber');  
			fieldSet.add('KnowledgeArticleId');
			fieldSet.add('VersionNumber');
			fieldSet.add('Language');
			
			result.put(kavApiName, fieldSet);
		}
		 
		return result;
	}
	
	protected List<FindKavResult> processListOfList(List<List<SObject>> result, String searchString) {
		
		List<FindKavResult> findKavResults = new List<FindKavResult>();
		for(List<SObject> kavs : result) {
			if ( kavs.size() > 0) {
				String articleVersionTypeName = KmArticleTypeModel.getArticleVersionType(kavs[0]);
				System.Debug('Found '+searchString +' in knowledge Article Type : ' + articleVersionTypeName);
				for(SObject kav : kavs) {
					System.Debug('     Knowledge Article : '+kav.get('Title')+' : '+ kav.get('id'));	
					
					FindKavResult kavResult = new FindKavResult(kav, searchString, articleVersionTypeName);
					findKavResults.add(kavResult);
				} 
			}
		}
		return findKavResults;
	}
	
	public class FindKavResult {
		public String Title;
		public Id KavId;
		public String PublishStatus;
		public String ArticleType;
		public String ArticleNumber;
		public String KnowledgeArticleId;
		public Integer VersionNumber;
		public String Language;
		public String SearchKeyword;
		public String articleVersionTypeName;
		
		public FindKavResult(SObject sobj, String searchString, String articleVersionTypeName) {
			Title = (String)sobj.get('Title');
			KavId = (Id)sobj.get('Id');
			PublishStatus = (String)sobj.get('PublishStatus');
			ArticleType = (String)sobj.get('ArticleType');
			ArticleNumber = (String)sobj.get('ArticleNumber');
			KnowledgeArticleId = (String)sobj.get('KnowledgeArticleId');
			VersionNumber = (Integer)sobj.get('VersionNumber');
			Language = (String)sobj.get('Language');
			SearchKeyword = searchString;
			this.articleVersionTypeName = articleVersionTypeName;
		}
		
	}
}