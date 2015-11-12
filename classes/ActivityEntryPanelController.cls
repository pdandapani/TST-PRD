global with sharing class ActivityEntryPanelController {
    
    public NoteTabWrapper noteTab1Wrapper{get;set;}
    public Id whatIdForNote1Task{get;set;}
    public String firstNoteActivitiesWhereClause{
        get;
        set{
            firstNoteActivitiesWhereClause = value;
            buildNote1Wrapper(false);
        }
    }
    public Boolean pageHasErrorMessages{get;set;}
    
    
    public Financial_Account__c financialAccount{get;set;}
    
    public String errorStringUsedForErrorMessageSetting{get;set;}
    
    public ActivityEntryPanelController() {
        
    }
    
    
    
    private void buildNote1Wrapper(Boolean resetNoteWrapper) {
        if(resetNoteWrapper || noteTab1Wrapper == null) {
            //resetNoteWrapper is used because it appears that the setter is hit multiple times; once before html rerendering and once after, breaking interconnectivity between the vf-component and noteTab1Wrapper  
            noteTab1Wrapper = new NoteTabWrapper('None','');
        }
        
        List<Activity_Code__c> activityCodes = queryActivityCodes(firstNoteActivitiesWhereClause);
        
        noteTab1Wrapper.activityList = buildActivitySelectOptions(activityCodes);
        if(noteTab1Wrapper.activityList.size() == 1) {
            noteTab1Wrapper.selectedActivityCode = noteTab1Wrapper.activityList[0].getValue();
        }
    }
    
    
    private List<Activity_Code__c> queryActivityCodes(String whereClause) {
        List<Activity_Code__c> listToReturn;
        
        String query = 'SELECT Id, Name, Description__c, Collection_Activity_Code__c ';
        query += ' FROM Activity_Code__c ';
        if(firstNoteActivitiesWhereClause != null && firstNoteActivitiesWhereClause.length() > 0) {
            query += ' WHERE ' + firstNoteActivitiesWhereClause;
        }
        query += ' ORDER BY Name ASC';
        
        listToReturn = Database.query(query);
        if(listToReturn == null) {
            listToReturn = new List<Activity_Code__c>();
        }
        
        return listToReturn;
    }
    
    
    private List<SelectOption> buildActivitySelectOptions(List<Activity_Code__c> listOfActivityCodes){
        
        List<SelectOption> unsortedList = new List<SelectOption>();
        List<SelectOption> listToReturn = new List<SelectOption>();
        
        for(Activity_Code__c activityCode: listOfActivityCodes){
            unsortedList.add(new SelectOption(activityCode.Name, activityCode.Name + ' - ' + activityCode.Description__c));
        }
        
        if(unsortedList.size() != 1) {
            listToReturn.add(new SelectOption('None','None')); //NONE needs to be first unless list only has 1 record.
        }
        
        unsortedList.sort();
        listToReturn.addAll(unsortedList); //NONE needs to be first
        return listToReturn;
    }
    
    
    
    public PageReference saveNote1() {
        clearPageRefErrorVar();
        Boolean clearNote = true;
        Activity_code__c selectedCode ;
        String errorMsg;
        if(noteTab1Wrapper.selectedActivityCode == 'None') {
            errorMsg = 'Activity Code required.';
        }else if(noteTab1Wrapper.note == null || noteTab1Wrapper.note == '') {
            errorMsg = 'Note text required.';
        }
        else if(financialAccount == null){
            errorMsg = 'Please select a Financial Account for Case before saving the activity.';
        }
        
        try {
            if(errorMsg == null) {
                selectedCode = selectActivityCodeFromCodeNameValue( noteTab1Wrapper.selectedActivityCode );
                saveNote(noteTab1Wrapper, whatIdForNote1Task, selectedCode);
            }
        }catch(Exception e) {
            errorMsg = e.getMessage();
        }
        
        if(errorMsg != null) {
            appendErrorMessage( errorMsg );
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Record Saved.'));
            
            if(clearNote) {
                List<SelectOption> activityCodes = noteTab1Wrapper.activityList ;
                noteTab1Wrapper = new NoteTabWrapper('None','');
                noteTab1Wrapper.activityList = activityCodes;
                if(noteTab1Wrapper.activityList.size() == 1) {
                    noteTab1Wrapper.selectedActivityCode = noteTab1Wrapper.activityList[0].getValue();
                }
            }
        }
        
        return null;
    }
    
    private Activity_code__c selectActivityCodeFromCodeNameValue(String codeName) {
        Activity_Code__c activityCodeToReturn = [SELECT Id, Name, Description__c, Collection_Activity_Code__c, 
                                                   CTI_Reason__c, CTI_Result__c
                                                 From Activity_Code__c
                                                 WHERE Name = :codeName ];
        
        return activityCodeToReturn;
    }
    
    private void saveNote(NoteTabWrapper noteTabData, String whatId, Activity_code__c selectedCode) {
        
        Task activityNote = new Task(  Description = noteTabData.note,
                                        Collection_Activity_Code__c = selectedCode.Name,
                                        Subject = selectedCode.Name + ' - ' + selectedCode.Description__c,
                                        Status = TFSC_Constants.ACTIVITY_STATUS_COMPLETED,
                                        ActivityDate = Date.today() );
        
        if(whatId != null && whatId.length() > 0) {
            activityNote.WhatId = whatId;
        }
        
        if(financialAccount != null) {
            
            activityNote.Financial_Account__c = financialAccount.Id;
            
            if(financialAccount.Financial_Account_Number__c != null) {
                activityNote.Financial_Account_Number__c = financialAccount.Financial_Account_Number__c ;
            }
        }
        
        insert activityNote;
    }
    
    
    private void clearPageRefErrorVar() {
        //initially i had a pageHasErrorMessages that returned ApexPages.hasMessages();
        //i am, however, alerting the user to successful saves with a page message.
        pageHasErrorMessages = false;
    }
    
    public PageReference setPageErrorMsg() {
        appendErrorMessage(errorStringUsedForErrorMessageSetting);
        return null;
    }
    private void appendErrorMessage(String errorMessage) {
        pageHasErrorMessages = true;
        ApexPages.Message apexPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(apexPageMessage);
    }
    
    
    
    public class NoteTabWrapper {
        
        public List<SelectOption> activityList{get;set;}
        public String selectedActivityCode{get;set;}
        public String note{get;set;}
        
        public NoteTabWrapper(String selectedActivityCode, String note) {
            this.note = note;
            this.selectedActivityCode = selectedActivityCode;
        }
        
    }
    
    
}