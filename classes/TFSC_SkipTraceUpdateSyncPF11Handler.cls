/**
 *  Firstly, this trigger handler is a 'sister' to TFSC_PF11NotesSkipTraceSyncHandler
 *
 *  This trigger handler takes a skipTrace upsert and either generates a pf11 note or updates the values of the existing pf11 note.
 *  Most all of the logic for updating a 'phone line' can be found in updatePhoneNoteValueFromSkipTrace().
 * 
 */
public class  TFSC_SkipTraceUpdateSyncPF11Handler implements TFSC_TriggerDispatcher.Handler {
    
    public static Boolean CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE = false;
    
    public void handle() 
    {
        List<Skip_Trace__c> newList = (List<Skip_Trace__c>)Trigger.new;
        
        if(!TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE) {
        	updateRelatedPF11Records(newList);
        }
        
    }
    
    
    private void updateRelatedPF11Records(List<Skip_Trace__c> newList) {
    	
    	List<Id> faIdList = generateFaList(newList);
    	
    	Map<Id,PF11_Notes__c> mapOfFaIdToSkipTrace = buildPF11Map(faIdList);
    	Map<Id,Financial_Account__c> mapOfFAs = buildFaMap(faIdList);
    	
    	List<PF11_Notes__c> pf11NotesToUpdate = new List<PF11_Notes__c>();
    	
    	for(Skip_Trace__c st : newList) {
    		
    		PF11_Notes__c relatedNote = mapOfFaIdToSkipTrace.get(st.Financial_Account__c);
    		Financial_Account__c fa = mapOfFAs.get(st.Financial_Account__c);
    		
    		if(relatedNote == null) {
    			relatedNote = new PF11_Notes__c( Financial_Account__c = st.Financial_Account__c );
    			relatedNote.Financial_Account_Number__c = fa.Financial_Account_Number__c ;
    			relatedNote.Name = fa.Financial_Account_Number__c ;
    			relatedNote.Type__c = fa.RecordType.Name;
    		}
    		
			updateRelatedNoteValuesFromSkipTrace(relatedNote, st);
			
			pf11NotesToUpdate.add(relatedNote);
    		
    	}
    	
    	//PREVENT AN UNNEEDED LOOP WHEN THE PF11_NOTES TRIGGER UPDATES SKIP_TRACE (AND CALLS THIS TRIGGER AGAIN).
        TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE = true;
    	
    	upsert pf11NotesToUpdate;
    	
    }
    
    private void updateRelatedNoteValuesFromSkipTrace(PF11_Notes__c relatedNote, Skip_Trace__c skipTrace) {
    	
    	//parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_4__c, skipTrace, 'Phone1_', 'Phone2_', '', '', 'CS', 'CS');
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_4__c', 'PHN:', skipTrace.Phone1_Type__c, skipTrace.Phone1__c, skipTrace.Phone1_Status__c, skipTrace.Phone1_Date__c, skipTrace.Phone2_Type__c, skipTrace.Phone2__c, skipTrace.Phone2_Status__c, skipTrace.Phone2_Date__c );
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_5__c', 'PHN:', skipTrace.Phone3_Type__c, skipTrace.Phone3__c, skipTrace.Phone3_Status__c, skipTrace.Phone3_Date__c, skipTrace.Phone4_Type__c, skipTrace.Phone4__c, skipTrace.Phone4_Status__c, skipTrace.Phone4_Date__c );
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_6__c', 'PHN:', skipTrace.Phone5_Type__c, skipTrace.Phone5__c, skipTrace.Phone5_Status__c, skipTrace.Phone5_Date__c, skipTrace.Phone6_Type__c, skipTrace.Phone6__c, skipTrace.Phone6_Status__c, skipTrace.Phone6_Date__c );
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_7__c', 'PHN:', skipTrace.Phone7_Type__c, skipTrace.Phone7__c, skipTrace.Phone7_Status__c, skipTrace.Phone7_Date__c, skipTrace.Phone8_Type__c, skipTrace.Phone8__c, skipTrace.Phone8_Status__c, skipTrace.Phone8_Date__c );
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_8__c', 'PHN:', skipTrace.Phone9_Type__c, skipTrace.Phone9__c, skipTrace.Phone9_Status__c, skipTrace.Phone9_Date__c, skipTrace.Phone10_Type__c, skipTrace.Phone10__c, skipTrace.Phone10_Status__c, skipTrace.Phone10_Date__c );
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_9__c', 'PHN:', skipTrace.Phone11_Type__c, skipTrace.Phone11__c, skipTrace.Phone11_Status__c, skipTrace.Phone11_Date__c, skipTrace.Phone12_Type__c, skipTrace.Phone12__c, skipTrace.Phone12_Status__c, skipTrace.Phone12_Date__c );
    	updatePhoneNoteValueFromSkipTrace(relatedNote, 'Notes_10__c', 'PHN:', skipTrace.Phone13_Type__c, skipTrace.Phone13__c, skipTrace.Phone13_Status__c, skipTrace.Phone13_Date__c, skipTrace.Phone14_Type__c, skipTrace.Phone14__c, skipTrace.Phone14_Status__c, skipTrace.Phone14_Date__c );
    	
    	updateDateNoteValueFromSkipTrace(relatedNote, skipTrace.Innovis_Date__c, 'Notes_25__c', 'INN: '); //
        updateDateNoteValueFromSkipTrace(relatedNote, skipTrace.Fast_Data_Date__c, 'Notes_26__c', 'FDA: '); 
        updateDateNoteValueFromSkipTrace(relatedNote, skipTrace.Accurint_Date__c, 'Notes_27__c', 'ACC: '); 
    }
    
    private void updateDateNoteValueFromSkipTrace(PF11_Notes__c relatedNote, Date dateObj, String destField, String startString) {
    	String strFieldValue = startString; //len = 5
    	
    	
    	String dateStringPlusComma = '         ';
    	if(dateObj != null) {
    		String dd = prependZeroToDateIf1Chr( String.valueOf(dateObj.day()) );
    		String mm = prependZeroToDateIf1Chr( String.valueOf(dateObj.month()) );
    		String yy = String.valueOf(dateObj.year()).substring(2,4);
    		dateStringPlusComma = mm + '/' + dd + '/' + yy + ',' ;
    	}
    	strFieldValue += dateStringPlusComma ;
    	
    	
    	strFieldValue += numberOfSpacesMap.get(41);
    	strFieldValue += getMMDDFromDate(dateToday, 5);
    	
    	relatedNote.put( destField, strFieldValue );
    }
    
    private String prependZeroToDateIf1Chr(String numString) {
    	if(numString.length() == 1) {
    		numString = '0' + numString;
    	}
    	return numString;
    }
    
    
    
    private void updatePhoneNoteValueFromSkipTrace(PF11_Notes__c relatedNote, 
                                                    String noteDestinationField,
                                                    String noteStart, 
                                                    String phoneType1, 
                                                    String phone1, 
                                                    String status1, 
                                                    Date phoneDate1,
                                                    String phoneType2, 
                                                    String phone2, 
                                                    String status2, 
                                                    Date phoneDate2) 
    {
    	//CEL: C# 9515552222 D# 06/09, X# 9515553333 B# 06/09,   06/09
    	String oneCharPhoneType1 = ' ';
    	String oneCharPhoneType2 = ' ';
    	if(phoneType1 != null && phoneType1.length() > 0) {
            oneCharPhoneType1 = phoneType1.substring(0,1); 
        }
        if(phoneType2 != null && phoneType2.length() > 0) {
            oneCharPhoneType2 = phoneType2.substring(0,1); 
        }
    	
    	
    	String srtValue = noteStart + ' '; //note start = 'PHN:'  len = 5
    	
    	srtValue += getNoteChunkStartingFromTypeToDate(phone1, oneCharPhoneType1, status1, phoneDate1);
    	srtValue += ', ';
    	srtValue += getNoteChunkStartingFromTypeToDate(phone2, oneCharPhoneType2, status2, phoneDate2);
    	srtValue += ',   ';
    	srtValue += getMMDDFromDate(dateToday, 5);
    	
    	relatedNote.put( noteDestinationField, srtValue );
    }
    
    private Date dateToday = Date.today();
    private String getNoteChunkStartingFromTypeToDate(String phone, String oneCharPhoneType, String status, Date phoneDate) {
    	//C# 9515552222 D# 06/09
    	String strToReturn = '';
    	if(oneCharPhoneType != null && oneCharPhoneType.length() == 1) {
            strToReturn += oneCharPhoneType + '# ';
        }else{
            strToReturn += '___';
        }
        
        strToReturn += cleanPhoneTo10Chars(phone);
        strToReturn += ' ';
        
        if( !TFSC_Utils.isNullOrEmpty(status) ) {
            strToReturn += status.substring(0,1) + '# ';
        }else{
            strToReturn += '___';
        }
        
        strToReturn += getMMDDFromDate(phoneDate, 5);
    	
    	return strToReturn;
    }
    
    private String getMMDDFromDate(Date dateObj, Integer spacesToReturnIfBlank) {
    	String strToReturn = '';
    	if(dateObj != null){
    		String dd = String.valueOf( dateObj.day() );
    		String mm = String.valueOf( dateObj.month() );
    		if(dd.length() == 1) {
                dd = '0' + dd;
            }
            if(mm.length() == 1) {
                mm = '0' + mm;
            }
            strToReturn = mm + '/' + dd;
    	}
    	
    	if(strToReturn == '' && spacesToReturnIfBlank > 0){
    		strToReturn = numberOfSpacesMap.get(spacesToReturnIfBlank);
    	}
    	
    	return strToReturn;
    }
    
    private String cleanPhoneTo10Chars(String phone) {
    	String strToReturn = '';
    	
    	if(!TFSC_Utils.isNullOrEmpty(phone)) {
    		strToReturn = phone.replaceAll('[^0-9]','') ;
    	}
    	
    	Integer strLength = strToReturn.length();
    	if(strLength > 10) {
    		strToReturn = strToReturn.substring(0, 10);
    	}else if(strLength < 10) {
    		strToReturn = numberOfSpacesMap.get(10 - strLength) + strToReturn;
    	}
    	
    	return strToReturn;
    	
    }
    
    private Map<Integer,String> numberOfSpacesMap = new Map<Integer,String>{
        1 => ' ',
        2 => '  ',
        3 => '   ',
        4 => '    ',
        5 => '     ',
        6 => '      ',
        7 => '       ',
        8 => '        ',
        9 => '         ',
        10 => '          ',
        41 => '                                         ',
        40 => '                                        '
    };
    
    
    
    
    private List<Id> generateFaList(List<Skip_Trace__c> newList) {
        List<Id> listToReturn = new List<Id>();
        for(Skip_Trace__c skipTrace : newList) {
            listToReturn.add( skipTrace.Financial_Account__c );
        }
        
        return listToReturn;
    }
    
    private Map<Id,PF11_Notes__c> buildPF11Map(List<Id> faIdList) {
    	Map<Id,PF11_Notes__c> mapToReturn = new Map<Id,PF11_Notes__c>();
    	
    	for(PF11_Notes__c note : [select id, Financial_Account__c, Type__c
                                   from PF11_Notes__c
                                   where Financial_Account__c in :faIdList] )
        {
        	mapToReturn.put(note.Financial_Account__c, note);
        }
    	
    	return mapToReturn;
    }
    
    private Map<Id,Financial_Account__c> buildFaMap(List<Id> faIdList) {
    	
    	Map<Id,Financial_Account__c> mapToReturn;
    	
    	try {
            mapToReturn = new Map<Id,Financial_Account__c>( [select id, Financial_Account_Number__c, RecordType.Name
                                                               from Financial_Account__c
                                                               where id in :faIdList] );
        }
        catch (Exception e) {
        }
	    	
    	
    	
    	if(mapToReturn == null) {
    		mapToReturn = new Map<Id,Financial_Account__c>();
    	}
    	
    	return mapToReturn;
    	
    }
    
    
    
    

}