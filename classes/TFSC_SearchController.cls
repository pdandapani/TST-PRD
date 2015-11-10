/**    
    * @author  Amanjot Purewal
        * @date 8/25/2015    
        * @description This class handles Custom Search Parameters and methods
     */ 

public with Sharing class TFSC_SearchController{
        public String fANumber{get;set;}
        public String sSN{get;set;}
        public String tIN{get;set;}
        public String fName{get;set;}
        public String lName{get;set;}
        public String busiName{get;set;}
        public String garZip{get;set;}
        public String vINFull{get;set;}
        public String vIN8{get;set;}
        public Integer noOfFAC;
    public Integer getnoOfFAC(){
        return noOfFAC;
    }
    public Integer noOfFA;
    public Integer getnoOfFA(){
        return noOfFA;
    }
    public String oneFAId;
    public String getoneFAId(){
        return oneFAId;
    }
    public String oneFANo;
    public String getoneFANo(){
        return oneFANo;
    }
    private String queryFilter='';
    private Integer resultLimit1 = 10;
    private Integer resultLimit2 = 50;
    public list<Financial_Account_Customer__c> searchedFACs{get;set;} 
    

    public void TFSC_SearchController(){
    searchedFACs = null;
    }
    public void reset(){        
        searchedFACs = null;
    }

// create the dynamic query based on the User input parameters 
public void searchFAC(){
    noOfFAC = -1;
    noOfFA = -1;
    oneFAId ='';
    oneFANo ='';
    
    String queryFilter = '';
    String selectFields = 'SELECT Id, Account__r.FirstName, Account__r.LastName, Account__r.Name, Account__r.IsPersonAccount, Vehicle_Identification_Number__c,Financial_Account__r.Collateral__r.Vehicle_Identification_Number_Last_8_Ch__c,Model_Year__c,Make__c,Model_Name__c,Mailing_Postal_Code_Garage__c,Financial_Account_Number__c,Social_Security_Number__c,Tax_Identification_Number__c,Financial_Account__r.Id,Financial_Account__r.Finance_Account_Status__c FROM Financial_Account_Customer__c';
    String queryOrder = 'Account__r.Name , Mailing_Postal_Code_Garage__c,Financial_Account_Number__c '; // Order By fields
    String queryLimit = '51';//Put the max number of records limit here  
    
    if(TFSC_Utils.isNotNullAndNotEmpty(fANumber)){
    if(fANumber.length() == 10 || fANumber.length() == 11 ){
            queryFilter = queryFilter + ' Financial_Account__r.Financial_Account_Number__c =\''+String.escapeSingleQuotes(fANumber)+'\' AND';
    }else if(fANumber.length() == 20 ){  
    if(fANumber.startsWith('000704') && fANumber.endsWith('0001') )
        {
            fANumber = fANumber.substring(6,16);
        }else if(fANumber.startsWith('0000000000')){            
            fANumber = fANumber.substring(10,12)+'0'+fANumber.substring(12,20);
        }
            queryFilter = queryFilter + ' Financial_Account__r.Financial_Account_Number__c =\''+String.escapeSingleQuotes(fANumber)+'\' AND';
    }
    }    
    if(TFSC_Utils.isNotNullAndNotEmpty(sSN)){
            queryFilter = queryFilter +' Social_Security_Number__c =\''+String.escapeSingleQuotes(sSN)+'\' AND' ;
    }
    if(TFSC_Utils.isNotNullAndNotEmpty(tIN)){
           queryFilter = queryFilter + ' Tax_Identification_Number__c =\''+String.escapeSingleQuotes(tIN)+'\' AND' ;
    }
    if(TFSC_Utils.isNotNullAndNotEmpty(lName)){
        queryFilter = queryFilter + ' Account__r.LastName =\''+String.escapeSingleQuotes(lName)+'\' AND';
    }
    if(TFSC_Utils.isNotNullAndNotEmpty(fName)) {
                queryFilter = queryFilter + ' Account__r.FirstName LIKE \''+String.escapeSingleQuotes(fName)+'%\' AND';
    }
    if(TFSC_Utils.isNotNullAndNotEmpty(garZip)){
            queryFilter = queryFilter + ' Mailing_Postal_Code_Garage__c =\''+String.escapeSingleQuotes(garZip)+'\' AND' ;
    }    
    if(TFSC_Utils.isNotNullAndNotEmpty(busiName)){
            queryFilter = queryFilter + ' Account__r.Name LIKE \''+String.escapeSingleQuotes(busiName)+'%\' AND  Account__r.RecordType.Name =\'Business Account\' AND';       
    }
    if(TFSC_Utils.isNotNullAndNotEmpty(vINFull)){
            queryFilter = queryFilter + ' Vehicle_Identification_Number__c =\''+String.escapeSingleQuotes(vINFull)+'\' AND' ;
    }
    if(TFSC_Utils.isNotNullAndNotEmpty(vIN8)){
            queryFilter = queryFilter +' Financial_Account__r.Collateral__r.Vehicle_Identification_Number_Last_8_Ch__c =\''+String.escapeSingleQuotes(vIN8)+'\' AND' ;
    }    
    if(queryFilter.endsWith('AND')){    
        queryFilter = queryFilter.Substring(0,queryFilter.length()-4);//Remove the last "AND" from query String
    }
    String query = selectFields+' WHERE '+queryFilter+' ORDER BY '+queryOrder+' LIMIT '+queryLimit ;   

try{
    searchedFACs = (List<Financial_Account_Customer__c>)Database.Query(query);
    
    if(searchedFACs != null){       
        noOfFAC = searchedFACs.size();      
        Set <Id> uniqueSearchedFAs = new Set<Id>();
        for(Financial_Account_Customer__c fac : searchedFACs){// Check if search returns a unique FA (there may be multiple FAC but if they all belong to one FA), then auto pop the FA in console
            uniqueSearchedFAs.add(fac.Financial_Account__r.Id);
        }
        if(uniqueSearchedFAs !=null && uniqueSearchedFAs.size() == 1){
            noOfFA = 1; //No of Unique FAs
            oneFAId = searchedFACs.get(0).Financial_Account__r.Id;
                oneFANo  = searchedFACs.get(0).Financial_Account_Number__c;
        }
     }
    if(noOfFAC == 0 ){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Records found for this search Criteria')); 
    }else if(noOfFAC > resultLimit2 ){
    searchedFACs.remove(50);//Remove the last result if more than 50 are returned.
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Your search returned more than 50 results. Not all results are displayed below. Enter additional criteria to refine your search.'));
    }else if(noOfFAC >= resultLimit1 ){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter additional criteria to refine your search.'));
    }
}catch(QueryException se){
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,se.getMessage()));
}
    
} 

}