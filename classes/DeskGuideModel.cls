/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  Desk Guide Packs are used to group legacy TFS Desk Guide in PDF format.  
*               Then Individual articles will be linked to Desk Guide Packs for printing
*  
**/

public class DeskGuideModel {


	public static void deleteAllDeskGuideFeedItems() {
		List<Desk_Guide_PDF__Feed> feeds = [
			select id 
			from Desk_Guide_PDF__Feed
		];
		delete feeds;
	}

	private static void deleteAllDeskGuideFeedItems(set<id> dgIds) {
		List<Desk_Guide_PDF__Feed> feeds = [
			select id 
			from Desk_Guide_PDF__Feed
			where ParentId in :dgIds
		];
		delete feeds;
	}
	
	public static void deleteAllDeskGuides() {
		List<Desk_Guide_PDF__c> dgs = [
			select id
			from Desk_Guide_PDF__c
			
		];
		delete dgs;
	}

	private static void deleteAllDeskGuides(set<Id> dgPackIds) {
		List<Desk_Guide_PDF__c> dgs = [
			select id
			from Desk_Guide_PDF__c
			where DeskGuidePack__c in :dgPackIds
		];
		
		set<id> dgIds = new Set<Id>();
		for(Desk_Guide_PDF__c dgPdf : dgs) {
			dgIds.add(dgPdf.id);
		}
		
		deleteAllDeskGuideFeedItems(dgIds);
		delete dgs;
	}
	
	public static void delAllDeskGuidePacks() {
		List<Desk_Guide_Pack__c> dgPacks = [
			select id
			from Desk_Guide_Pack__c
		];
		delete dgPacks;
	}
	
	//DeskGuideModel.deleteAllDeskGuidePacks();
	public static void deleteAllDeskGuidePacks() {
		
		List<Desk_Guide_Pack__c> dgPacks = [
			select id
			from Desk_Guide_Pack__c
		];
		
		set<id> dgPackIds = new Set<Id>();
		for(Desk_Guide_Pack__c dgPack : dgPacks) {
			dgPackIds.add(dgPack.id);
		}
		
		SavePoint sp = Database.setSavepoint();
		try {
			deleteAllDeskGuides(dgPackIds);
			delete dgPacks;
		} catch( Exception e) {
			Database.rollback(sp);
		}   
	}
	
	
	//DeskGuideModel.calculateArchivedDate();  
	public static void calculateArchivedDate() {
		List<Desk_Guide_PDF__c> deskGuideList = [
			select name,  PublishedDate__c, ArchivedDate__c, DeskGuidePack__r.name
			from Desk_Guide_PDF__c
			order by DeskGuidePack__r.name,PublishedDate__c
		];
		
		
		for(integer i = 0; i < deskGuideList.size()-1; i++) {
			if (deskGuideList[i].DeskGuidePack__r.name == deskGuideList[i+1].DeskGuidePack__r.name) {
				deskGuideList[i].ArchivedDate__c = deskGuideList[i+1].PublishedDate__c.addDays(-1);
			}
		}
		
		update deskGuideList;
	}
	
	//DeskGuideModel.calculateBlankArchivedDate('1/1/2015');  
	public static void calculateBlankArchivedDate(String lastArchivedDate) {
	
		Date lastDate = Date.parse(lastArchivedDate);
		System.Debug(lastDate);
	
		List<Desk_Guide_PDF__c> deskGuideList = [
			select ArchivedDate__c
			from Desk_Guide_PDF__c
			where ArchivedDate__c = null
		];
		
		for(Desk_Guide_PDF__c deskGuide : deskGuideList) {
			deskGuide.ArchivedDate__c = lastDate;
		}
		
		update deskGuideList;
	}

	//DeskGuideModel.parseDeskGuideTitle();
	public static void parseDeskGuideTitle() {
		List<Desk_Guide_PDF__c> dgs = [
			select id, name, TitleSort__c
			from Desk_Guide_PDF__c
		];
		
		for(Desk_Guide_PDF__c dg : dgs) {
			dg.TitleSort__c = getTitleSort(dg.name);
		}
		
		update dgs;
	}
	
		
	public static String getTitleSort( String dgName) {
		integer index = dgName.lastIndexOf(' ');
		String result = dgName.substring(0,index);
		return result;
	}

}