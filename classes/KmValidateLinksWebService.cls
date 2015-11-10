/*
@httpPost - retrieve links to check
@httpPatch - update brokenLink validation results
*/


@RestResource(urlMapping='/KmValidateLinksWebService/v1/*')
global class KmValidateLinksWebService {
	
	@httpPost
	global Static KmValidateLinksWebServieReply post () {
		//DateTime dt = DateTime.now().addHours(-24);
		
		List<LinkValidation__c> validateLinks = [
			select id, Link__c, Link_Type__c   
			from LinkValidation__c
			where Link_Type__c in ('SF Document','Intranet Doc','Internet', 'Article') 
			order by Link_Type__c, Last_Checked__c
			limit 5000
		];
		
		KmValidateLinksWebServieReply result = new KmValidateLinksWebServieReply();
		for(LinkValidation__c lv : validateLinks) {
			lv.Last_Checked__c = DateTime.now();
			result.details.add(new KmValidateLinksWebServieReplyDetail(lv));
		}
		update validateLinks;
		
		return result;  
	}  


	@httpPatch
	global Static void patch(List<String> brokenLinkIds, List<String> connectionRefusedIds) {
	
		if ( brokenLinkIds == null) {
			System.Debug('KmValidateLinksUpdWebServiceReply == null');
		} else {
			System.Debug('Patch received # of brokenLink Ids count = '+ brokenLinkIds.size());
			for(String brokenLinkId : brokenLinkIds) {
				System.Debug('BrokenLink Id = '+ brokenLinkId);
			}
		}
		
		Set<String> brokenLinkSet = new Set<String>();
		for(String linkid : brokenLinkIds) {
			brokenLinkSet.add(linkid);
		}
		
		Set<String> connectionRefusedSet = new Set<String>();
		for(String linkid : connectionRefusedIds) {
			connectionRefusedSet.add(linkid);
		}
		
		List<LinkValidation__c> validateLinks = [
			select id, is_Broken__c
			from LinkValidation__c
		];    
		
		for(LinkValidation__c lv : validateLinks) {
			if ( brokenLinkSet.contains(lv.id) ){
				lv.is_Broken__c = true;
			} else {
				lv.is_Broken__c = false;
			}
			
			if ( connectionRefusedSet.contains(lv.id) ){
				lv.Connection_Refused__c = true;
			} else {
				lv.Connection_Refused__c = false;
			}
		}
		
		update validateLinks;
		
	}
	
	///////////////////////////////////////////////////////////////////////////////////
	
	global class KmValidateLinksWebServieReply {
	
		public List<KmValidateLinksWebServieReplyDetail> details = null;	
		
		public KmValidateLinksWebServieReply() {
			details = new List<KmValidateLinksWebServieReplyDetail>();
		}
	}
	
	global class KmValidateLinksWebServieReplyDetail {
	
		public Id validateLinkId;
		public String link;
		public String typ;
		
		public KmValidateLinksWebServieReplyDetail(LinkValidation__c lv) {
			this.validateLinkId = lv.id;
			this.link = lv.link__c;
			this.typ = lv.Link_Type__c;
			
		}
	}
}