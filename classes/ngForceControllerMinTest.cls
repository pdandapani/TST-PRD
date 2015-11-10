@isTest
public with sharing class ngForceControllerMinTest {
	
	static testMethod void testSimple() {
      System.assertEquals('Simple', 'Simple'); 
    
    }
    
    
    static testMethod void insertSearchTest() {
    	
    	 Test.startTest();
    	 
    	 
    	 Integer sizeBefore = ngForceControllerMin.getSavedSearches().size();
    	 ngForceControllerMin.insertSearch('Search01','Type:DNC');
    	 Integer sizeAfter = ngForceControllerMin.getSavedSearches().size();
    	 
    	 System.assertNotEquals(sizeAfter, sizeBefore);
    	 
    	 Test.stopTest();
    	
    	
    }
    
    static testMethod void deleteSearchTest() {
    	
    	 Test.startTest();
    	 
    	 
	    	 Integer sizeBefore = ngForceControllerMin.getSavedSearches().size();
	    	 
	    	 String Id = ngForceControllerMin.insertSearchGetId('Search01','Type:DNC');
	    	 
	    	 ngForceControllerMin.deleteSearch(Id);
	    	 
	    	 Integer sizeAfter = ngForceControllerMin.getSavedSearches().size();
	    	 
	    	 System.assertEquals(sizeAfter, sizeBefore);
    	 
    	 Test.stopTest();
    	
    	
    }
    
    
    static testMethod void QueryTest() {
    	
    	 Test.startTest();
    	 
    	 
    	     String qryStr = ' SELECT Id, Name, Search_Criteria__c, Globally_Available__c   FROM Saved_Notes_Search__c '  ;
                                      
	    	 String jsonStrBefore =  ngForceControllerMin.query(qryStr);
	    	 
	    	 String Id = ngForceControllerMin.insertSearchGetId('Search01','Type:DNC');
	    	 
	    	 String jsonStrAfter =  ngForceControllerMin.query(qryStr);
	    	 
	    	 
	    	 
	    	 System.assertNotEquals(jsonStrBefore, jsonStrAfter);
    	 
    	 Test.stopTest();
    	
    	
    }

}