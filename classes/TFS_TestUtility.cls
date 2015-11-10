public with sharing class TFS_TestUtility {

	public static final String STANDARD_USER_PROFILE = 'Standard User';
	public static final String ADMIN_USER_PROFILE = 'System Administrator';
	public static final String DEFAULT_PROFILE_NAME = 'System Administrator';
    public static final String DEFAULT_USER_ROLE='Support';

	public static User getAdminUser()
	{
		return getUserByProfile( ADMIN_USER_PROFILE );
	}

	public static User getUserByProfile( String profileName ){
		User usr = Null;
		
		try{
			usr = [ Select 
						Name 
					From 
						User 
					Where 
						Profile.Name = :profileName And 
						UserRoleId != Null And
						IsActive=TRUE 
					Order By
						LastModifiedDate Desc
					LIMIT 1
					];
			// TODO: Clean up					
			System.debug('In try: User Name :' + usr.Name); 
		}
		catch(Exception e){
			// Suppress exception
			System.debug( 'Exception: ' + e.getMessage() );
			/*
			usr.LastName = profileName + ' User';
			Profile prf = [ Select Id from Profile where Name = :profileName ];
			usr.ProfileId = prf.Id;
			usr.IsActive = false;
			insert usr;
			*/
		}
		return usr;
	}
	
	public static UserRole getUserRole( String roleName )
	{
		UserRole ur = Null;
		
		try {
			
			ur = [ Select Id, Name From UserRole Where Name = :roleName LIMIT 1];
			
		}catch(Exception e){
			// Suppress exception
			System.debug( 'Exception: ' + e.getMessage() );
		}
		if( ur == Null ) {
			ur = createUserRole( roleName );
		}
		return ur;
	}
	
	
	public static UserRole createUserRole( String roleName )
	{
		UserRole ur = new UserRole( Name=roleName );
		Insert ur;
		// UserRole ur2 = [ Select Id, Name From UserRole Where Name = :ur.Name];
		// System.assertEqual( ur.Id, ur2.Id );
		
		return ur;			
	}
	
	public static Profile getUserProfile( String profileName )
	{
		Profile up = Null;
		
		try {
			
			up = [ Select Id, Name From Profile Where Name = :profileName LIMIT 1];
			
		}catch(Exception e){
			// Suppress exception
			System.debug( 'Exception: ' + e.getMessage() );
		}
		return up;
	}
	
	public static Profile getDefaultProfile()
	{
		return getUserProfile( DEFAULT_PROFILE_NAME );
	}
	
	public static Profile getAdminProfile()
	{
		return getUserProfile( ADMIN_USER_PROFILE );
	}
	
	public static UserRole geDefaultUserRole()
	{
		return getUserRole( DEFAULT_USER_ROLE );
	}
	
	public static User getUserByRole( String roleName )
	{
		User usr = Null;
		
		try{
			usr = [ Select 
						Id, Name 
					From 
						User 
					Where 
						UserRole.Name = :roleName AND
						IsActive = True 
					Order By
						LastModifiedDate Desc
					LIMIT 1
					];
		}
		catch(Exception e){
			// Suppress exception
			System.debug('Exception caught: ' + e.getMessage() );
		}
					
		if( usr == Null ) {
			UserRole ur = getUserRole( roleName );
			usr = makeUser();
			usr.UserRoleId = ur.id;
			
			Update usr;
		}
		// TODO: Clean up					
		System.debug('In try: User Name :' + usr.Name); 
		return usr;
	}


	public static User getUserByUserName( String userName )
	{
		User usr = Null;
		try{
			usr = [ Select 
						Id, Name, username 
					From 
						User 
					Where 
						username = :userName 
					LIMIT 1 
					];
			// TODO: Clean up					
			System.debug('In try: User Name :' + usr.Name); 
			
			
		}
		catch(Exception e){
			// Suppress exception
			System.debug('Exception caught: ' + e.getMessage() );
		}
		return usr;
	}

	public static User getUserByUserId( String userId )
	{
		User usr = Null;
		try{
			usr = [ Select 
						Id, Name, username 
					From 
						User 
					Where 
						Id = :userId 
					LIMIT 1 
					];
			// TODO: Clean up					
			System.debug('In try: User Name :' + usr.Name); 
		}
		catch(Exception e){
			// Suppress exception
			System.debug('Exception caught: ' + e.getMessage() );
		}
		return usr;
	}

	public static User getUserByName( String name ){
		User usr = Null;
		try{
			usr = [ Select 
						Id, Name, username 
					From 
						User 
					Where 
						Name = :name 
					LIMIT 1 
					];
			// TODO: Clean up					
			System.debug('In try: User Name :' + usr.Name); 
		}
		catch(Exception e){
			// Suppress exception
			System.debug('Exception caught: ' + e.getMessage() );
		}
		return usr;
	}
	
	public static User getSystemAdminUser()
	{
		User usr = getUserByProfile( ADMIN_USER_PROFILE );
		
		if( usr == Null )
			usr = makeUser();
		
		return usr;
	}		

	public static User getAlikeUser( User usr )
	{
		User newUser = Null;
		User existingUser = Null;
		Profile p = Null;
		UserRole ur = Null;
		 
		if( usr != Null ) {
			// Select user agagin so that we get profile and role
			try {
				existingUser = [ Select 
										Id, Name, Profile.Name, UserRole.Name 
									  From 
									  	User 
									  Where 
									  	Id = :usr.Id LIMIT 1
									  ];
			}catch( Exception e ) {
				// Exception suppressed
				System.debug('Exception : ' + e.getMessage() );
			}
		}

	
		if( existingUser != Null ) {
			
			try {
				newUser = [ Select 
									Id, Name, Profile.Name, UserRole.Name 
							  From 
									  	User 
							  Where 
									  	Id != :existingUser.Id AND
									  	Profile.Name = :existingUser.Profile.Name AND
									  	UserRole.Name = :existingUser.UserRole.Name AND
									  	IsActive = True
									  	Order by LastModifiedDate Desc
									  	LIMIT 1
									  ];
			}catch( Exception e ) {
				// Exception suppressed
				System.debug('Exception : ' + e.getMessage() );
			}
		}
		
		if( newUser == Null && 
			existingUser != Null) {
			
			p = getUserProfile( existingUser.Profile.Name );
			ur = getUserRole( existingUser.UserRole.Name );
			newUser = makeUser( p, ur );
		}		
		return newUser;
	} 	

	public static User makeUser(Profile p, UserRole ur)
	{
		User usr = Null;

		usr = makeUser();
		usr.ProfileId = p.Id;
		usr.UserRoleId = ur.Id;
		
		Update usr;
				
		return usr;
	}	
		
    public static User makeUser() {
    	return makeUser('test' + Math.random());
    }
    
    public static User makeUser(String communityNickname) {
        
        Profile p = getAdminProfile();
        
        String name = communityNickname + '@salesforce.com';

        User u = new User(
            alias = communityNickname.substring(0, 8), //Hopefully this is unique
            email=name,
            emailencodingkey='UTF-8',
            firstname='Ftesting',
            lastname='Ltesting',
            languagelocalekey='en_US',
            localesidkey='en_US',
            profileid = p.id,
            timezonesidkey='America/Los_Angeles',
            username=name,
            communityNickname = communityNickname,
            UserPermissionsSFContentUser = false,
            UserPermissionsMarketingUser = True
        );
        
        insert u;
        
        return u;
    }

	
	/**
	 * Method that returns a system time as a string.
	 */
	public static String getTimeStamp()
	{
		return String.valueOf( DateTime.now().getTime() );
	}
	 	
	/**
	 * Test method to validate utility methods.
	static testMethod void testUtilityMethods()
	{
		// Assuming there will always be a system admin profile
		User adminUser = getSystemAdminUser();
		
		if( adminUser == Null ) {
			adminUser = makeuser();	
			User u = getUserByProfile( DEFAULT_PROFILE_NAME );
			System.assertEquals(adminUser.Id, u.Id );
		}
		else {
			System.assertNotEquals(Null, adminuser );
		}
		
		User u1 = makeuser();
		
		User u2 = getUserByUserName( u1.Username );
		System.assertEquals( u1.Id, u2.Id );
		
		User u3 = getUserByName( u2.Name );
		System.assertEquals( u2.Id, u3.Id );
		
		System.assertNotEquals(Null, getTimeStamp() );
		
		System.runas(adminUser) {
			u1 = getUserByRole('Test123');
			System.assertNotEquals(Null, u1);
			u2 = getUserByRole('Test123');
			System.assertEquals( u1.Id, u2.Id );
		}
				
		Profile p = getUserProfile( DEFAULT_PROFILE_NAME );
		System.assertNotEquals(Null, p );
		
		p = getDefaultProfile();
		System.assertNotEquals(Null, p );

		p = getAdminProfile();
		System.assertNotEquals(Null, p );
				
	}
	 */
}