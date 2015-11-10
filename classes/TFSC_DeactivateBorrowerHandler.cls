public with sharing class TFSC_DeactivateBorrowerHandler implements TFSC_TriggerDispatcher.Handler{

    public class FACException extends Exception{}
         
    
    public void handle() {
        String bulkLoadIndicator;
        
       /* try{
            bulkLoadIndicator = Label.Bulk_Load_In_Progress;
        }*/
         
         try{
          bulkLoadIndicator = Label.Bulk_Load_In_Progress;
                if(UserInfo.GetName().contains('ETL User'))
                {
               // General_Settings__c gs = General_Settings__c.getInstance();
               // if(gs.By_Pass_Trigger_Logic__c)
               
                bulkLoadIndicator ='True';
                }       
            }       
        
        catch(Exception e){
            bulkLoadIndicator = 'false';
        }
        
        if(bulkLoadIndicator.toUpperCase() != 'TRUE'){
            
            System.debug('***** Trigger already executed - ' + TFSC_TriggerContextUtility.hasAlreadyExecuted() + ' *****');
    
            if(!TFSC_TriggerContextUtility.hasAlreadyExecuted()) {
        
                TFSC_TriggerContextUtility.setAlreadyExecuted();
        
                List<Financial_Account_Customer__c> newFACList = (List<Financial_Account_Customer__c>)Trigger.new;
                Map<Id,Financial_Account_Customer__c> oldFACMap = (Map<Id,Financial_Account_Customer__c>)Trigger.oldMap;
        
                List<Financial_Account_Customer__c> FACUpdateList = new List<Financial_Account_Customer__c>();
        
                System.debug('***** Size of newFACList - ' + newFACList.size() + ' *****');
                if(oldFACMap != null)
                    System.debug('***** Size of oldFACMap - ' + oldFACMap.size() + ' *****');
        
                for(Financial_Account_Customer__c modifiedFAC : newFACList) {
                    Financial_Account_Customer__c oldFAC;
                    if(oldFACMap != null) {
                        oldFAC = oldFACMap.get(modifiedFAC.Id);
                    }
            
                    System.debug('***** modified FAC - ' + modifiedFAC + ' *****');

                    if(((oldFAC == null) || (modifiedFAC.Financial_Account_Customer__c != oldFAC.Financial_Account_Customer__c)) && (modifiedFAC.Borrower_Status__c.toUpperCase() == 'ACTIVE')) {
                
                        if(modifiedFAC.Financial_Account__c == null)
                            throw new FACException('Missing Financial Account Number for FAC - ' + modifiedFAC.Financial_Account_Customer__c);
                    
                        List <Financial_Account_Customer__c> activeFACList 
                            = [Select Id, Borrower_Status__c, Financial_Account_Customer__c, FA_Role_Status__c 
                                    from Financial_Account_Customer__c 
                                    where 
                                    Customer_Role_Type__c = :modifiedFAC.Customer_Role_Type__c 
                                    and 
                                    Financial_Account__c = :modifiedFAC.Financial_Account__c 
                                    and 
                                    Borrower_Status__c = 'Active'
                                    and Id != :modifiedFAC.Id
                                    limit 1];

                                                
                        if(activeFACList != null && activeFACList.size() != 0) {
                            Financial_Account_Customer__c activeFAC = activeFACList.get(0);
                            System.debug('***** Existing Active FAC Id - ' + activeFAC.Id + ' *****');
                            activeFAC.Borrower_Status__c = 'Inactive';
                            activeFAC.Financial_Account_Customer__c = (activeFAC.Financial_Account_Customer__c.toUpperCase()).replace('ACTIVE', 'Inactive');
                            activeFAC.FA_Role_Status__c = (activeFAC.FA_Role_Status__c.toUpperCase()).replace('ACTIVE', 'Inactive');
                            FACUpdateList.add(activeFAC);
                        }
                
    
                    }
                }
        
                if(FACUpdateList.size() != 0){
                    System.debug('***** FACUpdateList size is - ' + FACUpdateList.size() + '  *****');
                    update FACUpdateList;       
                    System.debug('***** Updated FACs through trigger successfully *****');
                }              
            }
        }
    }
}