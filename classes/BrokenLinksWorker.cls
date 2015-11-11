global class BrokenLinksWorker {
	
	private static final Pattern ANCHOR_PATTERN = Pattern.compile('(?i)<a([^>]+)>(.+?)</a>'); //Anchor tag pattern
	private static final Pattern HREF_PATTERN = Pattern.compile('\\s*(?i)href\\s*=\\s*("([^\"]*\")|\'[^\']*\'|([^\'">\\s]+))'); //href pattern
		
	private static BrokenLinksWorker pInstance;
	public static BrokenLinksWorker getInstance() {
		if (pInstance == null) {
			pInstance = new BrokenLinksWorker();
		}
		return pInstance;
	}
	
	//BrokenLinksWorker.clearAllValidateLinks();
	public static void clearAllValidateLinks() {
		List<LinkValidation__c> lvs = [select id from LinkValidation__c ];
		delete lvs;
	}
	
	public BrokenLinksWorker() {
	}
	
	public static DateTime getJobLastRunTime() {     
		return getBrokenLinksJob().job_run_time__c;
	}
	
	public static void updateJobLastRunTime(DateTime jobStartTime) {
		//Update job last run time custom setting
		Broken_Links_Job__c blj = getBrokenLinksJob();
		blj.job_run_time__c = jobStartTime;
		update(blj);
	}
	
	private static Broken_Links_Job__c getBrokenLinksJob() {
		Broken_Links_Job__c blj = null;
		//Broken_Links_Job__c is a custom settings
		integer bljCount = [select count() from broken_Links_Job__c where name = 'Broken Links Job'];
		if (bljCount == 0) {
			blj = new Broken_Links_Job__c();
			blj.name = 'Broken Links Job';  
			blj.job_run_time__c = DateTime.newInstance(2000,1,1,0,0,0);
			insert blj;
		}  
		blj = [select job_run_time__c from Broken_Links_Job__c where name = 'Broken Links Job'];
		return blj;
	}
	  
	public static List<String> getCustomTextFieldsToCheckForLinks(String articleTypeApiName) {
		System.Debug('getCustomTextFieldsToCheckForLinks - checking '+articleTypeApiName);
		List<String> result = new List<String>();
		
		
		for(Schema.SobjectField sobjField : KmArticleTypeModel.getSObjectFieldMap(articleTypeApiName).values()) {
			Schema.DisplayType displayType = sobjField.getDescribe().getType();
			String fieldApiName = sobjField.getDescribe().getName();
			
			if ( displayType == Schema.DisplayType.String || displayType == Schema.DisplayType.TextArea || displayType == Schema.DisplayType.URL ) {
				result.add(fieldApiName);
				//System.Debug('CustomTextFieldsToCheckForLinks - scan for URL in  '+ fieldApiName);
			} else {
				//System.Debug('CustomTextFieldsToCheckForLinks - ignore '+ fieldApiName);
			}
		}
		System.Debug('CustomTextFieldsToCheckForLinks - '+ result);
		return result;
	} 
	
    
    /*
    * Main public worker method which:
    * 1. Finds links in the details__c field of each of the article types. 
    * 2. Inserts a LinkValidation__c record for each link found
    * 3. Updates the custom setting Broken_Links_Job__c with the job run time 
    */
    public void findLinks() {
    	DateTime jobStartTime = DateTime.now();
    	
    	List<LinkValidation__c> linkValidationList = new List<LinkValidation__c>();
    	  
    	try {
    		for (String kaApiName : KmArticleTypeModel.activeKaApiNames) {
    			System.Debug('\r\n\r\n'+'findLinks Scanning : '+ kaApiName);
    			
    			String kavApiName = kaApiName+'v';
    			Set<String> customFieldApiNames = KmArticleTypeModel.getArticleTypeCustomFields(kavApiName);
    			
    			//String soqlCustomFields = 'details__c, dm_forms__c, fopp__c, overview__c ';
    			String soqlCustomFields = '';
    			for(String customFieldApiName : customFieldApiNames) {
    				soqlCustomFields += customFieldApiName + ', ';
    			}   
    			soqlCustomFields = soqlCustomFields.substringBeforeLast(', ');
				DateTime jobLastRunTime = getJobLastRunTime();
				String dateTimeQueryLimiter = ' AND lastpublishedDate > :jobLastRunTime';
				
				String soql = 'SELECT id, KnowledgeArticleId, Title, articletype, articlenumber, versionnumber,  lastpublishedDate, Summary, UrlName, ' +
					soqlCustomFields + ' ' + 
					'FROM '+kavApiName+ ' ' +
					'WHERE publishStatus=\'Online\' and Language=\'en_US\'' + dateTimeQueryLimiter;
					
				System.Debug(soql);
				List<SObject> kavs = Database.query(soql);
				
				for (SObject kav : kavs) {
					String details = '';
					//build dynamic custom field list
					for ( String customFieldApiName : getCustomTextFieldsToCheckForLinks(kavApiName)) {
						String fieldContent = (String)kav.get(customFieldApiName);
						System.Debug('customFieldApiName : '+customFieldApiName ); //+ ' = '+ kav.get(customFieldApiName)+'\r\n');
						if ( fieldContent <> null) {
							details += kav.get(customFieldApiName)+' ';
						}
					}
					
					System.Debug('Details for article : '+details+'\r\n\r\n');
					
					List<String> links = findLinks(details);
					if (links.size() > 0) {			
						List<LinkValidation__c> articleLinksToBeValidated = getArticleLinksToBeValidated(links, kav);
						
						linkValidationList.addAll(articleLinksToBeValidated);
					} else {
						System.Debug('findLinks did not find any links in article Type '+kaApiName+'\r\n');
					}
				}   
    		}
		} catch (Exception e) {
			System.debug(e.getMessage());
		}			
		
		
		System.Debug('\r\n\r\n'+'findlinks finished scanning.');
		
		//Insert the new link validation records
		if (linkValidationList.size() > 0) {
			try {
			  insert (linkValidationList);
			} catch (DMLException dmle) {
			  System.debug(dmle.getMessage());
			}
		}
		updateJobLastRunTime(jobStartTime);
		
		//clean up all links from articles that has been archived with an async future job
		cleanUpBrokenLinksFromArchivedArticles();
    }
    
    @future
    private static void cleanUpBrokenLinksFromArchivedArticles() {
    
    	//Get a list of all links
    	List<LinkValidation__c> links = [
    		select id, Article_Number__c, Version_Number__c
    		from LinkValidation__c
    	];	

    	
    	Map<String, id> ArticleNumVersionMap = new Map<String, Id>();
    	for(LinkValidation__c link : links) {
    		System.debug('>>>>>> Article Number: ' + link.Article_Number__c + ', Version Number: ' + link.Version_Number__c);
    		String articleNumVersion = KmModel.getArticleNumVersion(link.Article_Number__c, link.Version_Number__c);
    		ArticleNumVersionMap.put(articleNumVersion, link.id );
    	} 
    	
    	//now find all ArticleNumVersion in ArticleDepot that has been archived
    	List<ArticlePDF__c> articlePdfList = [
    		select id, ArticleNumVersion__c
    		from ArticlePDF__c
    		where ArticleNumVersion__c in :ArticleNumVersionMap.keySet()
    		and PublishStatus__c = 'Archived'
    	];
    	
    	//now pick the validate link records that has been archived
    	set<String> archivedArticleNumVersionSet = new set<String>();
    	
    	for (ArticlePDF__c article : articlePdfList ) {
    		archivedArticleNumVersionSet.add(article.ArticleNumVersion__c);
    	}
    	
    	
    	List<LinkValidation__c> linksToDelete = new List<LinkValidation__c>();
    	for(LinkValidation__c link : links) {
    		String articleNumVersion = KmModel.getArticleNumVersion(link.Article_Number__c, link.Version_Number__c);
    		if (archivedArticleNumVersionSet.contains(articleNumVersion) ) {
    			linksToDelete.add(link);
    		}
    	} 
    	delete linksToDelete;
    }
    
   
    /*
    * Private utility method which returns populated LinkValidation__c object lists
    * which can then be inserted.
    */
    private List<LinkValidation__c> getArticleLinksToBeValidated(List<String> wellFormedUrls, SObject kav) {
    	
    	String articleType = (String)kav.get('articleType');
    	String articleNumber = (String)kav.get('articleNumber');
    	Integer versionNumber = (Integer)kav.get('versionNumber');
    	//Id kavId = (Id)kav.get('kavId');
    	Id kavId = (Id)kav.get('id');
    	//Id kaId = (Id)kav.get('kaId');
    	String Title = (String)kav.get('Title');
    	
    	List<LinkValidation__c> linksToBeValidated = new List<LinkValidation__c>();
    	
    	for (String wellFormedUrl : wellFormedUrls) {
    		//Set default link type to Internet
    		String linkType = 'Internet';
    		
    		if (String.isEmpty(wellFormedUrl) ) {
    			continue;
    		}
			//Check link type

	    	if (wellFormedUrl.startsWith('http://intradoc') || wellFormedUrl.startsWith('http://stellent')) {
	    		linkType = 'Intranet Doc';
	    	} else if (wellFormedUrl.startsWith('https://' + System.URL.getSalesforceBaseURL().getHost())) {
	    		if (wellFormedUrl.contains('/articles/')) {
	    			linkType = 'Article';
	    		} else {
	    			linkType = 'SF Document';
	    		}
	    	} else if (wellFormedUrl.contains('https://') && wellFormedUrl.contains('.salesforce.com/') && !wellFormedUrl.endsWith('.salesforce.com/')) {
	    		if (wellFormedUrl.contains('/articles/')) {
	    			linkType = 'Article';
	    		} else {
	    			linkType = 'SF Document';
	    		}	    		
	    	} else {  
	    		linkType = 'Internet';
	    	}

    		LinkValidation__c linkToValidate = new LinkValidation__c(Link__c = wellFormedUrl, 
    													 Link_Type__c = linkType,
    		                                             Article_Type_API__c = articleType, 
    		                                             Article_Number__c = articleNumber,
    		                                             Version_Number__c = versionNumber);
    		
    		//benjamin added code to show friendly article label, link to orginal article and link to edit article
    		//linkToValidate.Article_Type_Label__c = kmModel.articleApiToLabelMap.get(articleType);
    		linkToValidate.Article_Type_Label__c = KmArticleTypeModel.getKnowledgeArticleLabelByApiName(articleType);
    		
    		linkToValidate.Original_Article_URL__c = 'https://' + System.URL.getSalesforceBaseURL().getHost() + '/'+ kavId;
    		linkToValidate.Title__c = Title;
    		
			linksToBeValidated.add(linkToValidate);
    	}
    	return (linksToBeValidated);
    }
    
    /*
    * Private utility method which finds links using Regular Expression matching and returns the  
    * found links as a List of Strings.
    */
    private List<String> findLinks(String detail) {
    	List<String> links = new List<String>();
    	
		Matcher anchorMatcher = ANCHOR_PATTERN.matcher(detail);
		while (anchorMatcher.find()) {
		   String href = anchorMatcher.group(1);
		   
		   Matcher hrefMatcher = HREF_PATTERN.matcher(href);
		   while (hrefMatcher.find()) {
		      String link = hrefMatcher.group(1);
		      String wellFormedLink = getWellFormedUrl(link);
		      if (wellFormedLink != null) {
		      	//If found link is longer than 255 characters, restrict to 255 characters.  
		      	if (wellFormedLink.length() > 255 ) {
		      		links.add(wellFormedLink.substring(0, 255));
		      	} else {
		      		links.add(wellFormedLink);
		      	}
		      }
		   }
		}   
		
		if ( links.size() == 0) {
			System.Debug('findLinks did not find any links in '+detail + '/r/n'); 
		} else {
			System.Debug('findLinks found links : '+links.size());
		}
		return (links);
    }
    
    /*
    * Take the original link in the article and transform it into a form consumable by the broken link checker.
    * 1. Remove the start and end double quote
    * 2. Link starting with # or mailto is invalid
    * 3. For relative URLs starting with /, assume it is link to a salesforce document and prefix it with 
    *    https:// and the salesforce host.
    * If the link is not well formed, return null, else return the well formed link. 
    */
    private String getWellFormedUrl(String sourceUrl) {
    	String wellFormedUrl = null;
    	
		if (sourceUrl.startsWith('"')) {
		  sourceUrl = sourceUrl.substring(1);
		}
		if (sourceUrl.endsWith('"')) {
		  sourceUrl = sourceUrl.substring(0, sourceUrl.length() - 1);
		}
		if ( !(sourceUrl.startsWith('#') || sourceUrl.startsWith('mailto')) ) {
			if (sourceUrl.startsWith('/')) {
				wellFormedUrl = 'https://' + System.URL.getSalesforceBaseURL().getHost() + sourceUrl;
			} else {
				wellFormedUrl = sourceUrl;
			}
		}
    	
    	return (wellFormedUrl);
    }
    
    public void DeleteAllValidateLinkRecords() {
    	List<sObject> objs = [select id from LinkValidation__c];
    	delete objs;    
    	
    	//update job last run time custom setting
		updateJobLastRunTime(DateTime.now().addMonths(-100));
    }
    
    
    webservice static void OnDemandValidateArticleLinks() {
		BrokenLinksJob.RunBrokenLinksJob();
		return;
	}
	
}