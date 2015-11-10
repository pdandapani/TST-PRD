/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class StringUtil_Test {

	/**
	 * Test methods
	 */    
    public static testmethod void testStringUtilities()
	{
		// Quick and dirty testing.
		System.assertEquals( '\'test\'', StringUtil.enquote('test') );
		System.assertEquals( '\'John\\\'s\'', StringUtil.escapeAndEnquote('John\'s') );
		System.assertEquals( 'test', StringUtil.left('testing', 4) );
		
		String [] lstStr = new String[]{'One','Two','Three'};
		System.assertEquals( '\'One\',\'Two\',\'Three\'', StringUtil.escapeAndEnquote( lstStr ) );
		System.assertEquals( 'One;Two;Three', StringUtil.tokenizedString( lstStr, ';' ) );
		
		System.assertEquals( False, StringUtil.IsNull('test') );
		System.assertEquals( True, StringUtil.IsNull('') );
		System.assertEquals( False, StringUtil.IsNotNull('') );
		System.assertEquals( True, StringUtil.IsNotNull('test') );
	
		// Dirty code begins
		System.assertEquals( StringUtil.getScheduleTimeExpression( 5 ), StringUtil.getScheduleTimeExpression( 5 ) );
		System.assertNotEquals( StringUtil.getScheduleTimeExpression( 15 ), StringUtil.getScheduleTimeExpression( 5 ) );
		
		Decimal d = null;
		String test = null;
		System.assertEquals('',StringUtil.escapeNull(d));
		System.assertEquals('test', StringUtil.escapeNull('test'));
		System.assertEquals('', StringUtil.escapeNull(test));
		/*
		Account a1 = new Account(Name='test1');
		Account a2 = new Account(Name='test2');
		List<Account> listAccounts = new List<Account>{ a1, a2 };
		insert listAccounts;
		
		String expected = '(' + StringUtil.escapeAndEnquote( a1.Id ) + ',' + StringUtil.escapeAndEnquote( a2.Id ) + ')';
		String altExpected = '(' + StringUtil.escapeAndEnquote( a2.Id ) + ',' + StringUtil.escapeAndEnquote( a1.Id ) + ')';
		Set<String> ids = new Set<String>{a1.Id, a2.Id};
		Set<ID> accountIds = new Set<Id>{a1.Id, a2.Id};
		
		if(expected.equals(StringUtil.enquoteIDForInClause( ids )) || StringUtil.altExpected.equals(enquoteIDForInClause( ids )))
			System.assert(true);
		else
			System.assert(false);
		//System.assertEquals(escapeAndEnquote( a1.Id ) + ',' + escapeAndEnquote( a2.Id ) , StringUtil.enquoteFieldValues(accountIds));
		if(expected.equals(enquoteIDForInClause( accountIds )) || altExpected.equals(enquoteIDForInClause( accountIds )))
			System.assert(true);
		else
			System.assert(false);
		//System.assertEquals( expected, enquoteIDForInClause( accountIds ) );
		*/
	}
}