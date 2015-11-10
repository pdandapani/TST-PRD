public without sharing class RL_ConsoleMessengerController {
	
	
	//pushTopic
	public String topicString{get;set;}
	
	public String selectedMessageId{get;set;}
	public String selectedMessageText{get;set;}
	public List<System_Message__c> recentMessages{get;set;}
	
	private Id cachedCurUserId;
    public Id currentUserId {
        get {
            if(cachedCurUserId == null) {
                cachedCurUserId = UserInfo.getUserId();
            }
            return cachedCurUserId;
        }
    }
    
    
	
	public RL_ConsoleMessengerController() {
		//populateRecentMessages();
	}
	
	
	public PageReference getMessageText() {
		
		System_Message__c msg = [select id, Description__c from System_Message__c where id = :selectedMessageId limit 1];
		selectedMessageText = msg.Description__c;
		return null;
	}
	
	public PageReference initVars() {
		selectOrGeneratePushTopicAndPopulateTopicString();
		return null;
	}
	
	
	private void selectOrGeneratePushTopicAndPopulateTopicString() {
		PushTopic pt;
		String tmpName = getNameForQuery();
		try{
			pt = [select id, Name from PushTopic where Name = :tmpName limit 1];
			//pt = [select id, Name from PushTopic where Name = 'DocRequestAllUsers' limit 1];
		}catch(Exception e){
		}
		
		if(pt == null) {
			pt = generateAndInsertPushTopic();
		}
		
		topicString = '/topic/' + pt.Name;
	}
	
	
	private String getNameForQuery() {
		String name = 'DocR_' + currentUserId;
		name = name.substring(0,20);
		return name;
	}
	private PushTopic generateAndInsertPushTopic() {
		PushTopic pt = new PushTopic();
		pt.ApiVersion = 31.0;
		pt.Name = getNameForQuery();
		pt.Description = 'Doc Request status updates for user ' + UserInfo.getName();
		pt.Query = getPushTopicQuery(currentUserId);
		pt.NotifyForOperationUpdate = false;
		pt.NotifyForOperationUndelete = false;
		pt.NotifyForOperationDelete = false;
		pt.NotifyForOperationCreate = true; 
		insert pt;
		return pt;
	}
	
	
	private String getPushTopicQuery(String ownerId) {
		String strToReturn = 'SELECT Id, OwnerId, Notify_User__c, Source__c, Title__c, Type__c ';
		strToReturn += 'from System_Message__c where ownerId = \'' + ownerId + '\'' ;
		//no Description__c -- long textarea not supported
		return strToReturn; 
	}
	
	
	

}