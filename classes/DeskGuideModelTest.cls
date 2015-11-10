/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  Unit test for Desk Guides 
*  
**/

@IsTest
public class DeskGuideModelTest {

	@IsTest
	public static void TestDeskGuideModel() {
		createData();
		
		Test.startTest();
		
		DeskGuideModel.calculateArchivedDate();  
		DeskGuideModel.deleteAllDeskGuideFeedItems();
		DeskGuideModel.deleteAllDeskGuides();
		DeskGuideModel.delAllDeskGuidePacks();
		
		createData();
		DeskGuideModel.deleteAllDeskGuidePacks();
		
		Test.stopTest();
	}

	public static void createData() {
		//create a desk Guide Pack
		Desk_Guide_Pack__c deskGuidePack = new Desk_Guide_Pack__c();
		deskGuidePack.Name = 'testDeskGuidePack';
		
		insert deskGuidePack;
		System.assert(deskGuidePack.id <> null);
		
		
		//create a few Desk_Guide_PDF__Feed
		List<Desk_Guide_PDF__c> deskGuideList = new List<Desk_Guide_PDF__c>();
		
		Desk_Guide_PDF__c guide1 = new Desk_Guide_PDF__c();
		guide1.DeskGuidePack__c = deskGuidePack.id;
		deskGuideList.add(guide1);
		guide1.PublishedDate__c = Date.NewInstance(2014,1,1);
		
		Desk_Guide_PDF__c guide2 = new Desk_Guide_PDF__c();
		guide2.DeskGuidePack__c = deskGuidePack.id;
		deskGuideList.add(guide2);
		guide2.PublishedDate__c = Date.NewInstance(2014,2,1);
		
		Desk_Guide_PDF__c guide3 = new Desk_Guide_PDF__c();
		guide3.DeskGuidePack__c = deskGuidePack.id;
		deskGuideList.add(guide3);
		guide3.PublishedDate__c = Date.NewInstance(2014,3,1);
		
		insert deskGuideList;
	}
}