/**
*   Modified By : Paras Dhingra
*   Modified Date : 7/6/2015
*   Story : S-311850
*   Description : To update the Service type based on the values from tempInteractionType custom setting on case creation.
*/
global with sharing class TFSC_ConsoleManagerController {
    
    
    
    public TFSC_ConsoleManagerController() {
        
    }
    
    @RemoteAction
    global static String getObjectIdFromAccountNumber(String accountNum) {
        String strToReturn;
        
        if(accountNum != null && accountNum.length() > 0) {
            for(Financial_Account__c fac : [select id from Financial_Account__c 
                                              where Financial_Account_Number__c = :accountNum 
                                              limit 1]) 
            {
                strToReturn = fac.Id;
            }
        }
        
        return strToReturn;
    }
    
    @RemoteAction
    global static List<TFSC_ConsoleManagerController.FaObject> getFaObjectsFromFaIdList(List<String> idList) {
        List<TFSC_ConsoleManagerController.FaObject> listToReturn = new List<TFSC_ConsoleManagerController.FaObject>();
        for(Financial_Account__c fa : [select id, Financial_Account_Number__c,
                                           (
                                               select Financial_Account_Customer__c.id, 
                                               Financial_Account_Customer__c.Work_Phone_Garage__c,
                                               Financial_Account_Customer__c.Mobile_Phone__c, 
                                               Financial_Account_Customer__c.Home_Phone_Garage__c,
                                               Financial_Account_Customer__c.Work_Phone_Bill_To__c,
                                               Financial_Account_Customer__c.HomePhone_BillTo__c
                                               from Financial_Account__c.Financial_Account_Customers__r
                                            ),
                                            (
                                               select id, 
                                               Phone1__c, Phone10__c, Phone11__c, Phone12__c, Phone13__c, Phone14__c, 
                                               Phone15__c, Phone16__c, Phone17__c, Phone18__c, Phone19__c, Phone2__c, 
                                               Phone20__c, Phone21__c, Phone22__c, Phone23__c, Phone24__c, Phone25__c, 
                                               Phone26__c, Phone27__c, Phone28__c, Phone29__c, Phone3__c, Phone30__c, 
                                               Phone31__c, Phone32__c, Phone33__c, Phone34__c, Phone35__c, Phone36__c, 
                                               Phone37__c, Phone38__c, Phone39__c, Phone4__c, Phone40__c, Phone41__c, 
                                               Phone42__c, Phone43__c, Phone44__c, Phone45__c, Phone46__c, Phone47__c, 
                                               Phone48__c, Phone49__c, Phone5__c, Phone50__c, Phone6__c, Phone7__c, 
                                               Phone8__c, Phone9__c
                                               from Financial_Account__c.Skip_Trace__r
                                            )
                                         from Financial_Account__c
                                         where id in :idList
                                         limit 1000]) 
        {
            TFSC_ConsoleManagerController.FaObject faObj = new TFSC_ConsoleManagerController.FaObject();
            faObj.faId = fa.Id;
            faObj.faAcctNum = fa.Financial_Account_Number__c ;
            for(Financial_Account_Customer__c fac : fa.Financial_Account_Customers__r) {
                if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Garage__c) ){
                    faObj.facPhoneList.add( fac.Work_Phone_Garage__c.replaceAll('[^0-9]','') );
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Mobile_Phone__c) ){
                    faObj.facPhoneList.add( fac.Mobile_Phone__c.replaceAll('[^0-9]','') );
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Home_Phone_Garage__c) ){
                    faObj.facPhoneList.add( fac.Home_Phone_Garage__c.replaceAll('[^0-9]','') );
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.HomePhone_BillTo__c) ){
                    faObj.facPhoneList.add( fac.HomePhone_BillTo__c.replaceAll('[^0-9]','') );
                }
                if( !TFSC_Utils.isNullOrEmpty(fac.Work_Phone_Bill_To__c) ){
                    faObj.facPhoneList.add( fac.Work_Phone_Bill_To__c.replaceAll('[^0-9]','') );
                }
                
            }
            for(Skip_Trace__c skipTrace : fa.Skip_Trace__r) {
                for(Integer i=1; i<51; i++){
                    String phoneField = 'Phone' + String.valueOf(i) + '__c'; 
                    String skipPhoneNum = (String)skipTrace.get(phoneField);
                    if(skipPhoneNum != null && skipPhoneNum.length() > 0) {
                        skipPhoneNum = skipPhoneNum.replaceAll('[^0-9]','');
                        if(skipPhoneNum.length() > 0) {
                            faObj.facPhoneList.add(skipPhoneNum);
                        }
                    }
                }
            }
            listToReturn.add( faObj );
        }
        
        return listToReturn;
    }
    // Created for Story S-311850 #start By paras Dhingra 7/6/2015
    @RemoteAction
    global static void setInteractionType(String Id, String iType){ // Set unique Custom setting for the interaction type. 
        if( Id !=null && iType!=null){
            list<tempinteraction__c> interactionlist = [SELECT Name, Interaction_Type__c FROM tempinteraction__c WHERE Name = :Id LIMIT 1];
            if(interactionlist.size() != 0){
                interactionlist[0].Interaction_Type__c = iType;
                update interactionlist[0];
            }else{
                tempinteraction__c interaction  = new tempinteraction__c(name = id, Interaction_Type__c = iType);
                insert interaction;
            }            
        }

    }
    // Remote action to delete the interactiontype when the FA tab is closed
    @RemoteAction
    global static void deleteInteractionType(String id){
        if( Id !=null){
            list<tempinteraction__c> interactionlist = [SELECT Name, Interaction_Type__c FROM tempinteraction__c WHERE Name = :Id LIMIT 1];
            if(interactionlist.size() != 0){
                try{
                    delete interactionlist[0]; // Delete the interactionType once the scope of FA dies
                    }catch(Exception e){

                }
                
            }
        }
    }
    // Story S-311850 #End
    global class FaObject{
        
        public String faId{get;set;}
        public String faAcctNum{get;set;}
        public List<String> facPhoneList{get;set;}
        
        public FaObject() {
            facPhoneList = new List<String>();
        }
        
    }
    
}