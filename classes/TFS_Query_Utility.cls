public with sharing class TFS_Query_Utility {
	public static final String SOQL_SELECT = ' SELECT ';
	public static final String SOQL_WHERE = ' WHERE ';
	public static final String SOQL_FROM = ' FROM ';
	public static final String SOQL_AND = ' AND ';
	public static final String SOQL_OR = ' OR ';
	public static final String SOQL_IN = ' IN ';
	public static final String SOQL_INCLUDES = ' INCLUDES ';
	public static final String SOQL_LIMIT = ' LIMIT ';
	public static final String SOQL_ID = 'ID';

	/**
	 * Method that takes a list of sObject and returns a set of 
	 * IDs that corresponds to each object in list.
	 */
	public static Set<ID> extractIDSet( List<sObject> listObjects )
	{
		Set<ID> listIDs = new Set<ID>();
		
		for( String strId : extractFieldValuesSet( listObjects, 'ID') )
			listIDs.add( (ID) strID );
			
		return listIDs;
	}

	/**
	 * Method that takes a list of sObject and returns a set of 
	 * IDs that corresponds to each object in list.
	 */
	public static Set<String> extractStringSet( List<sObject> listObjects )
	{
		
		return extractFieldValuesSet( listObjects, SOQL_ID );
	}
	
	/**
	 * Method prepares a list of field values from an sObject as a Set.
	 */
	public static Set<String> extractFieldValuesSet( List<sObject> listObjects, 
													 String fieldName )
	{	
		String values = Null;
		String fieldValue = Null;
		Set<String> setFieldValues = new Set<String>();
		
		for( sObject obj : listObjects ) {
			// Get requested field value
			fieldValue = (String) obj.get( fieldName );
			if( fieldValue != Null && fieldValue != '' )
				setFieldValues.add( fieldValue );
		}
		return setFieldValues;
	}
	
	/**
	 * Method to compose a string with all fields name of a given object.
	 */
	public static String getObjectFields( String objectName )
	{
		Schema.SobjectType sObjectType = Null;
		Schema.DescribeSObjectResult sObjectDescribe = Null;
		Map<String, Schema.SObjectField> fields = Null;
		String csvFieldNames = '';
		
    	if( StringUtil.isNotNull( objectName ) ) { 
    		
	        // Set<String> fieldNames = new Set<String>();
	        sObjectType =  mapGlobalDescribe.get( objectName.toLowerCase() );
			sObjectDescribe = sObjectType.getDescribe();
  			fields = sObjectDescribe.Fields.getMap();
	    	
	        String expr = '';
	        for(String fieldName : fields.keySet() ){
	            expr += fieldName + ', ';
	        }
	       csvFieldNames = expr.substring(0, expr.lastIndexOf(','));
    	}
    	return csvFieldNames;
	}	
	 
	/**
	 * Method to compose a select query with a where clause filtering for object id with all 
	 * fields of an object in the select clause. 
	 * Note: This method does not execute a query.
	 */
	public static String composeSelectQuery( String objectName, 
											 String idField, 
											 String id )
	{
		String fieldNames = getObjectFields( objectName );
		
		return composeSelectQuery( objectName, fieldNames, idField, id );
	}	 

	/**
	 * Method to compose a partial select query without a where clause for an object 
	 * Note: This method does not execute a query.
	 */	 	 
	public static String composeSelectQuery( String objectName, 
											 		 String fieldNames) 

	{
		String query = '';

		// TODO: Throw exception when query parameters are not valid	
		if( StringUtil.isNotNull( fieldNames ) )
        	// query = 'Select ' + fieldNames ;
        	query = SOQL_SELECT + fieldNames ;
        
        if( StringUtil.isNotNull( objectName ) ) 
        	// query = query + ' From ' + objectName;
        	query = query + getFromClause(objectName);

		return query;
	}
	
	/**
	 * Method to compose a select query with a where clause filtering for object id with given 
	 * fields of an object in the select clause. 
	 * Note: This method does not execute a query.
	 */	 	 
	public static String composeSelectQueryIncludes( String objectName, 
											 		 String fieldNames, 
											 		 String filterField,
											 		 Set<String> values )
	{
		String query = '';

		// TODO: Throw exception when query parameters are not valid	
		if( StringUtil.isNotNull( fieldNames ) )
        	// query = 'Select ' + fieldNames ;
        	query = SOQL_SELECT + fieldNames ;
        
        if( StringUtil.isNotNull( objectName ) ) 
        	// query = query + ' From ' + objectName;
        	query = query + getFromClause(objectName);
		
        if( values != Null && values.size() > 0 )
        	query = query + getWhereClause( SOQL_INCLUDES, filterField, values );
		
		return query;
	}

	/**
	 * Method to compose a select query with a where clause filtering for object id with given 
	 * fields of an object in the select clause. 
	 * Note: This method does not execute a query.
	 */	 	 
	public static String composeSelectQueryIn( String objectName, 
											 		 String fieldNames, 
											 		 String filterField,
											 		 Set<String> values )
	{
		String query = '';

		// TODO: Throw exception when query parameters are not valid	
		if( StringUtil.isNotNull( fieldNames ) )
        	// query = 'Select ' + fieldNames ;
        	query = SOQL_SELECT + fieldNames ;
        
        if( StringUtil.isNotNull( objectName ) ) 
        	// query = query + ' From ' + objectName;
        	query = query + getFromClause(objectName);
		
        if( values != Null && values.size() > 0 )
        	query = query + getWhereClause( SOQL_IN, filterField, values );
		
		return query;
	}

	/**
	 * Method to compose a select query with a where clause filtering for object id with given 
	 * fields of an object in the select clause. 
	 * Note: This method does not execute a query.
	 */	 	 
	public static String composeSelectQuery( String objectName, 
											 String fieldNames, 
											 String idField, 
											 String id )
	{
		String query = '';

		// TODO: Throw exception when query parameters are not valid	
		if( StringUtil.isNotNull( fieldNames ) )
        	// query = 'Select ' + fieldNames ;
        	query = SOQL_SELECT + fieldNames ;
        	
        if( StringUtil.isNotNull( objectName ) ) 
        	// query = query + ' From ' + objectName;
        	query = query + getFromClause(objectName);
        	
        if( StringUtil.isNotNull( idField ) && 
        	StringUtil.isNotNull( id ) )
        	 // query = query + ' Where ' + idField + '=\'' + id + '\'';
        	 // query = query + SOQL_WHERE + idField + '=\'' + id + '\'';
        	 query = query + getWhereClause(idField, id);
        	 
		// TODO: Clean up
		// System.Debug('Debug: Query:' + query);       	 
		// System.Debug('Debug: idField:' + idField);       	 
		// System.Debug('Debug: id:' + id);    
		   	 
		return query;
	}
	
	/**
	 * Method to compose a select query with a where clause filtering for list of values with In calause 
	 * selecting all fields of an object in the select clause. 
	 * Note: This method does not execute a query.
	 */
	public static String composeSelectQuery( String objectName, 
											 String fieldName,
											 Set<String> values )
											 
	{
		String query = '';
		
		// TODO: Throw exception when query parameters are not valid	
		if( StringUtil.isNotNull( objectName ) )
        	// query = 'Select ' + fieldNames ;
        	query = SOQL_SELECT + getObjectFields( objectName ); 
        	
        if( StringUtil.isNotNull( objectName ) ) 
        	// query = query + ' From ' + objectName;
        	query = query + getFromClause(objectName);
        	
        if( values != Null && values.size() > 0 )
        	query = query + getWhereClause( fieldName, values );
		
		return query;
	}	 
	
	
	/**
	 * Method to get limit clause. 
	 */
	public static String getLimitClause( Integer limitSize )
	{
		String limitStr = '';
		
		if( limitSize > 0 )
			limitStr = SOQL_LIMIT + limitSize;
		
		return limitStr;
	} 	 

	/**
	 * Method to get where clause 
	 */	 	 
	public static String getWhereClause( String idField, String idValue )
	{
		return SOQL_WHERE + idField + '=\'' + idValue + '\'';
	}	 
	
	/**
	 * Method to get where clause 
	 */	 	 
	public static String getWhereClause( String relatedFieldName, Set<String> relatedIDs )
	{
        // String relatedFieldValues = StringUtil.enquoteValueForInClause(relatedIDs);
		
        // return SOQL_WHERE + relatedFieldName + SOQL_IN + relatedFieldValues;
        return getWhereClause( SOQL_IN, relatedFieldName, relatedIds );
	}	 
	
	/**
	 * Method to get where clause 
	 */	 	 
	public static String getWhereClause( String operator, String relatedFieldName, Set<String> relatedIDs )
	{
        String relatedFieldValues = StringUtil.enquoteValueForInClause(relatedIDs);
		
        return SOQL_WHERE + relatedFieldName + operator + relatedFieldValues;
	}	 

	/**
	 * Method to get in clause 
	 */	 	 
	public static String getInClause( String relatedFieldName, Set<String> values )
	{
        String relatedFieldValues = StringUtil.enquoteValueForInClause(values);
		
        return getFilterClause( SOQL_IN, relatedFieldName, values );
	}	 

	/**
	 * Method to get includes clause 
	 */	 	 
	public static String getIncludesClause( String relatedFieldName, Set<String> values )
	{
        String relatedFieldValues = StringUtil.enquoteValueForInClause(values);
		
        return getFilterClause( SOQL_INCLUDES, relatedFieldName, values );
	}	 

	/**
	 * Method to get filter clause 
	 */	 	 
	public static String getFilterClause( String operator, String relatedFieldName, Set<String> values )
	{
        String relatedFieldValues = StringUtil.enquoteValueForInClause(values);
		
        return relatedFieldName + operator + relatedFieldValues;
	}	 

	/**
	 * Method to get filter clause 
	 */	 	 
	public static String getFilterClause( String relatedFieldName, String value )
	{
        String relatedFieldValue = StringUtil.escapeAndEnquote(value);
		
        return relatedFieldName + '=' + relatedFieldValue;
	}	 

	/**
	 * Method to get from clause 
	 */	 	 
	public static String getFromClause( String objectName )
	{
		return SOQL_FROM + objectName;
	}	 
	
	/**
	 *
	 */
  	public static Map<String, Schema.SObjectType> mapGlobalDescribe { 
  		
  		get { 
  			if(mapGlobalDescribe == Null) 
  				mapGlobalDescribe = Schema.getGlobalDescribe();
  				
  			return mapGlobalDescribe;
  		}
  		set;
  	}
}