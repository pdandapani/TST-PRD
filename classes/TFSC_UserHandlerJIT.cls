/**
* @author: Salesforce Services
* @date:    2014-09-05
* @description: Helper class for the TFSC_UserTrigger trigger
*               
* @log:
* -----------------------------------------------------------------------------
*    Developer                    Date                Description
* -----------------------------------------------------------------------------
*    Scott W                    2014-08-05          creation of class
*   Benajmin L                  2014-08-05          creation of methods
*   
*/
public with sharing class TFSC_UserHandlerJIT implements TFSC_TriggerDispatcher.Handler {
    
    public void handle() {  
        //if (trigger.isInsert) {
        //  if (trigger.isBefore) {
                handleBeforeInsert();
        //  }
        //  else if (trigger.isAfter) {
        //      handleAfterInsert();
        //  }
        //}
    }

    // Just-in-Time Provisioning for Portals
    // https://help.salesforce.com/apex/HTViewHelpDoc?id=sso_jit_portal_requirements.htm

    // need to handle the case where agent creates the shell

    private void handleBeforeInsert() {

        // build a set of SGUIDs
        Set<String> newUserSGUIDS = new Set<String>(); 
        for (User u : (List<User>)trigger.new)
        {
            if (!u.IsPortalEnabled && u.FederationIdentifier != null)
            {
                newUserSGUIDS.add(u.FederationIdentifier);
            }
        }

        // check that there are portal enabled users to process
        if (newUserSGUIDS.size() == 0)
        {
            // no portal users, return
            return;
        }

        // retrieve the accounts for these SGUIDs belonging to portal enabled users
        // build a map of accounts where the key is their email address
        Map<String, Contact> contactMapBySGUID = new Map<String, Contact>();
        for (Contact c : [SELECT Id, FirstName, Title, SGUID__c FROM Contact
            WHERE SGUID__c IN :newUserSGUIDS])
        {
            contactMapBySGUID.put(c.SGUID__c, c);
        }

        // loop through the users and update them with the account data
        for (User u : (List<User>)trigger.new)
        {
        
            system.debug(u.FederationIdentifier);
            // check if an account was found for this SGUID
            if (contactMapBySGUID.containskey(u.FederationIdentifier))
            {
                Contact c = contactMapBySGUID.get(u.FederationIdentifier);
                // account with this SGUID was found, user is properly provisioned, update with account info
                u.FirstName = c.FirstName;
                u.Title = c.Title;
                System.Debug('Updated user defailts for SGUID: ' + u.FederationIdentifier);
            }
            else
            {
                // account with this SGUID could not be found! return an error
                u.addError('This user has not been properly provisioned!');
                System.debug(LoggingLevel.ERROR,
                    'An account with SGUID [' + u.FederationIdentifier + '] could not be found!\n' +
                    'This indicates that the user has not been properly provisioned before attempting to ' +
                    'authenticate to the community.');
            }
        }

    }

    //private void handleAfterInsert() {
    //  // establish link from user to weblogin PersonAccount

 //       // build a list of users that I need to update the associated PersonAccount to point at the user
 //       Set<Id> usersToUpdate = new Set<Id>();
 //       for (User userToCheck : (List<User>)trigger.new)
 //       {
 //           if (!userToCheck.IsPortalEnabled)
 //           {
 //               usersToUpdate.add(userToCheck.Id);
 //           }
 //       }

 //       // check if there are users to update
 //       if (usersToUpdate.size() > 0)
 //       {
 //           // set the Account.Community_User__c to the User.Id with the matching SGUID
 //           // future method since cannot mix setup objects DML
 //           // UpdateContactUserId.UpdateContact(usersToUpdate);
 //       }

    //}

}