/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  BinderPageFilter2 - 2nd version of BinderPage Filter
*					retrieves knowledge articles from Article Depot instead of individual KAV custom objects
*
* - upgraded to work with dynamic ArticleTypes
**/

global class BinderPageFilter2 {

	webservice static void QueryForArticles(String BinderId) {
		
		BinderModel.clearAllBinderPages(BinderId);

		Binder__c binder = BinderModel.getBinderById(BinderId);
		
		if ( binder == null) {
			System.Debug('BinderPageFilter2::QueryForArticles  ERROR - Abort cannot locate Binder by BinderId '+BinderId);
			return;
		}
		  
		if ( binder.recordType.name == 'Print Function 1' ) {
			// 1. FOPP# / Hierarchy / Article Type
			queryForPrint1(binder); 
		} else if ( binder.recordType.name == 'Print Function 2') {
			// 2. Date Range
			queryForPrint2(binder);
		} else {
			//invalid - only 2 print functions defined so far
			System.Debug('BinderPageFilter2::QueryForArticles  Warning - unknown Binder Record Type for '+BinderId +
				'  defaulting to Print Function 1');
			queryForPrint1(binder); 
		
		}
		
	}

	////////////////////////////////////////////
	// webservices to sort binderPages


	webservice static void OrderByArticleNumVersionThenTitleForDeskGuides(String BinderId) {
		List<BinderPage__c> pages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			and ArticleNumVersion__c <> null
			order by Article_Number__c, Version_Number__c desc 
		];
		integer lastSeq = sequenceAndPersist(pages, 10);
		lastSeq += 100;
		
		//then handle the Deskguides
		List<BinderPage__c> dgPages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			and ArticleNumVersion__c = null
			order by TitleSort__c, Published_on__c desc
		];
		sequenceAndPersist(dgPages, lastSeq);
	}
		
	webservice static void OrderByKnowledgeContainerArticleNumVersion(String BinderId) {
		List<BinderPage__c> pages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			order by Knowledge_Container_Name__r.name, Article_Number__c, Version_Number__c desc 
		];
		sequenceAndPersist(pages, 10);
	}
	
	webservice static void OrderByFoppArticleNumVersion(String BinderId) {
		List<BinderPage__c> pages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			order by FOPP__c, Article_Number__c, Version_Number__c desc
		];
		sequenceAndPersist(pages, 10);
	}
	webservice static void OrderByArticleTypeNumberVersionDesc(String BinderId) {
		List<BinderPage__c> pages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			order by PageType__c, Article_Number__c, Version_Number__c desc
		];
		sequenceAndPersist(pages, 10);
	}
	webservice static void OrderByPublishedDate(String BinderId) {
		List<BinderPage__c> pages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			order by Published_on__c
		];
		sequenceAndPersist(pages, 10);
	}

	private static integer sequenceAndPersist(List<BinderPage__c> pages, integer seq) {
		for(BinderPage__c page : pages) {
			page.sequence__c = seq;
			seq += 10;
		}
		
		update pages;
		return seq;
	}

	///////////////////////////////////////////
		
	public static String getDateTime(Date aDate) {
		if ( aDate <> null) {
			string result = String.ValueOf(aDate)+'T00:00:00Z';
			return result;
		} else {
			return '';
		}
	}

	//change to toDate to 11:59:59 of that date
	public static String getDateTimeEOD(Date aDate) {
		if ( aDate <> null) {
			string result = String.ValueOf(aDate)+'T23:59:59Z';
			return result;
		} else {
			return String.ValueOf(Date.today())+'T23:59:59Z';
		}
	}

	
	public static String idSetToString(set<id> ids) {
		string result = '(';
		for(id i : ids ){
			result = result + '\''+i+'\',';
		}
		result = result.removeEnd(',')+')';
		return result;
	}
	
	public static String stringSetToString(set<String> names) {
		string result = '(';
		for(String name : names ){
			result = result + '\''+name+'\',';
		}
		result = result.removeEnd(',')+')';
		return result;
	}
	
	
	private static void queryForPrint1(Binder__c binder) {
		
		if ( binder == null) {
			return;
		}
		if(binder.To_Date__c == null) {
			binder.To_Date__c = Date.today();
		}
		
		
		// 3 parts to construct the SOQL
		// 1 - field list and from 
		// 2 - date selection  
		// 3 - restOfSelection
		String soqlSelect = 'SELECT Id, ArchivedDate__c, PublishStatus__c, ArticleType__c, Article_Number__c, OrginalArticleId__c, OrginalArticleVersionId__c, ' +
			'FirstPublishedDate__c, LastPublishedDate__c, Desk_Guide_Pack__c, ArticleTypeAPI__c, PublishedDate__c, ArticleNumVersion__c,' + 
			'Title__c, VersionNumber__c, FOPP__c, KnowledgeContainerName__c ' +
			'FROM ArticlePDF__c ';
			
			
		String soqlDateOnline =  
			'WHERE PublishStatus__c = \'Online\' and PublishedDate__c >= '+getDateTime(binder.From_Date__c) +
			' and PublishedDate__c <= '+getDateTimeEOD(binder.To_Date__c)+' ';
			
			
		String soqlSelectRest = '';
		
		if ( binder.FOPP__c <> null ) {
			soqlSelectRest =  ' and FOPP__c like \'%'+ binder.FOPP__c+'%\' ';
		}
		
		if ( binder.Knowledge_Container__c <> null  && !binder.Include_children__c) {
			soqlSelectRest += ' and Knowledge_Container__r.name = \''+ binder.Knowledge_Container__r.name +'\' ';
		} else if ( binder.Knowledge_Container__c <> null  && binder.Include_children__c) {
			
			String containerIdsString = stringSetToString(KnowledgeContainerModel.findContainerNamesWithChildren(binder.Knowledge_Container__c) );
			soqlSelectRest += ' and Knowledge_Container__r.name in '+ containerIdsString +' ';
		} 
		  
		  
		if (binder.Article_Type__c <> null && binder.Article_Type__c <> '') {
			soqlSelectRest += ' and ArticleTypeAPI__c in ( '+ 
			translateArticleTypeMultiPicklist(binder.Article_Type__c) +') ';
		} 
		
		
		String soqlSelectOnline = soqlSelect + soqlDateOnline + soqlSelectRest;
		System.Debug(soqlSelectOnline);
		
		List<ArticlePDF__c>	articles = Database.query(soqlSelectOnline);
		
		binder.SOQL_Online__c = soqlSelect + '\r\n' + soqlDateOnline + '\r\n' + soqlSelectRest + '\r\n\r\n';
		binder.SOQL_Online__c += DebugArticles(articles);
		
		if ( binder.Include_Archived__c) {
			articles = getArchivedArticles(articles, soqlSelect, soqlSelectRest, binder.From_Date__c, binder.To_Date__c.addDays(1), binder);
		} else {
			binder.SOQL_Archive_1__c = '';
			binder.SOQL_Archive_2__c = '';
			binder.SOQL_Archive_3__c = '';			
		}
		
		persistBinderPage(articles, binder.id);
		
		//now add the deskGuides
		binder.SOQL_DG_Pack__c = '';

		addDeskGuides(articles, binder.id, binder.From_Date__c, binder.To_Date__c.addDays(1), binder);
		
		update binder;
	}
	private static String DebugArticles(List<ArticlePDF__c> articles) {
		String result = '';
		for(ArticlePDF__c article : articles) {
			String debugStr = article.Article_Number__c +' : '+
				article.ArticleNumVersion__c + ' : '+
				article.Title__c + ' : ' + article.PublishedDate__c;
				
			result +=	debugStr + '\r\n';
			System.Debug(debugStr);
		}
		return result;
	}
	
	private static String DebugArchivedArticles(List<ArticlePDF__c> articles) {
		String result = '';
		for(ArticlePDF__c article : articles) {
			String debugStr = article.Article_Number__c +' : '+
				article.ArticleNumVersion__c + ' : '+
				article.Title__c + ' : '+
				article.PublishedDate__c + ' : ' + article.ArchivedDate__c;
				
			result +=	debugStr + '\r\n';
			System.Debug(debugStr);
		}
		return result;
	}

	private static String DebugDeskGuide(List<Desk_Guide_PDF__c> deskguides) {
		String result = '';
		for(Desk_Guide_PDF__c deskguide : deskguides) {
			String debugStr = deskguide.Name +' : '+
				deskguide.PublishedDate__c + ' : '+
				deskguide.ArchivedDate__c + ' : ' +
				deskguide.DeskGuidePack__r.name;
				
			result +=	debugStr + '\r\n';
			System.Debug(debugStr);
		}
		return result;
	}
	
	private static void addDeskGuides(List<ArticlePDF__c> articles, Id binderId, Date fromDate, Date toDate, Binder__c binder) {
		//1.gather a set of deskGuides referenced
		Set<Id> deskGuideIds = new Set<Id>();
		for(ArticlePDF__c article : articles) {
			if(article.Desk_Guide_Pack__c <> null ) { 
				deskGuideIds.add(article.Desk_Guide_Pack__c);
			}
		}
		
		//2.query for from / to date for deskGuides PDF
		List<Desk_Guide_PDF__c> deskGuides = [
			select id,name, DeskGuidePack__c, ArchivedDate__c, PublishedDate__c, DeskGuidePack__r.name, TitleSort__c
			from Desk_Guide_PDF__c
			where DeskGuidePack__c in :deskGuideIds
			and ( 
				( PublishedDate__c <= :fromDate and ArchivedDate__c >= :fromDate) or 
				( PublishedDate__c <  :ToDate   and ArchivedDate__c = null) or 
				( PublishedDate__c >  :fromDate and ArchivedDate__c <= :ToDate ) 
			)
		];
		
		binder.SOQL_DG_Pack__c = 
			'select id,name, DeskGuidePack__c, ArchivedDate__c, PublishedDate__c, DeskGuidePack__r.name' + '\r\n' +
			'from Desk_Guide_PDF__c' + '\r\n' +
			'where DeskGuidePack__c in '+deskGuideIds + '\r\n' +
			'and ( ' + '\r\n' +
			'	( PublishedDate__c <= :' + fromDate + ' and ArchivedDate__c >= :'+fromDate+' ) or \r\n' +
			'	( PublishedDate__c <  :' + ToDate + ' and ArchivedDate__c = null) or \r\n' +
			'	( PublishedDate__c >  :' + fromDate + ' and ArchivedDate__c <= :'+ToDate+' ) \r\n' +
			') ' + '\r\n\r\n\r\n';
		
		binder.SOQL_DG_Pack__c +=  'found '+deskGuides.size() +'\r\n';
		binder.SOQL_DG_Pack__c += DebugDeskGuide(deskGuides) +'\r\n\r\n';
		
		//3.convert deskGuide PDF binder pages and persists
		
		List<BinderPage__c> bpList = new List<BinderPage__c>();
		integer seq = articles.size() * 10 + 100;
	
		for(Desk_Guide_PDF__c deskGuide : deskGuides) {

			binderPage__c bp = new binderPage__c();
			bp.binder__c = binderId;
			
			bp.PageType__c = 'Desk Guide';
			bp.PageRef__c = deskGuide.id;
			bp.TitleSort__c = deskGuide.TitleSort__c;
		
			bp.Sequence__c = seq;
			seq = seq + 10;
			bp.published_on__c = deskGuide.PublishedDate__c;
			bp.title__c =  deskGuide.name;
			
			bp.Publish_Status__c = 'Archived';
			bpList.add(bp);
		} 
		
		insert bpList;
		
	}
	
	private static List<ArticlePDF__c> getArchivedArticles(List<ArticlePDF__c>	articles, String soqlSelect, String soqlSelectRest, DateTime fromDate, DateTime toDate, Binder__c binder) {
		
		
		//6 cases
		//4 should be included
		//
		//case 1 - from > Published and from < Archived
		String soqlDateArchive1 = 'Where PublishedDate__c <= :fromDate and ArchivedDate__c >= :fromDate and PublishStatus__c = \'Archived\' ';
		String soqlSelectArchivedCase1 = soqlSelect + soqlDateArchive1 + + soqlSelectRest;
		List<ArticlePDF__c>	archivedArticlesCase1 = Database.query(soqlSelectArchivedCase1);
		binder.SOQL_Archive_1__c = soqlSelect + '\r\n' + soqlDateArchive1 + '\r\n' + soqlSelectRest + '\r\n\r\n';
		binder.SOQL_Archive_1__c += DebugArchivedArticles(archivedArticlesCase1);
		
		//case 2 - to > Published and to < Archived
		String soqlDateArchive2 = 'Where PublishedDate__c <= :toDate and ArchivedDate__c >= :toDate and PublishStatus__c = \'Archived\' ';
		String soqlSelectArchivedCase2 = soqlSelect + soqlDateArchive2 + soqlSelectRest;
		List<ArticlePDF__c>	archivedArticlesCase2 = Database.query(soqlSelectArchivedCase2);
		binder.SOQL_Archive_2__c = soqlSelect + '\r\n' + soqlDateArchive2 + '\r\n' + soqlSelectRest + '\r\n\r\n';
		binder.SOQL_Archive_2__c += DebugArchivedArticles(archivedArticlesCase2);
		
		//case 3 - from < Published and to > Archived
		String soqlDateArchive3 = 'Where PublishedDate__c >= :fromDate and ArchivedDate__c <= :toDate and PublishStatus__c = \'Archived\' ';
		String soqlSelectArchivedCase3 = soqlSelect + soqlDateArchive3 + soqlSelectRest;		
		List<ArticlePDF__c>	archivedArticlesCase3 = Database.query(soqlSelectArchivedCase3);
		binder.SOQL_Archive_3__c = soqlSelect + '\r\n' + soqlDateArchive3 + '\r\n' + soqlSelectRest + '\r\n\r\n';
		binder.SOQL_Archive_3__c += DebugArchivedArticles(archivedArticlesCase3);		
		
		
		//case 4 - from > Published and to < Archived    <--- no need for query - covered by case 1 & case 2 already
			
			
		//de-dupe with a map before appending
		List<ArticlePDF__c>	archivedArticles = new List<ArticlePDF__c>();
		
		archivedArticles.addAll(archivedArticlesCase1);
		archivedArticles.addAll(archivedArticlesCase2);
		archivedArticles.addAll(archivedArticlesCase3);
		
		set<String> archivedArticleNumVersionSet = new set<String>();
		//prefill with what has been inserted
		for(ArticlePDF__c article: articles) {
			archivedArticleNumVersionSet.add(article.ArticleNumVersion__c);
		}
		
		 
		for(ArticlePDF__c archivedArticle : archivedArticles) {
			
			if ( !archivedArticleNumVersionSet.contains(archivedArticle.ArticleNumVersion__c)) {
				articles.add(archivedArticle);
				archivedArticleNumVersionSet.add(archivedArticle.ArticleNumVersion__c);
			} else {
				System.Debug('Skipping archivedArticle - dupe '+ archivedArticle.ArticleNumVersion__c);
			}
		}
		
			
		return articles;
	}
	
	
	private static string translateArticleTypeMultiPicklist(String values ) {
		String[] articleTypes = values.split(';');
		string result = '';
		for(string articleType : articleTypes) {
			string kav = KmArticleTypeModel.knowledgeLabelNameToKav(articleType) ;
			if (kav.endswith('ka')) {
				kav += 'v';
			}
			result = result + '\'' + kav + '\', ';
		}
	
		return result.removeEnd(', ');
	}
	
	private static void queryForPrint2(Binder__c binder) {
		if ( binder == null) {
			return;
		}
		
		binder.Knowledge_Container__c = null;
		binder.Include_children__c = false;
		binder.Article_Type__c = null;
		binder.FOPP__c = null;
		
		queryForPrint1(binder);
	}
	
	
	private static List<BinderPage__c> persistBinderPage(List<ArticlePDF__c> articles, id binderId) {
		List<BinderPage__c> bpList = new List<BinderPage__c>();
		integer seq = 10;
	
		for(ArticlePDF__c article : articles) {

			binderPage__c bp = new binderPage__c();
			bp.binder__c = binderId;
			bp.Article_Number__c = article.Article_Number__c;
			bp.PageType__c = article.ArticleTypeAPI__c;
			bp.PageRef__c = article.OrginalArticleVersionId__c;
			bp.Comment__c = article.Title__c;
			bp.Sequence__c = seq;
			bp.articleDepotId__c = article.Id;
			seq = seq + 10;
			bp.published_on__c = article.PublishedDate__c;
			bp.version_number__c = article.VersionNumber__c;
			bp.articleNumVersion__c = article.articleNumVersion__c;
					
			bp.title__c =  article.Title__c;
			bp.FOPP__c = article.FOPP__c;
			bp.Knowledge_Container_Name__c = article.KnowledgeContainerName__c;
			
			bp.First_Published_date__c = article.FirstPublishedDate__c;
			bp.Publish_Status__c = article.PublishStatus__c;
			bpList.add(bp);
		} 
		
		insert bpList;
		
		return bpList;
	}
	
	
	
	webservice static void ClearAllBinderPages(String BinderId) {
		System.Debug('*** BinderPageFilters::ClearAllBinderPages '+BinderId);
		
		BinderModel.clearAllBinderPages(BinderId);
		
	}
	
	webservice static void RenumberAllBinderPages(String BinderId) {
		System.Debug('*** BinderPageFilters::RenumberAllBinderPages '+BinderId);
		
		List<BinderPage__c> pages = [
			select id, sequence__c
			from BinderPage__c
			where Binder__c = :BinderId
			order by sequence__c
		];
		
		integer newSeq = 10;
		for(BinderPage__c page : pages) {
			page.sequence__c = newSeq;
			newSeq = newSeq + 10;
		}
		update pages;
	}
}