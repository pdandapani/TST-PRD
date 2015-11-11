public class TFSC_CureNoteInfoController {

    private final Financial_Account__c fa;
    private String taskDescription = '';
    public static String cureNoticeSent = 'cure notice sent';
    
    public TFSC_CureNoteInfoController(ApexPages.StandardController stdController) {
        this.fa = (Financial_Account__c)stdController.getRecord();
        lookupNote();
    }
    
    public String getCureAmount(){
        String cureAmt = '';
        
        try{
           cureAmt = parseCureAmount(); 
        }
        catch(Exception e){
           System.debug('**************** An error occurred when parsing the cure amount: ' + e.getMessage());
           cureAmt = '';
        }
        
        return cureAmt;
    }
    
    public String getCureExpDate(){
        String cureExpDt = '';
        
        try{
           cureExpDt = parseCureExpDate();
        }
        catch(Exception e){
           System.debug('***************** An error occurred when parsing the cure expiration date: ' + e.getMessage());
           cureExpDt = '';
        }
        return cureExpDt;
    }
    
    public String getCureNote(){
        String note = taskDescription;
        
        return note;
    }
    
    
    private void lookupNote(){
        String description = '';
        
        try {
            description = [SELECT Description 
                                  FROM Task 
                                  WHERE WhatId = :fa.Id 
                                  AND Collection_Activity_Code__c = 'CURE' 
                                  ORDER BY Collection_Activity_DateTime__c DESC LIMIT 1].Description;
    
            if(String.isBlank(description)){
                description = '';
            }
        }catch(Exception e) {
            System.debug('*************** An error occurred when querying the most recent cure note: ' + e.getMessage());
            description = '';
        }
            
        
        taskDescription = description;
    }
    
    
    private String parseCureAmount(){
        String amount = '';
        
        if(!String.isBlank(taskDescription)){
            String tempDesc = taskDescription;
            
            if(tempDesc.toLowerCase().contains(cureNoticeSent) && tempDesc.toLowerCase().contains('$')){
                
                //get the dollar amount index to be used later
                Integer dollarStart = tempDesc.indexOf('$');
                
                //get the cent amount start index to be used later
                Integer centStart = tempDesc.indexOf('.',dollarStart);
                
                if(centStart >= 0){
                    
                    //parse the full amount using the returned indices (dollarStart, (centStart - dollarStart + 3))
                    Integer len = centStart - dollarStart + 3;
                    amount = tempDesc.mid(dollarStart, len);
                    
                }
                
            }
            
        }
        
        if(String.isBlank(amount)){
            amount = '';
        }
        
        return amount;
    }
    
    
    private String parseCureExpDate(){
        String expDt = '';
        String expires = 'expires';
        
        if(!String.isBlank(taskDescription)){
            String tempDescFull = taskDescription;
            String tempDesc = tempDescFull.replaceAll('\\s+',' ');
            
            if(tempDesc.containsIgnoreCase(cureNoticeSent) && tempDesc.containsIgnoreCase(expires) && tempDesc.toLowerCase().indexOf(expires) >= 0){
                
                //Determine the starting point for the expiration date
                Integer expStart = tempDesc.toLowerCase().indexOf(expires) + expires.length() + 1;
                
                //parse out the date; the date is in a MMDDYY format
                Integer month = Integer.valueOf(tempDesc.substring(expStart, (expStart + 2)));
                Integer day = Integer.valueOf(tempDesc.substring((expStart + 2), (expStart + 4)));
                Integer year = 2000 + Integer.valueOf(tempDesc.substring((expStart + 4), (expStart + 6)));
                Date tempDt = Date.newInstance(year, month, day);
                
                //set the date to a string
                expDt = tempDt.format();
                
            }
            
        }
        
        if(String.isBlank(expDt)){
            expDt = '';
        }
        
        return expDt;
        
    }
    
    
}