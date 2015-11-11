/*

@HttpPost - retrieve all feedItem related to a parent Id

then use /chatter/feed-elements/feedElementId/capabilities/content to get the content
as described in http://www.salesforce.com/us/developer/docs/chatterapi/
*/

@RestResource(urlMapping='/FeedItemContentWebService/v1/*')
global class FeedItemContentWebService {

	@httpPost
	global static FeedItemMetaData post(String parentIdString) {
		if ( parentIdString == null || parentIdString.length() == 0) {
			return new FeedItemMetaData(parentIdString);
		}
		
		List<FeedItem> items = [
			SELECT id, ParentId, ContentFileName, ContentType, Title, Type, createdDate, createdBy.name, createdById, relatedRecordId
			FROM FeedItem
			where ParentId = :parentIdString
		];
		
		List<FeedItemMetaDataDetails> details = new List<FeedItemMetaDataDetails>();
		for(FeedItem item :  items) {
			details.add(new FeedItemMetaDataDetails(item));
		}
		return new FeedItemMetaData(parentIdString, details);
		
	}
	
	/////////////////////////////////////////////////////////////////
	global class FeedItemMetaData{
		public Id feedItemParentId;
		public integer numOfItem;
		public List<FeedItemMetaDataDetails> items;
			
		public FeedItemMetaData(id parentId) {
			this.feedItemParentId = parentId;
			this.numOfItem = 0;
			this.items = new List<FeedItemMetaDataDetails>();
		}

		public FeedItemMetaData(id parentId, List<FeedItemMetaDataDetails> items) {
			this.feedItemParentId = parentId;
			this.numOfItem = items.size();
			this.items = items;	
		}
	}
	
	global class FeedItemMetaDataDetails {
		public Id feedItemId;
		public Id parentId;
		public String contentFileName;
		public String contentType;
		public String title;
		public String feedItemType;
		//public String createdDate;
		public String createdByName;
		public String relatedRecordId;
		public Id createdById;
		
		public FeedItemMetaDataDetails(FeedItem item) {
			this.feedItemId = item.id;
			this.parentId = item.parentId;
			this.contentFileName = item.contentFileName;
			this.contentType = item.ContentType;
			this.title = item.title;
			this.feedItemType = item.type;
			//this.createdDate = item.createdDate;
			this.createdByName = item.createdBy.name;
			this.createdById = item.createdById;
			this.relatedRecordId = item.relatedRecordId;
		}
	}
	
	/////////////////////////////////////////////////////////////////
	
}