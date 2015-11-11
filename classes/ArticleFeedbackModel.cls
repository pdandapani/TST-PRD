public class  ArticleFeedbackModel {
	
	//return map of knowledgeArticleId, kavDetails
	public static Map<Id, kavDetails> FindKnowledgeArticleDetails(List<id> knowledgeArticleIds)  {	
		//0 retrieve the articleNumber for each knowledgeArticleId
		List<KnowledgeArticle> kaList = [
			Select Id, ArticleNumber
			from KnowledgeArticle
			where id in :knowledgeArticleIds
		];
		
		//1 sort the knowledgeArticleIds by article Type
		Map<String, List<String>> mapOfKaNumber = new Map<String, List<String>>();
		for(KnowledgeArticle ka : kaList) {
			String kaType = getArticleType(ka.Id);
			if ( !mapOfKaNumber.ContainsKey(kaType)) {
				mapOfKaNumber.put(kaType, new List<String>());
			}
			mapOfKaNumber.get(kaType).add(ka.ArticleNumber);
		}
		
		System.Debug('');
		for(String kaType : mapOfKaNumber.KeySet()) {
			System.Debug('found article found KaType :' + kaType);
		}
		System.Debug('');
		
		
		//2 for each article type - query and convert
		Map<Id, kavDetails> allKnowledgeArticleMap = new Map<Id, kavDetails>();
		for(String kaType : mapOfKaNumber.keySet()) {
			List<kavDetails> kaTypeDetails = getKaTypeDetails(kaType, mapOfKaNumber.get(kaType));
			
			for(kavDetails kaTypeDetail :  kaTypeDetails) {
				allKnowledgeArticleMap.put(kaTypeDetail.knowledgeArticleId, kaTypeDetail);
			}
		}
		
		return allKnowledgeArticleMap;
	}
	
	
	public static List<kavDetails> getKaTypeDetails(String kaApiName, List<String> knowledgeArticleNumberList) {
			
		String kavApiName = kaApiName + 'v';
		String soql = 'select Id, ArticleType, ArticleNumber, Title, UrlName, VersionNumber, KnowledgeArticleId ' + 
			'from '+kavApiName+' ' + 
			'where ArticleNumber in :knowledgeArticleNumberList ' +
			'and PublishStatus = \'Online\' and Language = \'en_US\'';
		
		
        System.Debug(soql);
        		
		List<SObject> kavList = database.query(soql);
		List<kavDetails> result = new List<kavDetails>();
		for ( SObject obj : kavList) {
			result.add(new kavDetails(obj) );
		}
		
		return result;
	}
    

    //Util method to get Article Type from article Id.
    public static String getArticleType(String articleId) {
        String articlePrefix = articleId.substring(0,3);
        Set<String> keySet = describeMap.keySet();
        String articleType = null;
        for(String key: keySet) {
            if(articlePrefix.equalsIgnoreCase(key)) {
                articleType = describeMap.get(key);
                return articleType;
            }
        }
        return articleType;
    }  

	private static map<String,String> pDescribeMap = null;
	public static map<String,String> describeMap {
		get {
			if (pDescribeMap == null) {
				pDescribeMap = new map<String,String>();
				Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		        Set<String> keySet = gd.keySet();
		        for (String key : keySet) {
		            Schema.SObjectType objectType = gd.get(key);
		            if (key.endsWith('ka') || key.endsWith('kb')) {
		                pDescribeMap.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getName());
		            }
		        }				
			}
			return pDescribeMap;
		}
	}
	
	
	public class kavDetails {
		public Id knowledgeArticleVersionId;
		public String articleType;
		public String articleNumber;
		public String articleTitle;
		public String articleVersionUrl;
		public Id knowledgeArticleId;
		public Decimal versionNumber;
		
		public kavDetails(SObject obj) {
			knowledgeArticleVersionId = (Id)obj.get('Id');
			articleType = (String)obj.get('ArticleType');
			articleNumber = (String)obj.get('ArticleNumber');
			articleTitle = (String)obj.get('Title');
			articleVersionUrl = (String)obj.get('UrlName');
			knowledgeArticleId = (Id)obj.get('knowledgeArticleId');
			versionNumber = (Decimal)obj.get('versionNumber');
		}
	}
}