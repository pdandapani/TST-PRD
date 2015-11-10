public class KmSoslSearchModel extends KmSearchModel {
	
	//SOSL can search multiple knowledge article types and multiple fields quickly
	//but does not retrieve HTML tag to match the keyword - need to use SOQL to complete the search

	//KmSoslSearchModel.SearchArticles('*TFS/LFS*');
	public List<FindKavResult> SearchArticles(String searchString) {
		List<String> kavApiNames = KmArticleTypeModel.activeKavApiNames;	
		Map<String, Set<String>> articleTypeNameFieldsMap = buildKavApiNameFieldsMap(kavApiNames);
		
		List<List<SObject>> result = SearchArticles(articleTypeNameFieldsMap,  searchString);	
		List<FindKavResult> findKavResults =processListOfList(result, searchString);
	
		return findKavResults;
	}

	private  List<List<SObject>> SearchArticles(Map<String, Set<String>> articleTypeNameFieldsMap,  String searchString) {
		
		String SOSL_search_string = 'FIND \''+searchString +'\' IN ALL FIELDS RETURNING ';
		
		for(String articleTypeApi : articleTypeNameFieldsMap.KeySet()) {
		
			String articleTypeToken = articleTypeApi+'(';
			for(String articleField : articleTypeNameFieldsMap.get(articleTypeApi)) {
				articleTypeToken += articleField + ', ';
			}
			articleTypeToken = articleTypeToken.removeEnd(', ');
			articleTypeToken += ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' ), ';  
			
			SOSL_search_string += articleTypeToken;
		}
		SOSL_search_string = SOSL_search_string.removeEnd(', ');
		System.debug('SOSL_search_string : '+ SOSL_search_string);
		
		List<List <sObject>> myQueryResult = search.query(SOSL_search_string);
		return myQueryResult;
	
	}
	

}