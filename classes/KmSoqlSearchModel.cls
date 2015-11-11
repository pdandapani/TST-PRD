public class KmSoqlSearchModel extends KmSearchModel {

	//(new KmSoqlSearchModel()).SearchArticles('TFS/LFS');    <--- do not use * will mess up the string.contains function
	public List<FindKavResult> SearchArticles(String searchString) {
		System.Debug('KmSoqlSearchModel::SearchArticles looking for '+ searchString);
		List<String> kavApiNames = KmArticleTypeModel.activeKavApiNames;	
		Map<String, Set<String>> articleTypeNameFieldsMap = buildKavApiNameFieldsMap(kavApiNames);
		
		List<List<SObject>> result = SearchArticles(articleTypeNameFieldsMap, searchString);
		List<FindKavResult> findKavResults = processListOfList(result, searchString);
		
		System.Debug('Found '+ findKavResults.size() +' matches.');
		
		return findKavResults;
	}

	private List<List<SObject>> SearchArticles(Map<String, Set<String>> articleTypeNameFieldsMap,  String searchString) {

		// first search for published articles with keyword
		List<List<SObject>> result = SearchArticlesByStatus('Online', articleTypeNameFieldsMap, searchString);
	
		// now repeat the same search for draft article
		result.AddAll(SearchArticlesByStatus('Draft', articleTypeNameFieldsMap, searchString));
		
		return result;
	}
	
	private List<List<SObject>> SearchArticlesByStatus(
		String status, Map<String, Set<String>> articleTypeNameFieldsMap,  String searchString) {
	
		List<List<SObject>> result = new List<List<SObject>>();
		
		for(String kavApiName : articleTypeNameFieldsMap.KeySet()) {
		
			String SOQL_query = 'select ';
			for(String field : articleTypeNameFieldsMap.get(kavApiName)) {
				SOQL_query += field + ', ';
			}
			SOQL_query = SOQL_query.removeEnd(', ');
			SOQL_query += ' from '+kavApiName;
			SOQL_query += ' WHERE PublishStatus = \'' +status+ '\' AND Language = \'en_US\' ';
			
			
			List<SObject> onlineKavs = Database.query(SOQL_query);
			System.Debug(SOQL_query + '\r\n' + 'Found '+onlineKavs.size()+' records');
			
			List<SObject> kavResult = new List<SObject>();
			for (SObject record : onlineKavs ) {
				boolean hasMatch = false;
				Set<String> kavFields = articleTypeNameFieldsMap.get(kavApiName);
				for(String field : kavFields) {
					
					if ( field.endsWith('__c')) {
						String richTextField = (String)record.get(field);
						
						if ( richTextField <> null && richTextField.contains(searchString)) {
							//System.Debug('found match in rich text field : '+ field);
							hasMatch = true;
						} 
					} 
				}
				if ( hasMatch) {
					kavResult.add(record);
				}
			}
			System.Debug('SearchArticles - looking for ('+searchString+') returning '+kavResult.size()+' records for kav = '+ kavApiName);
			
			result.add(kavResult);
		} 
		return result;
		
	}

}