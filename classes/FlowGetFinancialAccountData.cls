/**
* @author       Mohan Chinnappan     
* @date         05/23/2014
* @description  
*   
*    Class to support reading Financial Account Data for Visual Flow - C&D
*/

global with sharing class FlowGetFinancialAccountData implements Process.Plugin {
    
    global Process.PluginResult invoke(Process.PluginRequest request) {
    
    //perform service requests here
    
    String financialAccountNumber = (String) request.inputParameters.get('vFinanceAccountId');
    Map<String,Object> result = new Map<String,Object>();  

    List<String> faIds = FlowUtil.getFinancialAccountIds(financialAccountNumber);
    
    result.put('oValidAccountNumber',false);
    result.put('oNumAccounts', 0);
    
    
    if (faIds != null) {
        if (faIds.size() == 1) {
           
            result.put('oValidAccountNumber',true);
            
            String bkStatus =  FlowUtil.getFlagBankruptcy(faIds.get(0),'Primary');
            if (null != bkStatus)  result.put('oBKFlag', bkStatus);
            else result.put('oBKFlag', '');             
             
            List <Financial_Account_Customer__c>  facs = FlowUtil.getFinancialAccountCustomers((String) faIds.get(0));
            if (facs != null) {
                result.put('oNumAccounts',facs.size());
                 
                if (facs.size() == 2) {
                 
                 
                     Map<String,Boolean> valueDNCMapB = FlowUtil.getDNCConsentData(financialAccountNumber, 'Primary' );
                     result.put('oFlag_Home_Phone_DNC_Garage_B', valueDNCMapB.get('Flag_Home_Phone_DNC_Garage__c'));
                     result.put('oFlag_Home_Phone_DNC_BillTo_B', valueDNCMapB.get('Flag_Home_Phone_DNC_BillTo__c'));
                     result.put('oFlag_Work_Phone_DNC_Garage_B', valueDNCMapB.get('Flag_Work_Phone_DNC_Garage__c'));
                     result.put('oFlag_Work_Phone_DNC_BillTo_B', valueDNCMapB.get('Flag_Work_Phone_DNC_BillTo__c')); 
                     result.put('oFlag_Mobile_Phone_DNC_B', valueDNCMapB.get('Flag_Mobile_Phone_DNC__c'));
                     //result.put('oElection_Overall_Consent_B', valueDNCMapB.get('Election_Overall_Consent__c'));
                            
                     
                     Map<String,Boolean> valueDNCMapCB = FlowUtil.getDNCConsentData(financialAccountNumber, 'Co-X' );
                     result.put('oFlag_Home_Phone_DNC_Garage_CB', valueDNCMapCB.get('Flag_Home_Phone_DNC_Garage__c'));
                     result.put('oFlag_Home_Phone_DNC_BillTo_CB', valueDNCMapCB.get('Flag_Home_Phone_DNC_BillTo__c'));
                     result.put('oFlag_Work_Phone_DNC_Garage_CB', valueDNCMapCB.get('Flag_Work_Phone_DNC_Garage__c'));
                     result.put('oFlag_Work_Phone_DNC_BillTo_CB', valueDNCMapCB.get('Flag_Work_Phone_DNC_BillTo__c')); 
                     result.put('oFlag_Mobile_Phone_DNC_CB', valueDNCMapCB.get('Flag_Mobile_Phone_DNC__c'));
                     //result.put('oElection_Overall_Consent_CB', valueDNCMapCB.get('Election_Overall_Consent__c'));
             
                }
                 
                if (facs.size() == 1) {
                    
                    
                     Map<String,Boolean> valueDNCMapB = FlowUtil.getDNCConsentData(financialAccountNumber, 'Primary' );
                     result.put('oFlag_Home_Phone_DNC_Garage_B', valueDNCMapB.get('Flag_Home_Phone_DNC_Garage__c'));
                     result.put('oFlag_Home_Phone_DNC_BillTo_B', valueDNCMapB.get('Flag_Home_Phone_DNC_BillTo__c'));
                     result.put('oFlag_Work_Phone_DNC_Garage_B', valueDNCMapB.get('Flag_Work_Phone_DNC_Garage__c'));
                     result.put('oFlag_Work_Phone_DNC_BillTo_B', valueDNCMapB.get('Flag_Work_Phone_DNC_BillTo__c')); 
                     result.put('oFlag_Mobile_Phone_DNC_B', valueDNCMapB.get('Flag_Mobile_Phone_DNC__c'));
                     //result.put('oElection_Overall_Consent_B', valueDNCMapB.get('Election_Overall_Consent__c'));
                            
                }
            }
             
        }
    }
     
     
     return new Process.PluginResult(result);   
    
    }

   // Returns the describe information for the interface   
   // this function describe to the flow which data the plugin need to receive
   global Process.PluginDescribeResult describe()   {
   
      Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
      
      result.Name = 'FlowGetFinancialAccountData';  
      result.Tag = 'Name';  
        
      result.inputParameters =new List<Process.PluginDescribeResult.InputParameter>();  
       
      result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vFinanceAccountId',  
         Process.PluginDescribeResult.ParameterType.STRING, true));  
         
     
      // output
      
       result.outputParameters = new List<Process.PluginDescribeResult.outputParameter>(); 
       
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oValidAccountNumber', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
      
      
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oNumAccounts', Process.PluginDescribeResult.ParameterType.INTEGER));  
     
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oBKFlag', Process.PluginDescribeResult.ParameterType.STRING)); 
       
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Home_Phone_DNC_Garage_B', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Home_Phone_DNC_BillTo_B', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Work_Phone_DNC_Garage_B', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Work_Phone_DNC_BillTo_B', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Mobile_Phone_DNC_B', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oElection_Overall_Consent_B', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       
       
       
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Home_Phone_DNC_Garage_CB', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Home_Phone_DNC_BillTo_CB', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Work_Phone_DNC_Garage_CB', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Work_Phone_DNC_BillTo_CB', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oFlag_Mobile_Phone_DNC_CB', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       result.outputParameters.add( new Process.PluginDescribeResult.OutputParameter('oElection_Overall_Consent_CB', Process.PluginDescribeResult.ParameterType.BOOLEAN));  
       
       
     
      return result;
 
   }
   
  
  
   
   
  }