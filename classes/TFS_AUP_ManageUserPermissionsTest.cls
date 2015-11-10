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
// TODO: REMOVE SEE ALL DATA  
// NO NEVER DO THIS FOR REAL...ONLY FOR POC TO SIMULATE A USER.
@isTest(SeeAllData=true)
public class TFS_AUP_ManageUserPermissionsTest {
	
	/**
	 * Test method to validate manage user permissions classs
	 */
	public static testMethod void testManageUserPermissions()
	{
	 
	 	User usr = TFS_TestUtility.getUserByProfile('Collections Base');
	 	
	 	System.runAs( usr ) {
	 		
	 		TFS_AUP_ManageUserPermissions.getApplicablePermissions();
	 		
	 		// System.debug('query = '+ query ); 
	 		/*
	 		List<String> listPermsNames = TFS_AUP_ManageUserPermissions.getUserApplicableUserPermissions();
	 		System.assertNotEquals(Null, listPermsNames );
	 		System.assertEquals(0, listPermsNames.size() );
	 		
	 		// List perms
	 		for (String perms : listPermsNames ) {
	 			
	 			System.debug('Custom Setting Name = ' + perms );
	 		}
	 		*/
	 	}
	}
	
	/**
	 * Test method to validate utility methods.
	 * TODO: Move this method to its own test class
	 */
	 /*
	static testMethod void testUtilityMethods()
	{
		// Assuming there will always be a system admin profile
		User adminUser = TFS_TestUtility.getSystemAdminUser();
		
		if( adminUser == Null ) {
			adminUser = TFS_TestUtility.makeuser();	
			User u = TFS_TestUtility.getUserByProfile( TFS_TestUtility.DEFAULT_PROFILE_NAME );
			System.assertEquals(adminUser.Id, u.Id );
		}
		else {
			System.assertNotEquals(Null, adminuser );
		}
		
		User u1 = TFS_TestUtility.makeuser();
		
		User u2 = TFS_TestUtility.getUserByUserName( u1.Username );
		System.assertEquals( u1.Id, u2.Id );
		
		User u3 = TFS_TestUtility.getUserByName( u2.Name );
		System.assertEquals( u2.Id, u3.Id );
		
		System.assertNotEquals(Null, TFS_TestUtility.getTimeStamp() );
		
		System.runas(adminUser) {
			u1 = TFS_TestUtility.getUserByRole('Test123');
			System.assertNotEquals(Null, u1);
			u2 = TFS_TestUtility.getUserByRole('Test123');
			System.assertEquals( u1.Id, u2.Id );
		}
				
		Profile p = TFS_TestUtility.getUserProfile( TFS_TestUtility.DEFAULT_PROFILE_NAME );
		System.assertNotEquals(Null, p );
		
		p = TFS_TestUtility.getDefaultProfile();
		System.assertNotEquals(Null, p );

		p = TFS_TestUtility.getAdminProfile();
		System.assertNotEquals(Null, p );
	}
	*/
}