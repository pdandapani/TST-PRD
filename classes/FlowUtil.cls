/**
* @author       Mohan Chinnappan     
* @date         05/22/2014
* @description  
*   
*    Util class for Visual Flow - C&D
*/
public with sharing class FlowUtil {
    
     /**
     *  
     * @description:
     *      DNC and consent values for the given financialAccountNumber and borrowerPosition
       example: getDNCConsentData('UF6324', 'Primary')
     */

  public static Map<String,Boolean>  getDNCConsentData(String financialAccountNumber, String borrowerPosition )  {
    
      Map<String,Boolean> valueDNCMap = null;
      
      List<String> faIds = getFinancialAccountIds(financialAccountNumber);
      for (String faId : faIds) {
        List <Financial_Account_Customer__c>  facs = getFinancialAccountCustomers (faId);
        for (Financial_Account_Customer__c fac : facs) {
            if (fac.Borrower_Position__c != borrowerPosition)  continue;
            valueDNCMap = new Map<String,Boolean>();
            
            valueDNCMap.put('Flag_Home_Phone_DNC_Garage__c', false);
            valueDNCMap.put('Flag_Home_Phone_DNC_BillTo__c', false);
            valueDNCMap.put('Flag_Work_Phone_DNC_Garage__c', false);
            valueDNCMap.put('Flag_Work_Phone_DNC_BillTo__c', false);
            valueDNCMap.put('Flag_Mobile_Phone_DNC__c', false);
            valueDNCMap.put('Election_Overall_Consent__c', false);
            
            
            valueDNCMap.put('Flag_Home_Phone_DNC_Garage__c', fac.Flag_Home_Phone_DNC_Garage__c  == null ? false : fac.Flag_Home_Phone_DNC_Garage__c );
            valueDNCMap.put('Flag_Home_Phone_DNC_BillTo__c', fac.Flag_Home_Phone_DNC_BillTo__c == null  ? false : fac.Flag_Home_Phone_DNC_BillTo__c );
            valueDNCMap.put('Flag_Work_Phone_DNC_Garage__c', fac.Flag_Work_Phone_DNC_Garage__c == null  ? false : fac.Flag_Work_Phone_DNC_Garage__c);
            valueDNCMap.put('Flag_Work_Phone_DNC_BillTo__c', fac.Flag_Work_Phone_DNC_BillTo__c == null  ? false : fac.Flag_Work_Phone_DNC_BillTo__c );
            valueDNCMap.put('Flag_Mobile_Phone_DNC__c', fac.Flag_Mobile_Phone_DNC__c == null ? false : fac.Flag_Mobile_Phone_DNC__c );
            valueDNCMap.put('Election_Overall_Consent__c', fac.Election_Overall_Consent__c == null ? false : Boolean.valueOf(fac.Election_Overall_Consent__c) );
            
             
        }   
                
     }
     return valueDNCMap;
  }
   
     /**
     *  
     * @description:
     *      Get list of FinancialAccountIds for the given FinancialAccountNumber
       example: getFinancialAccountIds('UF6324')
     */
   
   public static List<String> getFinancialAccountIds (String financialAccountNumber ) {
    
        List<Financial_Account__c> fas =  [
            SELECT id, Financial_Account_Number__c
              FROM 
                Financial_Account__c
              WHERE
                 Financial_Account_Number__c = :financialAccountNumber
        ];
        
        List<String> ids = new List<String>();
        for (Financial_Account__c fa: fas) {
            ids.add(fa.id);
        }
        
        return ids;
 
   }
   
   
    /**
     *  
     * @description:
     *      the first FinancialAccountId for the given FinancialAccountNumber
       example: getFinancialAccountId('UF6324')
     */
   
   public static String getFinancialAccountId(String financialAccountNumber) {
        Financial_Account__c fa =  [
            SELECT id, Financial_Account_Number__c
              FROM 
                Financial_Account__c
              WHERE
                 Financial_Account_Number__c = :financialAccountNumber
              LIMIT 1
        ];
        
        return fa.Id;
   }
   
   
     /**
     *  
     * @description:
     *      Get list of FinancialAccountCustomers for the given FinancialAccountId
     */
   
   
   public static List <Financial_Account_Customer__c>  getFinancialAccountCustomers (String financialAccountId ) {
 
    List <Financial_Account_Customer__c> facs  = [
        SELECT 
               id
               ,Financial_Account_Customer__c 
               ,Borrower_Position__c
               ,Financial_Account__c
               ,Financial_Account__r.RecordType.Name
               ,Mailing_State_BillTo__c

               ,Work_Phone_No_Call_Reason_Code_Bill_To__c
               ,Home_Phone_No_Call_Reason_Code_BillTo__c
               ,Mobile_Phone_No_Call_Reason_Code__c

               ,Election_Overall_Consent__c
               ,Election_Payment_Reminder_Day__c

               ,Flag_Home_Phone_DNC_Garage__c
               ,Flag_Home_Phone_Invalid_Garage__c
               ,Flag_Home_Phone_DNC_BillTo__c
               ,Flag_Home_Phone_Invalid_BillTo__c

               ,Flag_Work_Phone_DNC_Garage__c
               ,Flag_Work_Phone_Invalid_Garage__c
               ,Flag_Work_Phone_DNC_BillTo__c
               ,Flag_Work_Phone_Invalid_BillTo__c

               ,Flag_Mobile_Phone_DNC__c
               ,Flag_Mobile_Phone_Invalid__c

               ,Flag_Bankruptcy__c
           FROM
             Financial_Account_Customer__c

           WHERE
             Financial_Account__c = :financialAccountId AND 
             Borrower_Position__c IN ('Primary','Co-X') AND 
             Borrower_Status__c = 'Active'
    ];
    
    return facs;
   }
   
   
   /**
     *  
     * @description:
     *      getFlagBankruptcy for : Primary or Co-X )
     *      setting valueConsent null (instead of 'No' or 'Yes' will skip updating for  Election_Overall_Consent__c
       Example:
         getFlagBankruptcy('UF6324','Primary')
            
     */
   
   public static String getFlagBankruptcy(String financialAccountId,String borrowerPosition) {                                       
        List <Financial_Account_Customer__c>  facs = getFinancialAccountCustomers (financialAccountId);
        if (facs != null) {
            for (Financial_Account_Customer__c fac : facs) {
                if (fac.Borrower_Position__c != borrowerPosition)  continue;
                return fac.Flag_Bankruptcy__c;
            }
        }

     return null;
     
   }
   /**
     *  
     * @description:
     *      updateFlagBankruptcy for : Primary or Co-X )
     *       
   */
            
   
   
    public static void updateFlagBankruptcy(String financialAccountNumber,String borrowerPosition, String bkValue) {                                       
     List<String> faIds = getFinancialAccountIds(financialAccountNumber);
     for (String faId : faIds) {
        List <Financial_Account_Customer__c>  facs = getFinancialAccountCustomers (faId);
        for (Financial_Account_Customer__c fac : facs) {
            if (fac.Borrower_Position__c == borrowerPosition) {
                fac.Flag_Bankruptcy__c = bkValue;
                update fac;
            }
        }
     }
     
     
   }
   
     /**
     *  
     * @description:
     *     Send email to given emailAddress with subject and body
       example: sendEmail('mchinnappan@salesforce.com', 'SUBJECT', 'BODY of the email');
     */
   
   public static void sendEmail(String emailAddress, String subject, String body)  {
         
      System.Debug('test');
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
       
      mail.setToAddresses(new String[] {emailAddress});  
      mail.setSubject(subject);  
      mail.setPlainTextBody(body);  
        
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
   }  
   
   
   
   
    /**
     *  
     * @description:
     *      get description for the given activity code
        Example: getActivityCodeDesc('DNC1');
        
             
     */
   
   
    public static String getActivityCodeDesc(String activityCode) {
        String description = null;
        
        List<Activity_Code__c> acs = [
          SELECT Name , Description__c 
           FROM 
                Activity_Code__c
          WHERE 
               Name =:activityCode       
        
        ];
        
        
        
         for (Activity_Code__c ac: acs) {
           description =+ ac.Name + ' - ' + ac.Description__c;
         }
         return description;
    }


   /**
     *  
     * @description:
     *      gets the caseId for the given financialAccountId
     *       
        Example: getCaseId('a03S00000030rb5IAA');
        
             
     */

public static String getCaseId(String financialAccountId) {

    List<Case> caseRec = [
    
       SELECT Id, isClosed , Financial_Account__c, RecordType.Name
         FROM 
         case
        WHERE
           RecordType.Name = 'Collection'  
             AND
           Financial_Account__c = :financialAccountId
             AND
           IsClosed = false
            
          LIMIT 1
    ];
    
    if (caseRec.size() == 1) return caseRec[0].Id;
    else  return null; //TODO: CHECK THIS
    

}


 /**
     *  
     * @description:
     *     prepares DNC Map for the given input String
        
     */  
   
   public static  Map<String, Boolean> getDNCMap(String input) {
      List<String> recs = input.split(',');
      
        // {!Home_PhoneB},{!Work_PhoneB},{!Mobile_PhoneB},{!Home_Phone_BBilling},{!Work_Phone_BBilling} :
        // {!Home_PhoneCOB},{!Work_PhoneCOB}{!Mobile_PhoneCOB},{!Home_phone_COB_Billing},{!Work_Phone_COB_Billing}
        Map<String,Boolean> valueDNCMap = new Map<String, Boolean>();
        valueDNCMap.put('Flag_Home_Phone_DNC_Garage__c', false);
        valueDNCMap.put('Flag_Home_Phone_DNC_BillTo__c', false);
        valueDNCMap.put('Flag_Work_Phone_DNC_Garage__c', false);
        valueDNCMap.put('Flag_Work_Phone_DNC_BillTo__c', false);
        valueDNCMap.put('Flag_Mobile_Phone_DNC__c', false);
        
      Integer loc = 0;
      for (String rec: recs) {
        if (0 == loc && null != rec && 'true' == rec) {
            valueDNCMap.put('Flag_Home_Phone_DNC_Garage__c', true);
        }
        if (1 == loc && null != rec && 'true' == rec) {
            valueDNCMap.put('Flag_Work_Phone_DNC_Garage__c', true);
        }
        if (2 == loc && null != rec && 'true' == rec) {
            valueDNCMap.put('Flag_Mobile_Phone_DNC__c', true);
        }
        if (3 == loc && null != rec && 'true' == rec) {
            valueDNCMap.put('Flag_Home_Phone_DNC_BillTo__c', true);
        }
        if (4 == loc && null != rec && 'true' == rec) {
            valueDNCMap.put('Flag_Work_Phone_DNC_BillTo__c', true);
        }
        loc++;
      }
      
      return valueDNCMap;
   }

   /**
     *  
     * @description:
     *     returns the DNC String for Task.Description update
     *       
        
        
             
     */




public static String getDNCStr(String vDNCActionDetails ) {
    
        Map<String,Boolean> valueDNCMapB = null;
        Map<String,Boolean> valueDNCMapCOB = null;
         
        List<String> vDNCActionDetailsRecs = vDNCActionDetails.split(':');
        Integer loc = 0;
        for (String crec : vDNCActionDetailsRecs) {
            if (0 == loc && null != crec) valueDNCMapB = getDNCMap(crec);
            if (1 == loc && null != crec) valueDNCMapCOB =  getDNCMap(crec);
            
            loc++;
        }
        
        String dncStr = '';
        if ( valueDNCMapB.get('Flag_Home_Phone_DNC_Garage__c') ) dncStr += 'CS-G-Home, ';
        if ( valueDNCMapB.get('Flag_Work_Phone_DNC_Garage__c') ) dncStr += 'CS-G-Work, ';
        if ( valueDNCMapB.get('Flag_Mobile_Phone_DNC__c') ) dncStr += 'CS-G-Cell, ';
        if ( valueDNCMapB.get('Flag_Home_Phone_DNC_BillTo__c') ) dncStr += 'CS-B-Home, ';
        if ( valueDNCMapB.get('Flag_Work_Phone_DNC_BillTo__c') ) dncStr += 'CS-B-Work, ';
        
        
        if ( valueDNCMapCOB.get('Flag_Home_Phone_DNC_Garage__c') ) dncStr += 'CX-G-Home,' ;
        if ( valueDNCMapCOB.get('Flag_Work_Phone_DNC_Garage__c') ) dncStr += 'CX-G-Work, ';
        if ( valueDNCMapCOB.get('Flag_Mobile_Phone_DNC__c') ) dncStr += 'CX-G-Cell, ';
        if ( valueDNCMapCOB.get('Flag_Home_Phone_DNC_BillTo__c') ) dncStr += 'CX-B-Home, ';
        if ( valueDNCMapCOB.get('Flag_Work_Phone_DNC_BillTo__c') ) dncStr += 'CX-B-Work, ';
        
        return dncStr;
}


   
   /**
     *  
     * @description:
     *      inserts the given activityCode   for the given FinancialAccountNumber
     *      setting valueConsent null will skip updating for  Election_Overall_Consent__c
        Example: 
        
             
     */
   public static void insertActivityCodeInTask(String financialAccountNumber, String financialAccountId,
               String activityCode, String codeDescription, String whatId,
               String statusStr, String taskDesc) {
    
    
    /*
    Task.Subject = CODE - Code Description (from Activity_Code__c.Name & " - " & Activity_Code__c.Description__c)
    Task.WhatId = Id from Case where RecordType.Name = 'Collection' and Financial_Account__c = current FA Id and IsClosed = False limit 1
    Task.Collection_Activity_Code__c = selected Activity Code
    Task.Financial_Account__c = current FA Id
    Task.Financial_Account_Number__c = current FA #
    Task.Status = 'Completed'
    Task.ActivityDate = current date
    
    
    Result:
    
    2:55.344 (344344099)|USER_DEBUG|[11]|DEBUG|Task:
     {
       Status=Completed, 
       Financial_Account_Number__c=UF6324, 
       WhatId=500S0000004LUKWIA4, 
       Subject=PBNK - PENDING BANKRUPTCY,
       Id=00TS000000Od46WMAR, 
       Collection_Activity_Code__c=PBNK, 
       Financial_Account__c=a03S00000030rb5IAA, 
       ActivityDate=2014-05-26 00:00:00
      }
      
      

   */ 
   
   if (null == whatId) {
    Task newTask = new Task(
                  //Subject = activityCode + ' - '  + codeDescription,
                  Subject =  codeDescription,
                  //WhatId = whatId,
                  Financial_Account__c = financialAccountId,
                  Financial_Account_Number__c = financialAccountNumber,
                  Status = statusStr,
                  Collection_Activity_Code__c = activityCode,
                  Description = taskDesc,
                  ActivityDate = Date.today()
             );
     insert newTask;
   } else {
    Task newTask = new Task(
                  //Subject = activityCode + ' - '  + codeDescription,
                  Subject =  codeDescription,
                  WhatId = whatId,
                  Financial_Account__c = financialAccountId,
                  Financial_Account_Number__c = financialAccountNumber,
                  Status = statusStr,
                  Collection_Activity_Code__c = activityCode,
                  Description = taskDesc,
                  ActivityDate = Date.today()
             );
     insert newTask;
    
   }
    
   }
   
   
   

}