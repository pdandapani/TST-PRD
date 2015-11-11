public with sharing class TFSC_ActivityModel {
    

    @InvocableMethod(label='Lookup Most Recent Contact Date' description='Returns the date of the most recent contact')
    public static List<String> LookupMostRecentContactDate(List<String> faIds){

        //List<date> contactDates = new List<date>();
        List<Repo_Recovery_Activity_Codes__c> activityCodeList = Repo_Recovery_Activity_Codes__c.getAll().values();

        List<String> codes = new List<String>();
        List<String> taskID = new List<String>();
        List<String> contactDates = new List<String>();
        String faId = faIds.get(0);
        System.debug('******************* FA ID: ' + faId);

        for(Repo_Recovery_Activity_Codes__c c : activityCodeList)
        {
            System.debug('*************** Activity Code: ' + c.Name);
            codes.add(c.Name);
        }

        
       for(Task t : [SELECT Id,Collection_Activity_DateTime__c,Collection_Activity_Code__c,CreatedDate,Source_Created_Date__c
                     FROM Task WHERE WhatId = :faId  AND Collection_Activity_Code__c IN :codes ])
          {
                   
            //String dateString = String.valueOf(t.Source_Created_Date__c.month())+ String.valueOf(t.Source_Created_Date__c.day()) + String.valueOf(t.Source_Created_Date__c.year());
            
            String tid  = String.valueOf(t.Collection_Activity_Code__c)+':'+String.valueOf(t.id);
            System.debug('************ All Activity : ' + tid  );
            
            string taid = String.valueOf(t.id);
            taskID.add(taid);
        
          }
          
          for(Task t : [SELECT Id,Collection_Activity_DateTime__c,Collection_Activity_Code__c,CreatedDate,Source_Created_Date__c
                     FROM Task WHERE  ID IN :taskID order by Source_Created_Date__c DESC limit 1])
          {
                   
            String dateString = String.valueOf(t.Source_Created_Date__c.month())+'/'+String.valueOf(t.Source_Created_Date__c.day())+'/'+ String.valueOf(t.Source_Created_Date__c.year());
            System.debug('************ last Activity Date : ' + dateString);
            contactDates.add(dateString);
        
          }
   
        System.debug('****************** returned list\'s contents: ' + contactDates);
        return contactDates;

    }



    
}