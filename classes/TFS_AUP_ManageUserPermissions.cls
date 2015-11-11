/**
 Test code to validate if custom setings could be dynamically loaded 
 Intent of this code is to drive the functionality of assigning relevant permission sets to users 
 after provisioning via. JIT. This code is to figurre out if custom settings could be used to configure 
 and lookup permission sets available to a user based on certain properties supplied during JIT.  
*/
global class TFS_AUP_ManageUserPermissions {

    static public final String AUP_META_DATA_PREFIX = 'tfs_aup_';
    static public final String APU_APP_ACCESS_OBJECT = 'TFS_AUP_Application_Access__c';
    static public final String APU_APP_PERMSSIONS_OBJECT = 'TFS_AUP_Application_Permission__c';
    static public final String APU_APP_NAME_FIELD = 'Application_Name__c';
    
    
    static public String userFunction { set; get; }
    static public String userProfile { set; get; }
    static public String userRole { set; get; }
    static public String userId { set; get; }
    
    public TFS_AUP_ManageUserPermissions()
    {
        userFunction = 'Collection';
        userRole = 'Agent';
        userProfile = 'Collection Base';
    }

	/**
	 * Method invocable from flow (login flow) that passes running (login) user. 
	 * This method retrieves permission set and group configured and assigns permission sets and groups
	 * Note: It is important that there is no persion set or group setup for this user that conflicts with integrity of these system objects
	 * Clean up user permissions from permission set and group membership by calling clearUserPermissions(User usr) method before calling this method   
	 */
    @InvocableMethod 
    public static void setupUserPermissions(List<User> listUsers)
    {   
        User currentUser = Null;
        if( listUsers != NUll && 
            listUsers.size() > 0 )
            currentUser = listUsers.get(0);
            
        // Process only if user found and change permisison flag set.
        // Note: This flag will be marked once user gets provisioned via. JIT.
        // Checkign againg as a safety net.
        if(currentUser != Null && 
            currentUser.AUP_Change_Permissions__c == True ) {
            	
            // Clear any permission assigned to this user
            clearUserPermissions(currentUser);

            // Get permission sets configured
            List<PermissionSetAssignment> listUserPerms = getUserPermissionSets(currentUser);

            if( listUserPerms != Null && 
            	listUserPerms.size() > 0 ) {
	            // Delete any existing permission sets
	            // Debug
	            System.debug('listUserPerms.size() = ' + listUserPerms.size() );
	            
	            // Setup new permission sets
	            insert listUserPerms;
            }
            else {
	            // Debug
	            System.debug('No Permission Sets Setup for this user');
            }
            	            
            // Query list of group membership configured
            List<GroupMember> listUserGroupPerms = getUserGroupSetup(currentUser);
            if( listUserGroupPerms != Null && 
            	listUserGroupPerms.size() > 0 ) {
            
	            // Debug
	            System.debug('listUserGroupPerms.size() = ' + listUserGroupPerms.size() );
	            
	            insert listUserGroupPerms;
            }
            else {
	            // Debug
	            System.debug('No Groups Setup for this user');
            }
            
        }
    }
    
    /**
     * Method to retrieve permission sets setup for user based on Business Unit and Function values
     */
    public static List<PermissionSetAssignment> getUserPermissionSets(User usr)
    {
        List<PermissionSetAssignment> listPSAssignment = Null;
        // Debug
        System.debug('usrFunction='+usr.AUP_User_Function__c);
        System.debug('usrBusiness='+usr.AUP_Business_Unit__c);
        
        Set<String> permissionSetIds = getPermissionSetIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
        
        
        if( permissionSetIds != Null && 
            permissionSetIds.size() > 0 ) {

	        // Debug
	        System.debug('permissionSetIds.size() = ' + permissionSetIds.size() );

            listPSAssignment = new List<PermissionSetAssignment>();
            
	        for( String psId : permissionSetIds ) {
	        	// Debug
	        	System.debug('UserId='+usr.Id + 'PermId='+psId);
	            listPSAssignment.add( new PermissionSetAssignment(AssigneeId=usr.Id,PermissionSetId=psId) );
	        }
        }
        else {
	        // Debug
	        System.debug('No permission set names configured !');
        }
        return listPSAssignment;
    }
    
    
    /**
     * Method to find matching permission set Ids based on business and function attribute in user record
     */
    public static Set<String> getPermissionSetIds(String usrBusiness, String usrFunction)
    {
        Set<String> setOfPSIds = Null;
        
        // Compose a partial query with where clause
        String query = TFS_Query_Utility.composeSelectQueryIncludes('TFS_AUP_User_Permission__c', 
                                                            'Id, Name, Business_Unit__c, User_Function__c',
                                                            'Business_Unit__c',
                                                            new Set<String>{usrBusiness} );
                                                            
        // append another filter clause to already composed query
        query = query + TFS_Query_Utility.SOQL_AND + TFS_Query_Utility.getIncludesClause('User_Function__c',  
        																				  new Set<String>{usrFunction} );
        
        Set<String> setOfPSNames = executeQueryAndReturnSet( query, 'Name' );
        
        if( setOfPSNames != Null && 
            setOfPSNames.size() > 0 ) {

	        // Debug
	        System.debug('setOfPSNames.size() = '+ setOfPSNames.size() );
        
            query = TFS_Query_Utility.composeSelectQueryIn('PermissionSet', 
                                                         'Id, Name', 
                                                         'Name', 
                                                         setOfPSNames );
                                                             
            setOfPSIds = executeQueryAndReturnSet( query, 'Id' );
            
        }
        else {
	        // Debug
	        System.debug('No permission sets Ids found !');
        }
        return setOfPSIds;
    }
    
    
	/**
	 * Method to retrieve list of group names configured 
	 */    
    public static List<GroupMember> getUserGroupSetup(User usr)
    {
        List<GroupMember> listGMAssignment = Null;
        // Debug
        System.debug('usrFunction='+usr.AUP_User_Function__c);
        System.debug('usrBusiness='+usr.AUP_Business_Unit__c);
        
        Set<String> groupIds = getGroupIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
        
        if( groupIds != Null && 
            groupIds.size() > 0 ) {
            	
	        // Debug
	        System.debug('groupIds.size() = ' + groupIds.size() );
        
            listGMAssignment = new List<GroupMember>();
            
	        for( String ugId : groupIds ) {
	        	// Debug
	        	System.debug('UserId='+usr.Id + 'ugId='+ugId);
	            listGMAssignment.add( new GroupMember(UserOrGroupId=usr.Id,GroupId=ugId) );
	        }
        }
        else {
	        // Debug
	        System.debug('No group names found !');
        }
        return listGMAssignment;
    }
    
    /**
     * Method to find matching permission set Ids based on business and function attribute in user record
     */
    public static Set<String> getGroupIds(String usrBusiness, String usrFunction)
    {
        Set<String> setOfGrpIds = Null;
        
        // Compose a partial query with where clause
        String query = TFS_Query_Utility.composeSelectQueryIncludes('TFS_AUP_User_Group__c', 
                                                            'Id, Name, Business_Unit__c, User_Function__c',
                                                            'Business_Unit__c',
                                                            new Set<String>{usrBusiness} );
                                                            
        // append another filter clause to already composed query
        query = query + TFS_Query_Utility.SOQL_AND + TFS_Query_Utility.getIncludesClause('User_Function__c',  
        																				  new Set<String>{usrFunction} );
        
        Set<String> setOfGrpNames = executeQueryAndReturnSet( query, 'Name' );
        
        if( setOfGrpNames != Null && 
            setOfGrpNames.size() > 0 ) {

	        // Debug
	        System.debug('setOfGrpNames.size() = '+ setOfGrpNames.size() );
        
            query = TFS_Query_Utility.composeSelectQueryIn('Group', 
                                                         'Id, developerName, Name, Type', 
                                                         'developerName', 
                                                         setOfGrpNames );
                                                         
            // Note: Required to filter only for Public Group 
            query = query + 'And Type = \'Regular\'';
                                                             
            setOfGrpIds = executeQueryAndReturnSet( query, 'Id' );
        }
        else {
	        // Debug
	        System.debug('No matching group Id found!');
        }
        return setOfGrpIds;
    }
    
    /**
     * Method to clear any permission set or group membership configured for this user
     * TODO: Need to determine if this method is required or not. Using it for now for recycling user Id.
     */
    public static void clearUserPermissions(User usr)
    {   
    	List<sObject> listOfObjToDelete = new List<sObject>();
        // Debug
        System.debug('usrFunction='+usr.AUP_User_Function__c);
        System.debug('usrBusiness='+usr.AUP_Business_Unit__c);
    	
    	// Pull all applicable permission set Ids.
    	Set<String> setOfPSIds = getPermissionSetIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
    	
    	// Query and delete permission sets assigned for this user
		String query = TFS_Query_Utility.composeSelectQuery('PermissionSetAssignment', 
															'AssigneeId,Id,PermissionSetId',
															'AssigneeId',
															usr.Id );

		List<PermissionSetAssignment> listPSAssigned =  Database.query(query);
		
		listOfObjToDelete.addAll(findMatchingObjects( listPSAssigned, setOfPSIds, 'PermissionSetId') );

    	// Pull all applicable permission set Ids.
    	Set<String> setOfGrpIds = getGroupIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );

    	// Query and delete group membership assigned for this user
		query = TFS_Query_Utility.composeSelectQuery('GroupMember', 
													 'GroupId,Id,UserOrGroupId',
													 'UserOrGroupId',
													 usr.Id );
													 
		List<GroupMember> listGMAssigned = 	Database.query(query);

		listOfObjToDelete.addAll( findMatchingObjects( listGMAssigned, setOfGrpIds, 'GroupId') );
		
		if( listOfObjToDelete.size() > 0 ) {
			// Debug
			System.debug('Object to be deleted = '+ listOfObjToDelete.size() );
			delete listOfObjToDelete;
		}
		else {
			// Debug
			System.debug('No permissions found for delete !');
		}
																					
    }
        
	 
    /**
     * Method runs a query and returns a field from select clause.
     * Note: field name passed should be seleted in select clause
     */
    public static Set<String> executeQueryAndReturnSet(String query, String fieldName )
    {
        Set<String> setOfValues = Null;
        // Debug
        System.debug('Query='+query);
        
        List<sObject> listsObjects = Database.query(query);
         
        // Query permission set Ids only when required
        if( listsObjects != Null && 
            listsObjects.size() > 0) {
            
            setOfValues = TFS_Query_Utility.extractFieldValuesSet( listsObjects, fieldName );
        }
        
        return setOfValues;
    }
    
    /**
     * Method to retrieve list of sobject that find a match in a set of Ids
     */
	public static Set<sObject> findMatchingObjects(List<sObject> listObj, Set<String> setOfIds, String IdField )
	{
		Set<sObject> setOfObjects = new Set<sObject>();
		
		// Return empty set when bad parameters sent
		if( listObj == Null || 
			listObj.size() == 0 || 
			setOfIds == Null || 
			setOfIds.size() == 0 || 
			IdField == Null ||
			idField.trim().length() == 0 ) 
			
				return setOfObjects;

		for( sObject obj : listObj ) {
			
			if( setOfIds.contains( (String) obj.get(IdField)) )
				setOfObjects.add(obj);
				
		}
		return setOfObjects;
	}     
	
    /*
    public static List<PermissionSetAssignment> getApplicablePermissions(String uid)
    {
        userId = uid;
        List<PermissionSetAssignment> listUserPerms = new List<PermissionSetAssignment>();
        List<String> listPermNames = getConfiguredApplicationNames();
        // List<TFS_AUP_Application_Permission__c> appPermsList = getApplicationPermissions( listPermNames );
        getApplicationPermissions( listPermNames );
        
        return listUserPerms;   
    }
    */
    
    /**
     * Method to retrieve list of application permissions that provides all the permission set Ids
    public static String getApplicationPermissions(List<String> permNamesList)
    {

        String query = TFS_Query_Utility.composeSelectQuery( APU_APP_PERMSSIONS_OBJECT, 
                                                             APU_APP_NAME_FIELD, 
                                                             new Set<String>(permNamesList) );
                                                          
        System.debug('Query = ' + query );
        return query;
                    
    }
     */
    
    /**
     * Method returns list of custom objects to be queried for 
    public static List<String> getConfiguredApplicationNames()
    {
        // get meta-data field names using schema describe
        Schema.DescribeSObjectResult[] descResults = Schema.describeSObjects(new String[]{ APU_APP_ACCESS_OBJECT });
        
        // Get application config instance applicable for this profile. 
        // Ideally should be for userId when invoked via. Flow
        // TFS_AUP_Application_Access__c userAccess = TFS_AUP_Application_Access__c.getInstance();
        
        // TODO: Clean up. Forcing a user Id thats passs as parameter for testing.  
        TFS_AUP_Application_Access__c userAccess = TFS_AUP_Application_Access__c.getInstance( userId );
        
        List<String> listUserAccessNames = new List<String>();
        
        // Loop through schema resuls. Need to optimize 
        for(Schema.DescribeSobjectResult res : descResults) {
            
            Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
            
            for(String key : fieldsMap.keySet() ) {

                Schema.SObjectField fld = fieldsMap.get(key);
                
                Schema.DescribeFieldResult dfr = fld.getDescribe();
                
                if( dfr.getName().startsWithIgnoreCase( AUP_META_DATA_PREFIX ) && 
                    userAccess.get(dfr.getName()) == TRUE ) {
                        // Debug
                        System.debug('Application Enabled = ' + dfr.getName() );
                        listUserAccessNames.add( dfr.getName() );
                }
                else {
                
                    // Debug
                    System.debug('Application Not Enabled = ' + dfr.getName() );
                }
                    
                    // Debug
                    System.debug('Label = ' + dfr.getLabel() + ', Name = ' + dfr.getName() + ', Type = '+ dfr.getType()  + ', Value = ' + userAccess.get(dfr.getName()));
             }
        }  
        // Debug 
        System.debug('Size of application name list = ' + listUserAccessNames.size() );
                  
        return listUserAccessNames;
    }
     */

    
    /**
     * Sample POC method to introspect a custom settings instance for runtime user.
    public static void displayDataUsingMetadata()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name=:userProfile];
        String userProfileId = p.Id;
        
        // get meta-data field names using schema describe
        Schema.DescribeSObjectResult[] descResults = Schema.describeSObjects(new String[]{'TFS_AUP_Application_Access__c'});
        
        // Get application config instance applicable for this profile. 
        // Ideally should be for userId when invoked via. Flow
        TFS_AUP_Application_Access__c userAccess = TFS_AUP_Application_Access__c.getInstance( userProfileId );
        
        // Loop through schema resuls
        for(Schema.DescribeSobjectResult res : descResults) {
            System.debug('sObject Label: ' + res.getLabel());
            System.debug('Number of fields: ' + res.fields.getMap().size());
            System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
            System.debug('Field Name and Value List: ');
            
            Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
            
            for(String key : fieldsMap.keySet() ) {

                Schema.SObjectField fld = fieldsMap.get(key);
                Schema.DescribeFieldResult dfr = fld.getDescribe();
                if( dfr.getName().startsWithIgnoreCase('tfs_aup_') )
                    System.debug('Label = ' + dfr.getLabel() + ', Name = ' + dfr.getName() + ', Type = '+ dfr.getType()  + ', Value = ' + userAccess.get(dfr.getName()));
            }            
            
            // for(String key : res.fields.getMap().keySet() ) {
            //     System.debug('Key='+key );
            //     // System.debug('Value='+(String) res.fields.getMap().get(key) );
            // }
        }
    }
     */
    public class UndefinedSObjectTypeException extends Exception {}

    /**
     * Method to get new sObject by name
     */ 
    public static SObject getSobject(String typeName)
    {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        
        if (targetType == null) {
            // calling code should usually handle this exception:
            throw new UndefinedSObjectTypeException('The requested SObject type [' + typeName + 
                    '] cannot be constructed; it is not configured on this org.');
        }
        // SObjects offer the only way in Apex to instantiate an object with a type determined at 
        // runtime -- you can optionally pass an Id argument to instantiate an SObject for an 
        // existing record:
        return targetType.newSObject();
    }
    
    /*
    public static void displayMetadata()
    {
        // Get the sObject describe result for the TFS_AUP_Application_Access__c object
        Schema.DescribeSObjectResult dsr = TFS_AUP_Application_Access__c.sObjectType.getDescribe();
        Map<String, Schema.FieldSet> FsMap = dsr.fieldSets.getMap();    
            
        for( String key : FsMap.keySet() ) {
            System.debug('Key='+ key + ' Value=' + FsMap.get(key) );
        }
    }
    */

    /*
        // sObject types to describe
        String[] types = new String[]{'Account','Merchandise__c'};
        
        // Make the describe call
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        System.debug('Got describe information for ' + results.size() + ' sObjects.');
        
        // For each returned result, get some info
        for(Schema.DescribeSobjectResult res : results) {
            System.debug('sObject Label: ' + res.getLabel());
            System.debug('Number of fields: ' + res.fields.getMap().size());
            System.debug(res.isCustom() ? 'This is a custom object.' : 'This is a standard object.');
            // Get child relationships
            Schema.ChildRelationship[] rels = res.getChildRelationships();
            if (rels.size() > 0) {
                System.debug(res.getName() + ' has ' + rels.size() + ' child relationships.');
            }
        }
    */
    /*
        // Create a new account as the generic type sObject
        sObject s = new Account();
        
        // Verify that the generic sObject is an Account sObject
        System.assert(s.getsObjectType() == Account.sObjectType);
        
        // Get the sObject describe result for the Account object
        Schema.DescribeSObjectResult dsr = Account.sObjectType.getDescribe();
        
        // Get the field describe result for the Name field on the Account object
        Schema.DescribeFieldResult dfr = Schema.sObjectType.Account.fields.Name;
        
        // Verify that the field token is the token for the Name field on an Account object
        System.assert(dfr.getSObjectField() == Account.Name);
        
        // Get the field describe result from the token
        dfr = dfr.getSObjectField().getDescribe();  
    */
}