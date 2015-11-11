/**
* @author       Mohan Chinnappan     
* @date         05/22/2014
* @description  
*   
*    Plugin for Visual Flow - C&D
*/

global with sharing class FlowSendServiceRequest implements Process.Plugin {


    // The main method to be implemented. The Flow calls this at runtime.   
    // This is the function that the flow call from the class.
    
    global Process.PluginResult invoke(Process.PluginRequest request) {
    
    //perform service requests here
    
    String financialAccountNumber = (String) request.inputParameters.get('vFinanceAccountId');
    
    //Options: ALL 
    String vDNCActionDetails = (String) request.inputParameters.get('vDNCActionDetails');  
    String vAllConsentDetails = (String) request.inputParameters.get('vAllConsentDetails');
    String vActivityCode = (String) request.inputParameters.get('vActivityCode');
    
    String vTaskDesc = (String) request.inputParameters.get('vTaskDesc');
    String vBKFlag = (String) request.inputParameters.get('vBKFlag');
    Decimal vDMNumber = (Decimal) request.inputParameters.get('vDMNumber');
    
    if ('ALL' == vDNCActionDetails ) {
        updateAllPhonesToDNC( financialAccountNumber, true , vAllConsentDetails);
        
        if (vActivityCode == 'PBNK' || vActivityCode == 'DNCL' ) {
            vTaskDesc = vTaskDesc.replace('Attorney Name: ,', '')
            .replace('Address: ,','')
            .replace('Phone: ,', '');
            
             FlowUtil.updateFlagBankruptcy(financialAccountNumber, 'Primary', vBKFlag);
        }
        
        if (vActivityCode == 'PBNK'  ) {
            vTaskDesc = vTaskDesc.replace('BK Status: ,', '')
            .replace('Filing Location: ,','')
            .replace('Filing Date: ,','')
            .replace('Case Number: ,', '')
            .replace('Chapter: ,', '')
            .replace('4,042', '4042')
            .replace('3,428', '3428');
        }
        
        
    } else {
        updateLimitedPhonesToDNC( financialAccountNumber, vAllConsentDetails,  vDNCActionDetails);
        String dncStr =  FlowUtil.getDNCStr(vDNCActionDetails );
        vTaskDesc = vTaskDesc.replace('<phoneList>', dncStr);
    }
    
  
    String financialAccountId = FlowUtil.getFinancialAccountId(financialAccountNumber);
    
  
    FlowUtil.insertActivityCodeInTask(financialAccountNumber,
               financialAccountId,
               vActivityCode,
               FlowUtil.getActivityCodeDesc(vActivityCode), 
               FlowUtil.getCaseId(financialAccountId),
               'Completed',
               vTaskDesc
               ) ;
    
    
    // return to Flow   
     Map<String,Object> result = new Map<String,Object>();  
     result.put('oBKFlag', vBKFlag);
     result.put('oActivityCode', vActivityCode );
     result.put('oTaskDesc', vTaskDesc );
     result.put('oDMNumber', vDMNumber.toPlainString().replace('.0', '') );
     
     return new Process.PluginResult(result);   
    
    }

   // Returns the describe information for the interface   
   // this function describe to the flow which data the plugin need to receive
   global Process.PluginDescribeResult describe()   {
   
      Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
      
      result.Name = 'SendServiceRequest';  
      result.Tag = 'Name';  
        
      result.inputParameters =new List<Process.PluginDescribeResult.InputParameter>();  
       
      result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vFinanceAccountId',  
         Process.PluginDescribeResult.ParameterType.STRING, true));  
      
       result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vDNCActionDetails',  
         Process.PluginDescribeResult.ParameterType.STRING, true));  
         
         
       result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vAllConsentDetails',  
         Process.PluginDescribeResult.ParameterType.STRING, true)); 
         
         
         
        result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vActivityCode',  
         Process.PluginDescribeResult.ParameterType.STRING, true)); 
         
         
         
         result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vTaskDesc',  
         Process.PluginDescribeResult.ParameterType.STRING, true)); 
         
         

              result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vDMNumber',  
         Process.PluginDescribeResult.ParameterType.DECIMAL, true)); 
         
         
            result.inputParameters.add(  
      new Process.PluginDescribeResult.InputParameter('vBKFlag',  
         Process.PluginDescribeResult.ParameterType.STRING, true)); 
     
     
      
      // output
      
       result.outputParameters =new List<Process.PluginDescribeResult.outputParameter>(); 
       
       result.outputParameters.add(  
      new Process.PluginDescribeResult.OutputParameter('oBKFlag',  
         Process.PluginDescribeResult.ParameterType.STRING));  
      
      
      
         result.outputParameters.add(  
      new Process.PluginDescribeResult.OutputParameter('oActivityCode',  
         Process.PluginDescribeResult.ParameterType.STRING));  
         
         
        result.outputParameters.add(  
      new Process.PluginDescribeResult.OutputParameter('oTaskDesc',  
         Process.PluginDescribeResult.ParameterType.STRING));  
         
           result.outputParameters.add(  
      new Process.PluginDescribeResult.OutputParameter('oDMNumber',  
         Process.PluginDescribeResult.ParameterType.STRING));  
       
      
      return result;
   //https://developer.salesforce.com/blogs/developer-relations/2012/03/visual-workflow-converting-leads-with-an-apex-plugin.html
   }
   
   
   /**
     *  
     * @description:
     *     updates DNC and Consent for the limited phones
        
     */
   
   public void updateLimitedPhonesToDNC(String financialAccountNumber, String vAllConsentDetails, String vDNCActionDetails) {
        // {!Overall_ConsentBorrower},{!Overall_ConsentCOB}
        List<String> vAllConsentDetailsRecs = vAllConsentDetails.split(',');
        String overallConsentBorrower = null;
        String overallConsentCOB = null;
        
        Integer loc = 0;
        
        // {!Home_PhoneB},{!Work_PhoneB},{!Mobile_PhoneB},{!Home_Phone_BBilling},{!Work_Phone_BBilling} :
        // {!Home_PhoneCOB},{!Work_PhoneCOB}{!Mobile_PhoneCOB},{!Home_phone_COB_Billing},{!Work_Phone_COB_Billing}
        Map<String,Boolean> valueDNCMapB = null;
        Map<String,Boolean> valueDNCMapCOB = null;
        
        List<String> vDNCActionDetailsRecs = vDNCActionDetails.split(':');
        loc = 0;
        for (String crec : vDNCActionDetailsRecs) {
            if (0 == loc && null != crec) valueDNCMapB = FlowUtil.getDNCMap(crec);
            if (1 == loc && null != crec) valueDNCMapCOB =  FlowUtil.getDNCMap(crec);
            
            loc++;
        }
        
         if (null != valueDNCMapB) {
            updateSelectivePhonesToDNC(financialAccountNumber,'Primary', valueDNCMapB, overallConsentBorrower);
         }
         
         if (null != valueDNCMapCOB) {
            updateSelectivePhonesToDNC(financialAccountNumber,'Co-X', valueDNCMapCOB, overallConsentCOB);
         }
         
   }
   
   /**
     *  
     * @description:
     *      Update all the Phone Flags (Primary and Co-X )
     *      setting valueConsent null will skip updating for  Election_Overall_Consent__c
     */
   
   
   public void updateAllPhonesToDNC(String financialAccountNumber, Boolean valueDNC, String valueConsent) {
    
    
     List<String> faIds = FlowUtil.getFinancialAccountIds(financialAccountNumber);
     for (String faId : faIds) {
        List <Financial_Account_Customer__c>  facs = FlowUtil.getFinancialAccountCustomers (faId);
        for (Financial_Account_Customer__c fac : facs) {
            
            if (null != valueConsent) {
                //if ('No' == valueConsent ) valueConsent ='true';
                
                fac.Election_Overall_Consent__c = valueConsent;
                fac.Election_Payment_Reminder_Day__c = null;
            }
            fac.Flag_Home_Phone_DNC_Garage__c = valueDNC;
            if ( valueDNC ) {
                fac.Flag_Home_Phone_Invalid_Garage__c = false;
            }
            fac.Flag_Work_Phone_DNC_Garage__c = valueDNC;
            if ( valueDNC ) {
                fac.Flag_Work_Phone_Invalid_Garage__c = false;
            }

            fac.Flag_Mobile_Phone_DNC__c = valueDNC;
            if ( valueDNC ) {
                fac.Flag_Mobile_Phone_Invalid__c = false;
            }

            if (fac.Financial_Account__r.RecordType.Name == 'Lease' && fac.Mailing_State_BillTo__c != null) {
                fac.Flag_Work_Phone_DNC_BillTo__c = valueDNC;
                if ( valueDNC ) {
                    fac.Flag_Work_Phone_Invalid_BillTo__c = false;
                }
                fac.Flag_Home_Phone_DNC_BillTo__c = valueDNC;
                if ( valueDNC ) {
                    fac.Flag_Home_Phone_Invalid_BillTo__c = false;
                }
            }

            update fac;
            
        }
     }
     
   }
   
   
   
   /**
     *  
     * @description:
     *      Update selective Phone Flags (given borrowerPosition: Primary or Co-X )
     *      setting valueConsent null (instead of 'No' or 'Yes' will skip updating for  Election_Overall_Consent__c
       Example:
            Map<String,Boolean> valueDNCMap = new Map<String, Boolean>();
            valueDNCMap.put('Flag_Home_Phone_DNC_Garage__c', true);
            valueDNCMap.put('Flag_Home_Phone_DNC_BillTo__c', false);
            valueDNCMap.put('Flag_Work_Phone_DNC_Garage__c', true);
            valueDNCMap.put('Flag_Work_Phone_DNC_BillTo__c', false);
            valueDNCMap.put('Flag_Mobile_Phone_DNC__c', false);

            updateSelectivePhonesToDNC('UF6324','Primary', valueDNCMap, null);
            
     */
   
   
   public void updateSelectivePhonesToDNC(String financialAccountNumber,String borrowerPosition,
                                          Map<String,Boolean> valueDNCMap, String valueConsent) {
     List<String> faIds = FlowUtil.getFinancialAccountIds(financialAccountNumber);
     for (String faId : faIds) {
        List <Financial_Account_Customer__c>  facs = FlowUtil.getFinancialAccountCustomers (faId);
        for (Financial_Account_Customer__c fac : facs) {
            
            if (fac.Borrower_Position__c != borrowerPosition)  continue;
            if (null != valueConsent) {
                fac.Election_Overall_Consent__c = valueConsent;
                fac.Election_Payment_Reminder_Day__c = null;
            }
        
            fac.Flag_Home_Phone_DNC_Garage__c = valueDNCMap.get('Flag_Home_Phone_DNC_Garage__c');
            if ( valueDNCMap.get('Flag_Home_Phone_DNC_Garage__c') ) {
                fac.Flag_Home_Phone_Invalid_Garage__c = false;
            }
            fac.Flag_Work_Phone_DNC_Garage__c = valueDNCMap.get('Flag_Work_Phone_DNC_Garage__c');
            if ( valueDNCMap.get('Flag_Work_Phone_DNC_Garage__c') ) {
                fac.Flag_Work_Phone_Invalid_Garage__c = false;
            }

            fac.Flag_Mobile_Phone_DNC__c = valueDNCMap.get('Flag_Mobile_Phone_DNC__c');
            if ( valueDNCMap.get('Flag_Mobile_Phone_DNC__c') ) {
                fac.Flag_Mobile_Phone_Invalid__c = false;
            }

            if (fac.Financial_Account__r.RecordType.Name == 'Lease' && fac.Mailing_State_BillTo__c != null) {
                fac.Flag_Home_Phone_DNC_BillTo__c = valueDNCMap.get('Flag_Home_Phone_DNC_BillTo__c');
                if ( valueDNCMap.get('Flag_Home_Phone_DNC_BillTo__c') ) {
                    fac.Flag_Home_Phone_Invalid_BillTo__c = false;
                }
                fac.Flag_Work_Phone_DNC_BillTo__c = valueDNCMap.get('Flag_Work_Phone_DNC_BillTo__c');
                if ( valueDNCMap.get('Flag_Work_Phone_DNC_BillTo__c') ) {
                    fac.Flag_Work_Phone_Invalid_BillTo__c = false;
                }
            }
            update fac;
        }
     }
     
   }
}