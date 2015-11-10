public without sharing class TFSC_CaseCommentHandler implements TFSC_TriggerDispatcher.Handler {
	
	static final String PIPE = ' | ';
	static final String DDC = 'DDC ';
	//2000 STARS max size - 8 digit Case Number - PIPE - DDC XX - PIPE
	static final Integer PIVOT = 2000 - 8 - PIPE.length() - 6 - PIPE.length();

	public void handle() {	
		updateParentCase();
	}

	//this method will perform an empty update call on the parent comment
	//in order to update the parent's LastModifiedDate
	private void updateParentCase() {

		Map<Id,Case> casesMap = new Map<Id,Case>{};
		for (CaseComment item : (List<CaseComment>)trigger.new) {
			if (item.IsPublished) {
				casesMap.put(item.ParentId, null);
			}
		}

		for(Case c : [
			select Id, CaseNumber, Requested_Due_Date_Day_of_Month__c, RecordTypeId
			from Case 
			where Id in :casesMap.keySet()
		]) {
			casesMap.put(c.Id, c);
		}

		Map<Id,Case> cases = new Map<Id,Case>{};
		Map<Id,String> extras = new Map<Id,String>{};
		for (CaseComment item : (List<CaseComment>)trigger.new) {
			if (item.IsPublished) {
				Case parentCase = casesMap.get(item.ParentId);
				String caseNumber = parentCase.CaseNumber;
				String reqDDC = parentCase.Requested_Due_Date_Day_of_Month__c;
				if (reqDDC == null) {
					reqDDC = '00';
				}
				while (reqDDC.length() < 2) {
					reqDDC = '0' + reqDDC;
				}
				Case newCase = new Case(Id = item.ParentId);
				if (item.CommentBody.length() <= PIVOT) {
					newCase.Last_Comment__c = buildCaseCommentFragment(caseNumber, reqDDC, item.CommentBody);
				}
				else {
					newCase.Last_Comment__c = buildCaseCommentFragment(caseNumber, reqDDC,item.CommentBody.substring(0, PIVOT));
					extras.put(item.ParentId, item.CommentBody.substring(PIVOT));
				}

				cases.put(item.ParentId, newCase);
			}
		}

		if (!cases.isEmpty()) {
			update cases.values();
		}

		//if there were comments with excess size, do one more pass
		if (!extras.isEmpty()) {
			Map<Id, String> casesForUpdate = new Map<Id, String>();

			for (Id caseId : extras.keySet()) {
				Case parentCase = casesMap.get(caseId);
				String caseNumber = parentCase.CaseNumber;
				String reqDDC = parentCase.Requested_Due_Date_Day_of_Month__c;
				
				//TD #122 - null pointer exception at line 69 of TFSC_CaseCommentHandler
				//Benjamin Lau Reviewed with Dan
				if (reqDDC == null) {
					reqDDC = '00';
				}
				//end of TD #122 change
				
				while (reqDDC.length() < 2) {
					reqDDC = '0' + reqDDC;
				}
				
				String lastComment = buildCaseCommentFragment(caseNumber, reqDDC, extras.get(caseId));
					
				/*
				Case secondCase = new Case(
					Id = caseId,
					Last_Comment__c = buildCaseCommentFragment(caseNumber, reqDDC, extras.get(caseId)));
				secondCase.RecordTypeId = parentCase.RecordTypeId;
				*/
				casesForUpdate.put(caseId, lastComment);
				
			}

			//the last comment field is for STARS only
			//by update the last comment - we will trigger a new outbound message
			//update cases.values();
				
			// update the cases with the 2nd comment 
			// use batch to create a delay - so that Outbound message can capture the first comment
			Database.executeBatch(new TFSC_BatchUpdateCases(casesForUpdate));

		}

	}
	

	private String buildCaseCommentFragment(String caseNumber, String reqDDC, String comment) {
		
		// TD #123 - DO NOT Add DDC if the case is NOT a Due Date Change.
		if ( reqDDC.compareTo('00') == 0) {
			return caseNumber + PIPE + comment;
		} else {
			return caseNumber + PIPE + DDC + reqDDC + PIPE + comment;
		}
	}

}