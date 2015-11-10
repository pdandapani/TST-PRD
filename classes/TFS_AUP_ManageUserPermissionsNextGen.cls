/**
 Test code to validate if custom setings could be dynamically loaded 
 Intent of this code is to drive the functionality of assigning relevant permission sets to users 
 after provisioning via. JIT. This code is to figurre out if custom settings could be used to configure 
 and lookup permission sets available to a user based on certain properties supplied during JIT.  
*/
public with sharing class TFS_AUP_ManageUserPermissionsNextGen {

    static public final String APU_USER_ACCESS_CONTROL = 'AUP_Access_Control__mdt';
    static public final String APU_APP_ACCESS = 'TFS_AUP_Application_Access__c';
    static public final String APU_APP_PERMSSIONS = 'AUP_User_Access__mdt';
    static public final String APU_APP_NAME_FIELD = 'Application_Name__c';
    static public final String AUP_META_DATA_PREFIX = 'tfs_aup_';
    
    // static public String userFunction { set; get; }
    // static public String userProfile { set; get; }
    // static public String userRole { set; get; }
    // static public String userId { set; get; }
    
    public TFS_AUP_ManageUserPermissionsNextGen()
    {
        // userFunction = 'Collection';
        // userRole = 'Agent';
        // userProfile = 'Collection Base';
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
        List<String> listUserApplications = Null;
        
        if( listUsers != NUll && 
            listUsers.size() > 0 )
            currentUser = listUsers.get(0);
        
        // Process only if user found and change permisison flag set.
        // Note: This flag will be marked once user gets provisioned via. JIT.
        // Checkign againg as a safety net.
        if(currentUser != Null && 
            currentUser.AUP_Change_Permissions__c == True ) {
            
            // Retrieve all eligible application nams.
	        listUserApplications = getConfiguredApplicationNames();
        
        	// TODO: Fix clear permissions for next gen version
            // Clear any permission assigned to this user
            clearUserPermissions(currentUser, listUserApplications );
            
            // Get permission sets configured
            List<PermissionSetAssignment> listUserPerms = getUserPermissionSetsToAssign(currentUser, listUserApplications);
            
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
            List<GroupMember> listUserGroupPerms = getUserGroupsToAssign(currentUser, listUserApplications);
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
     * Method returns list of custom objects to be queried for 
     */
    private static List<String> getConfiguredApplicationNames()
    {
        // get meta-data field names using schema describe
        Schema.DescribeSObjectResult[] descResults = Schema.describeSObjects(new String[]{ APU_APP_ACCESS });
        
        // Get application config instance applicable for this profile. 
        // Ideally should be for userId when invoked via. Flow
        // TFS_AUP_Application_Access__c userAccess = TFS_AUP_Application_Access__c.getInstance();
        
        // TODO: Clean up. Forcing a user Id thats passs as parameter for testing.  
        // TFS_AUP_Application_Access__c userAccess = TFS_AUP_Application_Access__c.getInstance( userId );
        // Note: Get instance on a hierarchy custom settings should return an aggregated view 

        // DEFECT: Appears there is a possible defect in platform as it is not agregating org level settings
        // when getInstance() called at user level. 
        TFS_AUP_Application_Access__c userAccess = TFS_AUP_Application_Access__c.getInstance();
        
        List<String> listUserAccessNames = new List<String>();
        
        // Loop through schema resuls. Need to optimize 
        for(Schema.DescribeSobjectResult res : descResults) {
            
            Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
            
            for(String key : fieldsMap.keySet() ) {

                Schema.SObjectField fld = fieldsMap.get(key);
                
                Schema.DescribeFieldResult dfr = fld.getDescribe();
                // Select application names that are checked for this user / profile / org.
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
    
    /**
     * Method to retrieve permission sets setup for user based on Business Unit and Function values
     */
    private static List<PermissionSetAssignment> getUserPermissionSetsToAssign(User usr, List<String> listAppNames)
    {
        // List<PermissionSetAssignment> listPSAssignment = Null;
        List<PermissionSetAssignment> listPSAssignment = new List<PermissionSetAssignment>();
        
        // Debug
        System.debug('usrName='+usr.username);
        System.debug('usrFunction='+usr.AUP_User_Function__c);
        System.debug('usrBusiness='+usr.AUP_Business_Unit__c);
        
        // Set<String> permissionSetIds = getPermissionSetIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
        Set<String> permissionSetIds = getPermissionSetIds( usr, listAppNames );
        
        if( permissionSetIds != Null && 
            permissionSetIds.size() > 0 ) {
            	
	        // Debug
	        System.debug('permissionSetIds.size() = ' + permissionSetIds.size() );
            // listPSAssignment = new List<PermissionSetAssignment>();
            
	        for( String psId : permissionSetIds ) {
	        	// Debug
	        	System.debug('UserId='+usr.Id + 'PermId='+psId);
	            listPSAssignment.add( new PermissionSetAssignment(AssigneeId=usr.Id,PermissionSetId=psId) );
	        }
        }
        return listPSAssignment;
    }
    
    
    /**
     * Method to find matching permission set Ids based on business and function attribute in user record
     */
    // public static Set<String> getPermissionSetIds(String usrBusiness, String usrFunction)
    private static Set<String> getPermissionSetIds(User usr, List<String> listAppNames)
    {
        Set<String> setOfPSIds = Null;
        
        Set<String> setOfPSNames = getApplicablePermissionSetNames( usr, listAppNames );
        
        if( setOfPSNames != Null && 
            setOfPSNames.size() > 0 ) {
	        // Debug
	        System.debug('setOfPSNames.size() = '+ setOfPSNames.size() );
            String query = TFS_Query_Utility.composeSelectQueryIn('PermissionSet', 
                                                         'Id, Name', 
                                                         'Name', 
                                                         setOfPSNames );
                                                             
            setOfPSIds = executeQueryAndReturnSet( query, 'Id' );
            
        }
        return setOfPSIds;
    }
    
	/**
	 * Method to retrieve list of group names configured 
	 */    
    private static List<GroupMember> getUserGroupsToAssign(User usr, List<String> listAppNames)
    {
        // List<GroupMember> listGMAssignment = Null;
        List<GroupMember> listGMAssignment = new List<GroupMember>();
        // Debug
        System.debug('usrName='+usr.username);
        System.debug('usrFunction='+usr.AUP_User_Function__c);
        System.debug('usrBusiness='+usr.AUP_Business_Unit__c);
        
        // Set<String> groupIds = getGroupIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
        Set<String> groupIds = getGroupIds(usr, listAppNames);
        
        if( groupIds != Null && 
            groupIds.size() > 0 ) {

	        // Debug
	        System.debug('groupIds.size() = ' + groupIds.size() );
            // listGMAssignment = new List<GroupMember>();
	        for( String ugId : groupIds ) {
	        	// Debug
	        	System.debug('UserId='+usr.Id + 'ugId='+ugId);
	            listGMAssignment.add( new GroupMember(UserOrGroupId=usr.Id,GroupId=ugId) );
	        }
        }
        return listGMAssignment;
    }
    
    /**
     * Method to find matching permission set Ids based on business and function attribute in user record
     */
    // public static Set<String> getGroupIds(String usrBusiness, String usrFunction)
    private static Set<String> getGroupIds(User usr, List<String> listAppNames)
    {
        Set<String> setOfGrpIds = Null;
        Set<String> setOfGrpNames = getApplicableGroupNames(usr, listAppNames);

        if( setOfGrpNames != Null && 
            setOfGrpNames.size() > 0 ) {
	        // Debug
	        System.debug('setOfGrpNames.size() = '+ setOfGrpNames.size() );
            	
            String query = TFS_Query_Utility.composeSelectQueryIn('Group', 
                                                         'Id, developerName, Name, Type', 
                                                         'developerName', 
                                                         setOfGrpNames );
                                                         
            // Note: Required to filter only for Public Group 
            query = query + 'And Type = \'Regular\'';
                                                             
            setOfGrpIds = executeQueryAndReturnSet( query, 'Id' );
            
        }
        return setOfGrpIds;
    }
    
    /**
     * Method to clear any permission set or group membership configured for this user
     * TODO: Need to determine if this method is required or not. Using it for now for recycling user Id.
     */
    private static void clearUserPermissions(User usr, List<String> listAppNames)
    {   
    	List<sObject> listOfObjToDelete = new List<sObject>();
        // Debug
        System.debug('usrName='+usr.username);
        System.debug('usrFunction='+usr.AUP_User_Function__c);
        System.debug('usrBusiness='+usr.AUP_Business_Unit__c);
    	
    	// Pull all applicable permission set Ids.
    	// Set<String> setOfPSIds = getPermissionSetIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
    	Set<String> setOfPSIds = getPermissionSetIds(usr, listAppNames);
    	
    	// Query and delete permission sets assigned for this user
		String query = TFS_Query_Utility.composeSelectQuery('PermissionSetAssignment', 
															'AssigneeId,Id,PermissionSetId',
															'AssigneeId',
															usr.Id );

		List<PermissionSetAssignment> listPSAssigned =  Database.query(query);
		
		listOfObjToDelete.addAll(findMatchingObjects( listPSAssigned, setOfPSIds, 'PermissionSetId') );

    	// Pull all applicable permission set Ids.
    	// Set<String> setOfGrpIds = getGroupIds( usr.AUP_Business_Unit__c, usr.AUP_User_Function__c );
    	Set<String> setOfGrpIds = getGroupIds(usr, listAppNames);

    	// Query and delete group membership assigned for this user
		query = TFS_Query_Utility.composeSelectQuery('GroupMember', 
													 'GroupId,Id,UserOrGroupId',
													 'UserOrGroupId',
													 usr.Id );
													 
		List<GroupMember> listGMAssigned = 	Database.query(query);

		listOfObjToDelete.addAll( findMatchingObjects( listGMAssigned, setOfGrpIds, 'GroupId') );
		
		if( listOfObjToDelete.size() > 0 )
			delete listOfObjToDelete;
																					
    }
        
	 
    /**
     * Method runs a query and returns a field from select clause.
     * Note: field name passed should be seleted in select clause
     */
    private static Set<String> executeQueryAndReturnSet(String query, String fieldName )
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
	private static Set<sObject> findMatchingObjects(List<sObject> listObj, Set<String> setOfIds, String IdField )
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
	
	/**
	 * Get list of permission set names configured for applicstions accessible to user
	 * Note: This method determines permission set names based on user function attribute
	 */
	private static Set<String> getApplicablePermissionSetNames(User usr, List<String> listAppNames)
	{
        String query = TFS_Query_Utility.composeSelectQuery( APU_APP_PERMSSIONS, 
                                                     		 APU_APP_NAME_FIELD, 
                                                     		 new Set<String>(listAppNames) );
                                                     		 

		// Note: Filter ones with user's job function selected
		query = query + ' And ' + getMetadataColumnName(usr.AUP_User_Function__c)  +  ' = True ';                                        		 

        // Note: Required to filter only for Public Group 
        query = query + ' And Group_Indicator__c = FALSE ';
		
		// Debug                                                         
        System.debug('Permission Set Query = ' + query );
        
        return executeQueryAndReturnSet( query, 'Access_Name__c' );
	}
	
	/**
	 * Get list of group names configured for applicstions accessible to user
	 * Note: This method determines permission set names based on user function attribute
	 */
	private static Set<String> getApplicableGroupNames(User usr, List<String> listAppNames)
	{
        String query = TFS_Query_Utility.composeSelectQuery( APU_APP_PERMSSIONS, 
                                                     		 APU_APP_NAME_FIELD, 
                                                     		 new Set<String>(listAppNames) );

		// Note: Filter ones with user's job function selected
		query = query + ' And ' + getMetadataColumnName(usr.AUP_User_Function__c)  +  ' = True ';                                        		 

        // Note: Required to filter only for Public Group 
        query = query + ' And Group_Indicator__c = TRUE ';
		
		// Debug                                                         
        System.debug('Group Query = ' + query );
        
        return executeQueryAndReturnSet( query, 'Access_Name__c' );
	}
	
	/**
	 * A convenient method that takes a user function attribute and returns corresponding metadata field name.
	 * Note: This method hard wires a user attribute (data value) to a custom field name (meta-data element) as defined
	 * in custom metadata object AUP_User_Access__mdt
	 * Recommendation: It is worth considering replacing this method with another custom metadata type object
	 * that helps translate business function into appropriate column name / names.
	 * Prakash Dandapani, 13-Sep-2015
	 */ 
	private static String getMetadataColumnName(String userFunction)
	{
		// Taking a short cut by transforming user function name into a column name.
		// Note: Consistent naming required betwee data and meta-data for this to work reliablly.
		
		return StringUtil.getAPIName(userFunction) + '__c';
	}	 
	 
}