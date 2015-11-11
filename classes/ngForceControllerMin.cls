global class ngForceControllerMin{
    
    public Boolean makeGridVisible{get;set;}
    
    public ngForceControllerMin() {
    	makeGridVisible = false;
    }
    
    public PageReference updateGridVisible() {
    	return null;
    }
    
    public static List<Saved_Notes_Search__c> savedSearches  { get; set; }
    
    @RemoteAction
    global static List<Saved_Notes_Search__c> getSavedSearches() {
         String userProfileName =
           [SELECT u.Profile.Name FROM User u WHERE u.id = :Userinfo.getUserId()].Profile.Name;
       

          String qry = 
                   ' SELECT Id, Name, Search_Criteria__c, Globally_Available__c '  
                  + ' FROM Saved_Notes_Search__c ' +
                  + '  WHERE OwnerId = \'' + UserInfo.getUserId() + '\'' +
                  +'                 OR ' 
                  + '      Profile_Visibility__c INCLUDES (\'' + userProfileName + '\')' 
                  + '         ORDER BY  Globally_Available__c    DESC, Name ';
                          

                    
                    

            savedSearches =  Database.query(qry);
       
        return savedSearches;
    }
    
    @RemoteAction
    global static void insertSearch(String name, String criteria) {
        Saved_Notes_Search__c search = new Saved_Notes_Search__c();
        search.name = name;
        search.Search_Criteria__c = criteria;
        
        insert search;
    }
    
    
    @RemoteAction
    global static String insertSearchGetId(String name, String criteria) {
        Saved_Notes_Search__c search = new Saved_Notes_Search__c();
        search.name = name;
        search.Search_Criteria__c = criteria;
        
        insert search;
        return search.Id;
    }
    
    @RemoteAction
    global static void deleteSearch(String id) {
        Saved_Notes_Search__c search = new Saved_Notes_Search__c();
        search.Id = id; 
        delete search;
    }



    @remoteAction
    global static String query(String soql) {
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return '[{"message":"'+qe.getMessage()+'","errorCode":"INVALID_QUERY"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);
        
        return JSON.serialize(result);
    }
    
    
    @remoteAction
    global static List<Task> queryTasks(String faId) {
        
        List<Task> listToReturn;
        listToReturn = [SELECT  Id, Source_Created_Date__c, Service_Request_User_Group__c, Collection_Activity_Code__c, 
                           Service_Request_Type__c, Description,  StarsSRNumber__c, Source_Created_By__c,
                           Source_System_Created_By__c, Service_Request_Category__c, Service_Result__c, 
                           Service_Type__c, Current_Mileage__c, Service_Recipient__c, SR_Last_Name_Business_Name__c, 
                           SR_First_Name__c, Status, LastModifiedBy.Name, LastModifiedDate, TransferReason__c, Dealer__c
                        FROM Task 
                        WHERE Financial_Account__c = :faId 
                        ORDER BY Source_Created_Date__c DESC
                        LIMIT 1000];
        
        return listToReturn;
        
    }
    
    
    @remoteAction
    global static List<Case> queryCases(String faId) {
        
        List<Case> listToReturn;
        listToReturn = [SELECT Id, Source_Created_Date__c, Service_Request_User_Group__c, Communication_Comments__c,    
                            Service_Request_Type__c, Description,  StarsSRNumber__c, Source_Created_By__c,
                            Source_System_Created_By__c, Service_Request_Category__c, Service_Result__c, Service_Type__c, 
                            Current_Mileage__c, Service_Recipient__c, SR_Last_Name_Business_Name__c, SR_First_Name__c, 
                            Status, LastModifiedBy.Name, LastModifiedDate, TransferReason__c, Dealer__c 
                         FROM Case 
                         WHERE Financial_Account__c = :faId
                         ORDER BY Source_Created_Date__c DESC
                         LIMIT 1000];
                        
        return listToReturn;
        
    }
    
    
}