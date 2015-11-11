public with sharing class RL_TakeOwnershipPassThruController {
    
    
    public Boolean sccAndCf{get;set;}
    public Boolean isInConsole{get;set;}
    
    public String previousPage{get;set;}
    
    public Boolean errorsOccuredOnUpdate{get;set;}
    public String nextPage{get;set;}
    public Boolean goToNextPageViaJS{get;set;}
    public Boolean redirExecuted{get;set;}
    
    //note: the cached val will get set when referrer is the standard case page
    private List<String> cachedCaseIdsFromUrlParams;
    private List<String> caseIdsFromUrlParams {
        get {
            if(cachedCaseIdsFromUrlParams == null) {
                cachedCaseIdsFromUrlParams = new List<String>() ;
                Map<String,String> urlParamMap = ApexPages.currentPage().getParameters();
                String urlParamValue;
                String urlParamKey;
                for(Integer i=1; i<1000; i++){
                    //doing 1000 since a) i'm not sure of the UI context, and b) it's the limit for a list in apex.
                    urlParamKey = 'cs' + String.valueOf(i) ;
                    urlParamValue = urlParamMap.get(urlParamKey);
                    if(urlParamValue == null || urlParamValue == '') {
                        break;
                    }else{
                        cachedCaseIdsFromUrlParams.add(urlParamValue);
                    }
                }
            }
            return cachedCaseIdsFromUrlParams;
        }
    }
    
    private Id cachedCurUserId;
    public Id currentUserId {
        get {
            if(cachedCurUserId == null) {
                cachedCurUserId = UserInfo.getUserId();
            }
            return cachedCurUserId;
        }
    }
    
    
    public RL_TakeOwnershipPassThruController(ApexPages.StandardController stdController) {
        errorsOccuredOnUpdate = false;
        
        if(caseIdsFromUrlParams.size() == 0) {
            //try {
                system.debug('***** caseIdsFromUrlParams.size() == 0');
                Map<String,String> urlParamMap = ApexPages.currentPage().getParameters();
                if(urlParamMap.get('Id') != null && urlParamMap.get('Id') != '') {
                    cachedCaseIdsFromUrlParams.add( urlParamMap.get('Id') );
                }
            //}catch(Exception e) {
            
            //}
        }
        
        previousPage = ApexPages.currentPage().getHeaders().get('Referer');
    }
    
    
    
    private void takeOwnershipOfSelectedCases() {
        if(caseIdsFromUrlParams != null && caseIdsFromUrlParams.size() > 0) {
            Map<Id,Case> caseMap = buildCaseMap(caseIdsFromUrlParams);
            Map<Id,Repossession__c> repoMapByCaseId;
            
            if(caseMap.size() == 0) 
            {
                //throw error message
            }
            else if(caseMap.size() == 1) 
            {
                //redirect to single page
                repoMapByCaseId = buildRepoMapByCaseId(caseMap.keySet());
                
                updateCaseOwnersToCurrentUser(caseMap.values(), true);
            }
            else if(caseMap.size() > 1) 
            {
                //probably need to 
                repoMapByCaseId = buildRepoMapByCaseId(caseMap.keySet());
                
                updateCaseOwnersToCurrentUser(caseMap.values(), false);
            }
        }
    }
    
    
    private Boolean cannotUpdateRLCase(Case caseObj, String rt) {
        
        return( (rt == 'Rights Letter' || rt.substring(0,3) == 'RL ') 
                 && (caseObj.status == 'In Progress')
                 && (caseObj.ownerId != currentUserId)
                 && (caseObj.owner.name != 'Rights Letters') );
    }
    
    private void updateCaseOwnersToCurrentUser(List<Case> caseList, Boolean setStatusToInProgress) {
        String errorString;
        String confirmedString;
        String validationString;
        
        List<Case> caseListToUpdate = new List<Case>();
        
        for(Case caseObj1 : caseList) {
            //RL Notice of Sale;  RL Quality Review; Rights Letter
            String rt = caseObj1.RecordType.Name;
            
            if( (rt == 'Rights Letter' || rt.substring(0,3) == 'RL ') && cannotUpdateRLCase(caseObj1, rt) )
            {
                if(validationString == null) {
                    validationString = 'The following records have already been owned and are In Progress: <br />';
                }
                validationString += '<a href="/' + caseObj1.Id + '">' + caseObj1.caseNumber + '</a> <br />';
            }else{
                //ADD TO MAIN UPDATE LIST
                caseListToUpdate.add(caseObj1);
            }
        }
        
        
        if(caseListToUpdate.size() > 0) {
            
            for(Case caseObj : caseListToUpdate) {
                caseObj.ownerId = currentUserId;
                if(setStatusToInProgress && caseObj.status == 'New') {
                    caseObj.status = 'In Progress';
                }
            }
            
            Database.SaveResult[] saveResult = Database.update(caseListToUpdate, false);
            Integer i = 0;
            for(Database.SaveResult result : saveResult) {
                if(!result.isSuccess()) {
                    if(errorString == null) {
                        errorString = 'The following records could not be updated: <br />';
                    }
                    errorString += '<a href="/' + caseListToUpdate[i].Id + '">' + caseListToUpdate[i].caseNumber + '</a> <br />';
                }else{
                    if(confirmedString == null) {
                        confirmedString = 'These records were successful: <br />';
                    }
                    confirmedString += '<a href="/' + caseListToUpdate[i].Id + '">' + caseListToUpdate[i].caseNumber + '</a> <br />';
                }
                
                
                i++;
            }
            
        }//end caseListToUpdate update
        
        
        if(errorString != null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, errorString));
        }
        
        if(validationString != null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, validationString));
        }
        
        if(validationString != null || errorString != null) {
            errorsOccuredOnUpdate = true;
            
            if(confirmedString != null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, confirmedString));
            }
        }
        
    }
    
    
    /**
      *  Using a map since I need to quickly/easily snag both the id list and the case list.
    */
    public Map<Id,Case> buildCaseMap(List<String> idList) {
        Map<Id,Case> casesToReturn = new Map<Id,Case>();
        
        for(Case caseObj : [select id, subject, ownerId, owner.name, status, RecordType.Name, caseNumber 
                            from Case 
                            where id in :idList ])
        {
            casesToReturn.put(caseObj.id, caseObj);
        }
        
        return casesToReturn;
    }
    
    public Map<Id,Repossession__c> buildRepoMapByCaseId(Set<Id> caseIdSet) {
        Map<Id,Repossession__c> reposToReturn = new Map<Id,Repossession__c>();
        
        for(Repossession__c repoObj : [select id, Case__c from Repossession__c where Case__c in :caseIdSet]) {
            reposToReturn.put(repoObj.Case__c, repoObj);
        }
        
        return reposToReturn;
    }
    
    
    
    
    /**
    *
    *  on redirect from console there are 2 main entry points (both of which need to be handled differently from the console and standard ui).
    *  1) clicking take-ownership button on detail page (js needs to handle redirect when in console)
    *  2) clicking take-ownership button on list view
    *       a) if multiple records opened, then simply 'go back' (which is closeTab() if from console search).
    *       b) if single record opened, go to record (would be best to use PageRef, but there is no way to differentiate source -- could do this with some re-work)
    *          thus, javascript needs to be used.  For this case, nextPage is used.
    *
    */
    public PageReference redir() {
        redirExecuted = true;
        goToNextPageViaJS = false;
        takeOwnershipOfSelectedCases();
        
        //primarily used for [2.a] above.
        if(previousPage != null && previousPage != '') {
            nextPage = previousPage;
        }
        
        if(cachedCaseIdsFromUrlParams != null && cachedCaseIdsFromUrlParams.size() == 1) {
            nextPage = '/' + cachedCaseIdsFromUrlParams[0];
            if(!errorsOccuredOnUpdate) {
                goToNextPageViaJS = true;
            }
            if(isInConsole) {
                //nextPage += '?isdtp=vw';
            }
        }
        
        
        if(errorsOccuredOnUpdate) {
            return null;
        }
        
        if(isInConsole) {
            return null;
        }
        
        
        if(nextPage != null) {
        	return new PageReference(nextPage);
        }
        
        return null;
    }
    
    
    
}