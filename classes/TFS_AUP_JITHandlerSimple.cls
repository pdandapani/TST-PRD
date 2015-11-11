//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
// Auto generated code customized to handle user provisioning via. JIT for TFS.
global class TFS_AUP_JITHandlerSimple implements Auth.SamlJitHandler {
	
    private class JitException extends Exception{}
    
    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, boolean isStandard) {
        if(create && attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.Username');
        }
        if(create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
        }
        if(attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        if(attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        if(attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
        }
        if(attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        if(attributes.containsKey('User.AboutMe')) {
            u.AboutMe = attributes.get('User.AboutMe');
        }
        if(attributes.containsKey('User.Street')) {
            u.Street = attributes.get('User.Street');
        }
        if(attributes.containsKey('User.State')) {
            u.State = attributes.get('User.State');
        }
        if(attributes.containsKey('User.City')) {
            u.City = attributes.get('User.City');
        }
        if(attributes.containsKey('User.Zip')) {
            u.PostalCode = attributes.get('User.Zip');
        }
        if(attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }
        if(attributes.containsKey('User.CallCenter')) {
            u.CallCenterId = attributes.get('User.CallCenter');
        }
        if(attributes.containsKey('User.Manager')) {
            u.ManagerId = attributes.get('User.Manager');
        }
        if(attributes.containsKey('User.MobilePhone')) {
            u.MobilePhone = attributes.get('User.MobilePhone');
        }
        if(attributes.containsKey('User.DelegatedApproverId')) {
            u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
        }
        if(attributes.containsKey('User.Department')) {
            u.Department = attributes.get('User.Department');
        }
        if(attributes.containsKey('User.Division')) {
            u.Division = attributes.get('User.Division');
        }
        if(attributes.containsKey('User.EmployeeNumber')) {
            u.EmployeeNumber = attributes.get('User.EmployeeNumber');
        }
        if(attributes.containsKey('User.Extension')) {
            u.Extension = attributes.get('User.Extension');
        }
        if(attributes.containsKey('User.Fax')) {
            u.Fax = attributes.get('User.Fax');
        }
        if(attributes.containsKey('User.CommunityNickname')) {
            u.CommunityNickname = attributes.get('User.CommunityNickname');
        }
        if(attributes.containsKey('User.ReceivesAdminInfoEmails')) {
            String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
            u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
        }
        if(attributes.containsKey('User.ReceivesInfoEmails')) {
            String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
            u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
        }
        String uid = UserInfo.getUserId();
        User currentUser = 
            [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        if(attributes.containsKey('User.LocaleSidKey')) {
            u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else if(create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if(attributes.containsKey('User.LanguageLocaleKey')) {
            u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else if(create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if(attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if(create) {
            String alias = '';
            if(u.FirstName == null) {
                alias = u.LastName;
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if(alias.length() > 5) {
                alias = alias.substring(0, 5);
            }
            u.Alias = alias;
        }
        if(attributes.containsKey('User.TimeZoneSidKey')) {
            u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        } else if(create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if(attributes.containsKey('User.EmailEncodingKey')) {
            u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if(create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }

        /*
         * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.
         */
        if(attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
        if(attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }
        /*
        if(attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile WHERE Id=:profileId];
            u.ProfileId = p.Id;
        }
        if(attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id=:userRole];
            u.UserRoleId = r.Id;
        }
        */

        //Handle custom fields here
        
        if(attributes.containsKey('User.Lan_Id__c')) {
            u.Lan_Id__c = attributes.get('User.Lan_Id__c');
        } else if(create) {
            u.Lan_Id__c = currentUser.Lan_Id__c;
        }
        if(attributes.containsKey('User.Coll_Racf_Id__c')) {
            u.Coll_Racf_Id__c = attributes.get('User.Coll_Racf_Id__c');
        } else if(create) {
            u.Coll_Racf_Id__c = currentUser.Coll_Racf_Id__c;
        }
        
        // Quick and dirty code begins here. 
        // Custom code to handle name value pairs
        // semicolen seprated values for testing 
        // Business:Function:Role

		// /////////////////////////////////////////////////////////////////////////////////////// 
		// Note: this is the section of code that prepares glue code and implements
		// logic that assigns appropriate profile and permissions based on custom setting
		// TFS_AUP_Access_Control__c is the custom settings object used to drive this logic.
		// Prakash Dandapani, 10-Sep-2015, POC code not for production.
		// /////////////////////////////////////////////////////////////////////////////////////// 
		
		// User properties, for now sent as Business:Function
		// Set these only when createing a new user. 
        if(create && 
           attributes.containsKey('JITUserProperties')) {
           	
            String userProperties = attributes.get('JITUserProperties');
        
        	// Keep it simple for now. See below for details.
        	// Set business and function to user record
        	assignBusinessAndFunction(u, userProperties );
        
	        // Generate glue code to lookup user profile and role applicable to this user.      
	        // Note: This code is required as we are using custom settings to lookup profile and
	     	// role Ids. Custom steting Name (lookup value) has a limit of 40 characters.
	     	// Design Decision: Should we use custom object instead of custom settings?
	     	// This will allow us to define access levels based on user properties 
	     	// In any case the code or user properties need to be persisted in user record 
	     	// for assigning permission sets after user logs in.   
            
            // Expecting Business:User Function:Application
            // e.g.: Collection:Admin:Collection Console
            // Returns a 24 character string e.g.: vJFsQZAkbJBTupOxVXuoAA==
            // String glueCode = generateGlueCode( userProperties );
            
            // assignUserProfileAndRole(u, glueCode );

        	// Keep it simple for now. See above for details.
        	// Set user profile and role based on user properties
            assignUserProfileAndRole(u, userProperties );
            
            // Flag that forces login flow execution. Only when creating a user,
        	u.AUP_Change_Permissions__c = True;		// Flow logic kicks in with this flag.
            u.UserPermissionsKnowledgeUser = True; 	// Knowledge user permission ?
			u.UserPermissionsSupportUser = True; 	// Service Cloud user permission ? 
         }       

        if(!create) {
            update(u);
        }
    }
    
    /**
     * Note: This method is just a place holder method. 
     * This method takes a concatinated stirng as user properties that indicate
     * user's business unit and function. This value helps to derive  role, 
     * profile and stamp user record for later referance. 
     */
	private void assignBusinessAndFunction( User usr, String userProperties )
	{
        List<String> values = userProperties.split(':',2);
        
        if( values != Null && 
            values.size() == 2) {
            
            usr.AUP_Business_Unit__c = values[0];
            usr.AUP_User_Function__c = values[1];
            // Debug 
            System.debug('------------------------');
            System.debug('AUP_Business_Unit__c='+values[0]);
            System.debug('AUP_User_Function__c='+values[1]);
            System.debug('------------------------');
            
         }
         else {
         		throw new JitException('Error: -101 - Failed to setup user. Contact your administrator.');
         }
	}    

    /**
     * Note: This method is just a place holder method. 
	 * Method that takes a glue code (eg.Business:User Function:Application
	 * Figures out appropriate Id based on glue code.
	 * Note: Glue code is restricted to 40 characters max as we are using custom settings
	 * If required we need a layer of transformation taking attributes from SAML 
	 * and redue it a unique string that is 40 characters or less.
	 */    
    private void assignUserProfileAndRole(User usr, String glueCode )
    {
    	TFS_AUP_Access_Control__c userAccess = TFS_AUP_Access_Control__c.getValues(glueCode);
    	Boolean profileAssigned = False;
    	
    	if( userAccess != Null ) {
    		
    		// If profile Id already configured take that.
    		// May need further validation if its 15 or 18 characters.
    		if( userAccess.Profile_Id__c != Null ) {
    			usr.profileId = userAccess.Profile_Id__c;
    			profileAssigned = True;
    		}
    		// If only name provided take profile name and get Id
    		else if( userAccess.Profile_Name__c != Null ) {
    			
	            Profile p = [SELECT Id FROM Profile WHERE Name=:userAccess.Profile_Name__c];
	            usr.profileId = p.Id;
    			profileAssigned = True;
    		}
    			
    		// May need further validation if its 15 or 18 characters.
    		if( userAccess.Role_Id__c != Null ) {
    			usr.userRoleId = userAccess.Role_Id__c;
    		}
    		// If only name provided take role name and get Id
    		else if( userAccess.Role_Dev_Name__c != Null ) {
    				 
                UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName=:userAccess.Role_Dev_Name__c];
                usr.userRoleId = r.Id;
    		}    			
    	}
    	
    	if( ! profileAssigned ) 
    		throw new JitException('Error: -102 - Failed to setup user. Contact your administrator.');
    }
    
    /**
     * Note: This method is just a place holder method. 
     * A of now it takes a string to generate MD5 hash code that will be 24 char long. 
     * Method to generate glue code based on user properties that is sent in SAML
     * Eventually once user properties are flushed out this method 
     * should be modified to take multiple properties and coin a glue code,
     *
     * Note: This code is required as we are using custom settings to lookup profile and
     * role Ids. Custom steting Name (lookup value) has a limit of 40 characters.
     */
	private String generateGlueCode( String userProperties )
	{
		
		return StringUtil.getMD5Hash( userProperties );
	} 
	  
    /*
    private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
        Contact c;
        boolean newContact = false;
        if(create) {
            if(attributes.containsKey('User.Contact')) {
            String contact = attributes.get('User.Contact');
                c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
                u.ContactId = contact;
            } else {
                c = new Contact();
                newContact = true;
            }
        } else {
            if(attributes.containsKey('User.Contact')) {
                String contact = attributes.get('User.Contact');
                c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
                if(u.ContactId != c.Id) {
                    throw new JitException('Cannot change User.ContactId');
                }
            } else {
                String contact = u.ContactId;
                c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
            }
        }
        if(!newContact && c.AccountId != accountId) {
            throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
        }

        if(attributes.containsKey('Contact.Email')) {
            c.Email = attributes.get('Contact.Email');
        }
        if(attributes.containsKey('Contact.FirstName')) {
            c.FirstName = attributes.get('Contact.FirstName');
        }
        if(attributes.containsKey('Contact.LastName')) {
            c.LastName = attributes.get('Contact.LastName');
        }
        if(attributes.containsKey('Contact.Phone')) {
            c.Phone = attributes.get('Contact.Phone');
        }
        if(attributes.containsKey('Contact.MailingStreet')) {
            c.MailingStreet = attributes.get('Contact.MailingStreet');
        }
        if(attributes.containsKey('Contact.MailingCity')) {
            c.MailingCity = attributes.get('Contact.MailingCity');
        }
        if(attributes.containsKey('Contact.MailingState')) {
            c.MailingState = attributes.get('Contact.MailingState');
        }
        if(attributes.containsKey('Contact.MailingCountry')) {
            c.MailingCountry = attributes.get('Contact.MailingCountry');
        }
        if(attributes.containsKey('Contact.MailingPostalCode')) {
            c.MailingPostalCode = attributes.get('Contact.MailingPostalCode');
        }
        if(attributes.containsKey('Contact.OtherStreet')) {
            c.OtherStreet = attributes.get('Contact.OtherStreet');
        }
        if(attributes.containsKey('Contact.OtherCity')) {
            c.OtherCity = attributes.get('Contact.OtherCity');
        }
        if(attributes.containsKey('Contact.OtherState')) {
            c.OtherState = attributes.get('Contact.OtherState');
        }
        if(attributes.containsKey('Contact.OtherCountry')) {
            c.OtherCountry = attributes.get('Contact.OtherCountry');
        }
        if(attributes.containsKey('Contact.OtherPostalCode')) {
            c.OtherPostalCode = attributes.get('Contact.OtherPostalCode');
        }
        if(attributes.containsKey('Contact.AssistantPhone')) {
            c.AssistantPhone = attributes.get('Contact.AssistantPhone');
        }
        if(attributes.containsKey('Contact.Department')) {
            c.Department = attributes.get('Contact.Department');
        }
        if(attributes.containsKey('Contact.Description')) {
            c.Description = attributes.get('Contact.Description');
        }
        if(attributes.containsKey('Contact.Fax')) {
            c.Fax = attributes.get('Contact.Fax');
        }
        if(attributes.containsKey('Contact.HomePhone')) {
            c.HomePhone = attributes.get('Contact.HomePhone');
        }
        if(attributes.containsKey('Contact.MobilePhone')) {
            c.MobilePhone = attributes.get('Contact.MobilePhone');
        }
        if(attributes.containsKey('Contact.OtherPhone')) {
            c.OtherPhone = attributes.get('Contact.OtherPhone');
        }
        if(attributes.containsKey('Contact.Title')) {
            c.Title = attributes.get('Contact.Title');
        }
        if(attributes.containsKey('Contact.Salutation')) {
            c.Salutation = attributes.get('Contact.Salutation');
        }
        if(attributes.containsKey('Contact.LeadSource')) {
            c.LeadSource = attributes.get('Contact.LeadSource');
        }
        if(attributes.containsKey('Contact.CanAllowPortalSelfReg')) {
            String CanAllowPortalSelfRegVal = attributes.get('Contact.CanAllowPortalSelfReg');
            c.CanAllowPortalSelfReg = '1'.equals(CanAllowPortalSelfRegVal) || Boolean.valueOf(CanAllowPortalSelfRegVal);
        }
        if(attributes.containsKey('Contact.DoNotCall')) {
            String DoNotCallVal = attributes.get('Contact.DoNotCall');
            c.DoNotCall = '1'.equals(DoNotCallVal) || Boolean.valueOf(DoNotCallVal);
        }
        if(attributes.containsKey('Contact.HasOptedOutOfEmail')) {
            String HasOptedOutOfEmailVal = attributes.get('Contact.HasOptedOutOfEmail');
            c.HasOptedOutOfEmail = '1'.equals(HasOptedOutOfEmailVal) || Boolean.valueOf(HasOptedOutOfEmailVal);
        }
        if(attributes.containsKey('Contact.HasOptedOutOfFax')) {
            String HasOptedOutOfFaxVal = attributes.get('Contact.HasOptedOutOfFax');
            c.HasOptedOutOfFax = '1'.equals(HasOptedOutOfFaxVal) || Boolean.valueOf(HasOptedOutOfFaxVal);
        }
        if(attributes.containsKey('Contact.Owner')) {
            c.OwnerId = attributes.get('Contact.Owner');
        }
        if(attributes.containsKey('Contact.AssistantName')) {
            c.AssistantName = attributes.get('Contact.AssistantName');
        }
        if(attributes.containsKey('Contact.Birthdate')) {
            c.Birthdate = Date.valueOf(attributes.get('Contact.Birthdate'));
        }
        if(newContact) {
            c.AccountId = accountId;
            insert(c);
            u.ContactId = c.Id;
        } else {
            update(c);
        }
    }
    */
    /*
    private String handleAccount(boolean create, User u, Map<String, String> attributes) {
        Account a;
        boolean newAccount = false;
        if(create) {
            if(attributes.containsKey('User.Account')) {
                String account = attributes.get('User.Account');
                a = [SELECT Id FROM Account WHERE Id=:account];
            } else {
                if(attributes.containsKey('User.Contact')) {
                    String contact = attributes.get('User.Contact');
                    Contact c = [SELECT AccountId FROM Contact WHERE Id=:contact];
                    String account = c.AccountId;
                    a = [SELECT Id FROM Account WHERE Id=:account];
                } else {
                    a = new Account();
                    newAccount = true;
                }
            }
        } else {
            if(attributes.containsKey('User.Account')) {
            String account = attributes.get('User.Account');
                a = [SELECT Id FROM Account WHERE Id=:account];
            } else {
                if(attributes.containsKey('User.Contact')) {
                    String contact = attributes.get('User.Contact');
                    Contact c = [SELECT Id, AccountId FROM Contact WHERE Id=:contact];
                    if(u.ContactId != c.Id) {
                        throw new JitException('Cannot change User.ContactId');
                    }
                    String account = c.AccountId;
                    a = [SELECT Id FROM Account WHERE Id=:account];
                } else {
                    throw new JitException('Could not find account');
                }
            }
        }
        if(attributes.containsKey('Account.Name')) {
            a.Name = attributes.get('Account.Name');
        }
        if(attributes.containsKey('Account.AccountNumber')) {
            a.AccountNumber = attributes.get('Account.AccountNumber');
        }
        if(attributes.containsKey('Account.Owner')) {
            a.OwnerId = attributes.get('Account.Owner');
        }
        if(attributes.containsKey('Account.BillingStreet')) {
            a.BillingStreet = attributes.get('Account.BillingStreet');
        }
        if(attributes.containsKey('Account.BillingCity')) {
            a.BillingCity = attributes.get('Account.BillingCity');
        }
        if(attributes.containsKey('Account.BillingState')) {
            a.BillingState = attributes.get('Account.BillingState');
        }
        if(attributes.containsKey('Account.BillingCountry')) {
            a.BillingCountry = attributes.get('Account.BillingCountry');
        }
        if(attributes.containsKey('Account.BillingPostalCode')) {
            a.BillingPostalCode = attributes.get('Account.BillingPostalCode');
        }
        if(attributes.containsKey('Account.AnnualRevenue')) {
            a.AnnualRevenue = Integer.valueOf(attributes.get('Account.AnnualRevenue'));
        }
        if(attributes.containsKey('Account.Description')) {
            a.Description = attributes.get('Account.Description');
        }
        if(attributes.containsKey('Account.Fax')) {
            a.Fax = attributes.get('Account.Fax');
        }
        if(attributes.containsKey('Account.NumberOfEmployees')) {
            a.NumberOfEmployees = Integer.valueOf(attributes.get('Account.NumberOfEmployees'));
        }
        if(attributes.containsKey('Account.Phone')) {
            a.Phone = attributes.get('Account.Phone');
        }
        if(attributes.containsKey('Account.ShippingStreet')) {
            a.ShippingStreet = attributes.get('Account.ShippingStreet');
        }
        if(attributes.containsKey('Account.ShippingCity')) {
            a.ShippingCity = attributes.get('Account.ShippingCity');
        }
        if(attributes.containsKey('Account.ShippingState')) {
            a.ShippingState = attributes.get('Account.ShippingState');
        }
        if(attributes.containsKey('Account.ShippingCountry')) {
            a.ShippingCountry = attributes.get('Account.ShippingCountry');
        }
        if(attributes.containsKey('Account.ShippingPostalCode')) {
            a.ShippingPostalCode = attributes.get('Account.ShippingPostalCode');
        }
        if(attributes.containsKey('Account.Sic')) {
            a.Sic = attributes.get('Account.Sic');
        }
        if(attributes.containsKey('Account.TickerSymbol')) {
            a.TickerSymbol = attributes.get('Account.TickerSymbol');
        }
        if(attributes.containsKey('Account.Website')) {
            a.Website = attributes.get('Account.Website');
        }
        if(attributes.containsKey('Account.Industry')) {
            a.Industry = attributes.get('Account.Industry');
        }
        if(attributes.containsKey('Account.Ownership')) {
            a.Ownership = attributes.get('Account.Ownership');
        }
        if(attributes.containsKey('Account.Rating')) {
            a.Rating = attributes.get('Account.Rating');
        }
        if(newAccount) {
            insert(a);
        } else {
            update(a);
        }
        return a.Id;
    }
    */
    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        if(communityId != null || portalId != null) {
            // String account = handleAccount(create, u, attributes);
            // handleContact(create, account, u, attributes);
            handleUser(create, u, attributes, federationIdentifier, false);
        } else {
            handleUser(create, u, attributes, federationIdentifier, true);
        }
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }
}