@IsTest
public class FeedItemContentWebServiceTest {
	
	@IsTest
	public static void unitTest() {
		
		FeedItemContentWebService.FeedItemMetaData feedItemMdNull = FeedItemContentWebService.post(null);
		
		Id acctId = createData();
		
		FeedItemContentWebService.FeedItemMetaData feedItemMd = FeedItemContentWebService.post(acctId);
		
		System.assertNotEquals(null, feedItemMd);

		System.assert(feedItemMd.feedItemParentId == acctId);
		System.assert(feedItemMd.numOfItem == 1);
		System.assert(feedItemMd.items <> null);
		System.assert(feedItemMd.items.size() == 1);
		
		
		FeedItemContentWebService.FeedItemMetaDataDetails item = feedItemMd.items[0];
		System.assert( item <> null);
		System.assert( item.parentId == acctId );
	}
	
	
	//return the id of an account with an associated FeedItem
	public static Id createData() {
		Account a = new Account();
		a.lastName = 'unitTest Account';
		insert a;
		
		FeedItem fi = new FeedItem();
		fi.title = 'test FeedItem';
		fi.parentId = a.id;
		fi.body = 'test body';
		//fi.ContentFileName = 'testContentFile';
		//fi.Type = 'ContentPost';
		
		insert fi; 
		
		return a.id;
	}

}