public with sharing class StringUtil {

    /**
     * Method to enquote a string
     * Input: John's 
     * Output: 'John's'
     */
    public static String enquote( String value )
    {
        if( value != null )
            return '\'' + value + '\'';
        
        return '';
    }    
    
    /**
     * Method that escapes all single quotes in a string and enquote escaped string
     * Input: John's 
     * Output: 'John\'s'
     */
    public static String escapeAndEnquote( String value )
    {
        // String newValue = String.escapeSingleQuotes(  escapeBackSlash( value ) );
        String newValue = String.escapeSingleQuotes( value );
        
        if( newValue != null && newValue.length() > 0 )
            return enquote( newValue );
        
        return '';
    }
    
    /**
     * Method that takes a list of strings and returns an escaped coma delimited string.
     * Input: [0]=John's, [1]=Smith 
     * Output: 'John\'s,Smith'
     * Note: Useful to prepare contains clause when filtering by multi select picklist
     */
    public static String escapeAndEnquote( String[] values )
    {
        String comaDelimitedString = '';

        for( String value : values ){
    
            if( comaDelimitedString != '' )
                comaDelimitedString = comaDelimitedString + ',';
            
            comaDelimitedString = comaDelimitedString + escapeAndEnquote( value );
        }
        return comaDelimitedString;
    }
     
    /** 
     * Method that takes a list of strings and a delimiter then returns a string seperated by delimiter
     * Input1: [0]=John's, [1]=Smith 
     * Input2: ;
     * Output: 'John\'s;Smith'
     * Note: Useful when constructing user selection from a multi-select checkbox.
     */
    public static String tokenizedString( String[] values, String delimiter )
    {
        String concatString = '';
        
        if( delimiter == '' )
            delimiter = ';';
            
        for( String value : values ) {
        
            if( concatString != '' )
                concatString = concatString + delimiter;
                
            concatString = concatString + value;    
        }   
        return  concatString;
    }   
    
    /**
     * Method that takes a string and returns left most n characters
     * Input1: Testing
     * Input2: 4
     * Output: Test
     * Note: Method returns empty string when main string is null or less than length
     */
    public static String left( String mainString, Integer length )
    {
        String subString = '';
        Integer mainStrLen = 0;
        Integer subStrLen = 0;
        
        if( mainString != null ) {
            mainStrLen = mainString.length();
        
            subStrLen = ( mainStrLen > length ) ? length : mainStrLen;
            
            subString = mainString.substring( 0, subStrLen);  // MD 3/10/10: changed subStrLen-1 to just subStrLen
        }   
        
        return subString;
    }  
    
    /** 
     * Method to escape null into a empty string 
     * Useful when concatinating strings 
     */
	public static String escapeNull( Decimal  argDecimal )
	{
		return ( argDecimal == Null ) ? '' : argDecimal.format(); 
	}

    /** 
     * Method to escape null into a empty string 
     * Useful when concatinating strings 
     */
	public static String escapeNull( String argStr )
	{
		return ( argStr == Null ) ? '' : argStr; 
	}

	/**
	 * Method to check if a given string is not null or empty 
	 */
	public static Boolean isNotNull( String value )
	{
		if( value != Null && value != '')
			return True;
			
		return False;
	}
	 
	/**
	 * Method to check if a given string is null or empty 
	 */
	public static Boolean IsNull( String value )
	{
		return ! IsNotNull( value );
	}	 
	
	/**
	 * 
	 */
	public static String enquoteFieldValues(Set<String> listValues)
	{
		String values = '';
		
		for( String value : listValues ) {
			/*
			// escape and pad to values if not null
			if( IsNotNull(values) ) {
				// append a ',' when reentering loop
				values += ',';
				values += escapeAndEnquote( value );
			}
			*/
			if( isNotNull(value) ) {
				values = values + escapeAndEnquote( value ) + ',';
			}
		}
	    return values.substring(0, values.lastIndexOf(','));
		// return values;
	}

	public static String enquoteFieldValues(Set<ID> listValues)
	{
		String values = '';
		String strValue = '';
		
		for( ID value : listValues ) {
			/*
			// escape and pad to values if not null
			if( IsNotNull(values) ) {
				// append a ',' when reentering loop
				values += ',';
				values += escapeAndEnquote( value );
			}
			*/
			strValue = (String) value;
			
			if( isNotNull(strValue) ) {
				values = values + escapeAndEnquote( strValue ) + ',';
			}
		}
	    return values.substring(0, values.lastIndexOf(','));
		// return values;
	}
	
	/**
	 * Method prepares a list of ID values formatted to be used in an IN 
	 * clause of a SOQL	query.
	 * This method that takes a list of sobjects and returns a string with its
	 * Id values enquoted within parenthesis. 
	 */
	public static String enquoteValueForInClause( Set<String> listValues )
	{	
		String values = enquoteFieldValues(listValues);
		// Begin and end values with parenthesis
		return '(' + values + ')';
	}

	/**
	 * Method prepares a list of ID values formatted to be used in an IN 
	 * clause of a SOQL	query.
	 * This method that takes a list of sobjects and returns a string with its
	 * Id values enquoted within parenthesis. 
	 */
	public static String enquoteIDForInClause( Set<ID> listValues )
	{	
		String values = enquoteFieldValues(listValues);
		// Begin and end values with parenthesis
		return '(' + values + ')';
	}
	
	/**
	 * Method prepares a list of ID values formatted to be used in an IN 
	 * clause of a SOQL	query.
	 * This method that takes a list of sobjects and returns a string with its
	 * Id values enquoted within parenthesis. 
	public static String enquoteIDForInClause( List<sObject> listObjects )
	{	
		return enquoteFieldValues( listObjects, 'ID' );
	}
	 */

	/**
	 * Method prepares a list of values formatted to be used in an IN 
	 * clause of a SOQL	query. This emthod takes sObject field name that 
	 * needs to be enquoted. Method also takes a list of sobjects and returns 
	 * a string with value of given field enquoted within parenthesis. 
	public static String enquoteFieldValues( List<sObject> listObjects, String fieldName )
	{	
		String values = Null;
		String fieldValue = Null;
		for( sObject obj : listObjects ) {
			
			// Get requested field value
			fieldValue = (String) obj.get( fieldName );
			
			// escape and pad to values if not null
			if( isNotNull( fieldValue ) && 
				IsNotNull( values) ) {
				// append a ',' when reentering loop
				values += ',';
				values += escapeAndEnquote( fieldValue );
			}
			else {
				values = escapeAndEnquote( fieldValue );
			}				
		}
		// Begin and end values with parenthesis
		return '(' + values + ')';
	}
	 */
	
	/**
	 * Method to construct a schedule time format string based on system timestamp.
	 * This method takes a parameter that indicates time deilay to be applied
	 * in the prepared schedule time string
	 * 
	 * Note: This method is exclusivelly designed to create a schedule time string
	 * to start a task after n minutes. Where n indicates the number of minutes.
	 */	
	public static String getScheduleTimeExpression( Integer delayMinutes )
	{
		// public static String CRON_EXP = '0 0 0 3 9 ? 2022'
		// Seconds  Minutes  Hours  Day_of_month  Month  Day_of_week  optional_year
		DateTime dtTm = System.now().addMinutes( delayMinutes );
		
		// dtTM.addMinutes( delayMinutes );
		String expression = '0 ' + dtTm.minute() + ' ' + dtTm.hour() + ' ' +  dtTm.day() + ' ' + dtTm.month() + ' ? ' + dtTm.year();
		// String expression = '0 ' + dtTm.minute() + ' ' + dtTm.hour() + ' ' +  dtTm.day() + ' ' + dtTm.month() + ' ? ';

		// TODO: Clean up
		// Logger.info('Scheduler Expression : ' + expression );
		
		return expression;
	}

	/** 
	 * Method that returns a one wya hash for a given stirng.
	 */	
	public static String getMD5Hash(String text)
	{
		Blob targetBlob = Blob.valueOf(text);
		Blob hash = Crypto.generateDigest('MD5', targetBlob);
		
		return EncodingUtil.base64Encode(hash);
	}

	/**
	 * Method to translate a string into API name
	 * A quick and dirty way of converting a text value into a string that is API name compliant
	 * Basically replace any special character including space into '_' character 
	 */
	public static String getAPIName(String text)
	{
		String apiName='';
		
		if( text != Null )
			apiName = text.trim().replaceAll('[^a-zA-Z0-9]','_');
			
		return apiName;
	}
	 
	/* left-pad a string with a pattern (one or more chars) till the result is the specified length */
	public static String padLeft( String stringToPad, String padPattern, Integer finalLength ) 
	{
	
		Integer inputLength = stringToPad.length();
		if( inputLength >= finalLength ) { return stringToPad; }
		String newString = stringToPad; // we'll copy it, don't want to risk altering the original
		while( newString.length() < finalLength ) {
			newString = padPattern + newString; // tack the pattern onto the left
		}
		Integer startPos = newString.length() - finalLength;
		return newString.substring( startPos );
	}
	
	/* right-pad a string with a pattern (one or more chars) till the result is the specified length */
	public static String padRight( String stringToPad, String padPattern, Integer finalLength ) 
	{
	
		Integer inputLength = stringToPad.length();
		if( inputLength >= finalLength ) { return stringToPad; }
		String newString = stringToPad; // we'll copy it, don't want to risk altering the original
		while( newString.length() < finalLength ) {
			newString = newString + padPattern; // tack the pattern onto the right
		}
		return newString.substring( 0, finalLength );
	}
	
	/**
	 * Test methods
	 */   
	 /* 
    public static testmethod void testStringUtilities()
	{
		// Quick and dirty testing.
		System.assertEquals( '\'test\'', StringUtil.enquote('test') );
		System.assertEquals( '\'John\\\'s\'', StringUtil.escapeAndEnquote('John\'s') );
		System.assertEquals( 'test', StringUtil.left('testing', 4) );
		
		String [] lstStr = new String[]{'One','Two','Three'};
		System.assertEquals( '\'One\',\'Two\',\'Three\'', StringUtil.escapeAndEnquote( lstStr ) );
		System.assertEquals( 'One;Two;Three', StringUtil.tokenizedString( lstStr, ';' ) );
		
		System.assertEquals( False, IsNull('test') );
		System.assertEquals( True, IsNull('') );
		System.assertEquals( False, IsNotNull('') );
		System.assertEquals( True, IsNotNull('test') );
	
		System.assertEquals( getScheduleTimeExpression( 5 ), getScheduleTimeExpression( 5 ) );
		System.assertNotEquals( getScheduleTimeExpression( 15 ), getScheduleTimeExpression( 5 ) );
		
		Decimal d = null;
		String test = null;
		System.assertEquals('',StringUtil.escapeNull(d));
		System.assertEquals('test', StringUtil.escapeNull('test'));
		System.assertEquals('', StringUtil.escapeNull(test));
		
		
		
		Account a1 = new Account(Name='test1');
		Account a2 = new Account(Name='test2');
		List<Account> listAccounts = new List<Account>{ a1, a2 };
		insert listAccounts;
		
		String expected = '(' + escapeAndEnquote( a1.Id ) + ',' + escapeAndEnquote( a2.Id ) + ')';
		String altExpected = '(' + escapeAndEnquote( a2.Id ) + ',' + escapeAndEnquote( a1.Id ) + ')';
		Set<String> ids = new Set<String>{a1.Id, a2.Id};
		Set<ID> accountIds = new Set<Id>{a1.Id, a2.Id};
		if(expected.equals(enquoteIDForInClause( ids )) || altExpected.equals(enquoteIDForInClause( ids )))
			System.assert(true);
		else
			System.assert(false);
		//System.assertEquals(escapeAndEnquote( a1.Id ) + ',' + escapeAndEnquote( a2.Id ) , StringUtil.enquoteFieldValues(accountIds));
		if(expected.equals(enquoteIDForInClause( accountIds )) || altExpected.equals(enquoteIDForInClause( accountIds )))
			System.assert(true);
		else
			System.assert(false);
		//System.assertEquals( expected, enquoteIDForInClause( accountIds ) );
	}
	*/
}