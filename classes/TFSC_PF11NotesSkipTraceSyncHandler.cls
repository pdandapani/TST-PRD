/**
 *  Firstly, this trigger handler is a 'sister' to TFSC_SkipTraceUpdateSyncPF11Handler
 *
 *  Secondly, see the unit test for expected values for a PF11 note.
 *
 *  This trigger handler takes a PF11 note upsert and either generates a skip trace or updates the values of the existing skip trace.
 *  On insert, both updateAndInsertFieldValidationList and insertOnlyFieldValidationList FIELDS are synced.
 *  On update, only updateAndInsertFieldValidationList FIELDS are synced.
 *
 *  There wasn't much in the realm of a pre-insert/update validation, so currently the only major validations are that the
 *  length of a note line is equal to 60, and the line must start with the required prefix (see *fieldPrefixValidationMap*).
 *  Validation failures are appended to allFieldErrorMessagesValidationMap and are put into the field "PF11_Notes__c.Validation_Errors__c"
 *  
 *  One major thing to note is that the public static variables in the handle() method (PF11_TRIGGER_FIRED_ONCE_IN_STACK for example)
 *  are used within the call-stack.  SO, if TFSC_SkipTraceUpdateSyncPF11Handler is called first (a skip trace is upserted)
 *  then that public static boolean should be set in the call stack and this method shouldn't continue.
 *
 *  Last but not least, because this trigger needed to be an "after" trigger, and not a "before" trigger, a new update needed to be executed.
 *  hense the need for PF11_TRIGGER_FIRED_ONCE_IN_STACK.  See the lines of code surrounding "update notesToReUpdate;"
 * 
 */
public class TFSC_PF11NotesSkipTraceSyncHandler implements TFSC_TriggerDispatcher.Handler {
    
    public static Boolean runningTests = true;
    public static Boolean PF11_TRIGGER_FIRED_ONCE_IN_STACK = false; 
    
    public void handle() 
    {
        List<PF11_Notes__c> newlist = (List<PF11_Notes__c>)Trigger.new;
        
        
        validatePf11NoteLengthsAndValues(newlist, !trigger.isInsert);
        
        
        //see header comment.
        if(!TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE && !PF11_TRIGGER_FIRED_ONCE_IN_STACK) {
        	PF11_TRIGGER_FIRED_ONCE_IN_STACK = true;
        	updateRelatedSkipTraceRecords(newlist, trigger.isInsert);
        }else{
        	if(TFSC_PF11NotesSkipTraceSyncHandler.runningTests) {
	    		System.Debug('***** PF11_TRIGGER_FIRED_ONCE_IN_STACK = ' + String.valueOf(PF11_TRIGGER_FIRED_ONCE_IN_STACK));
	    		System.Debug('***** CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE = ' + String.valueOf(TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE));
	    	}
        }
        
    }
    
    
    private void validatePf11NoteLengthsAndValues(List<PF11_Notes__c> newList, Boolean isUpdate) {
    	
    	//'Notes_5__c', 
        //'Notes_6__c',
    	String[] insertOnlyFieldValidationList = new String[]{
		    	    'Notes_11__c', 
		            'Notes_12__c', 
		            'Notes_13__c', 
		            'Notes_15__c',
		    	    'Notes_16__c', 
		    	    'Notes_25__c',
		    	    'Notes_26__c',
		    	    'Notes_27__c'
    	};
        
        
    	 
    	String[] updateAndInsertFieldValidationList  = new String[]{
    	    'Notes_4__c', 
    	    'Notes_5__c', 
    	    'Notes_6__c', 
    	    'Notes_7__c', 
            'Notes_8__c', 
            'Notes_9__c', 
            'Notes_10__c',
            'Notes_17__c', 
            'Notes_18__c', 
            'Notes_19__c', 
            'Notes_20__c',
            'Notes_21__c',
            'Notes_22__c',
            'Notes_23__c'
    	};
    	
    	
    	String[] fieldListToValidate60CharLength = new String[]{};
    	fieldListToValidate60CharLength.addAll(insertOnlyFieldValidationList);
    	
    	//if(!isUpdate) {
    		fieldListToValidate60CharLength.addAll(updateAndInsertFieldValidationList);
    	//}
    	
    	
    	Boolean allRowsHitErrors = true;
    	
    	for(PF11_Notes__c pf11Note : newList) {
    		allRowsHitErrors = true;
    		for(String insertFieldName : fieldListToValidate60CharLength) {
                String fieldVal = (String)pf11Note.get(insertFieldName);
                String threeCharPrefix ;
                String errMsg = '';
                if(fieldVal != null){
                    Integer fieldValLength = fieldVal.length();
                    if(fieldValLength != 60) {
                        fieldFailedValidationMap.put(pf11Note.Id + insertFieldName, true);
                        errMsg = allFieldErrorMessagesValidationMap.get(pf11Note.Id);
                        if(errMsg == null) {
                        	errMsg = '';
                        }
                        errMsg += insertFieldName + ' not 60 characters long; ' + fieldVal;
                        allFieldErrorMessagesValidationMap.put(pf11Note.Id, errMsg);
                        
                    }else {  //field length = 60
                        threeCharPrefix = fieldPrefixValidationMap.get(insertFieldName);
                        if(threeCharPrefix != null) {
                            if(threeCharPrefix != fieldVal.substring(0,3)) {
                                fieldFailedValidationMap.put(pf11Note.Id + insertFieldName, true);
                                
                                errMsg = allFieldErrorMessagesValidationMap.get(pf11Note.Id);
		                        if(errMsg == null) {
		                            errMsg = '';
		                        }
		                        errMsg += 'Incorrect Prefix for ' + insertFieldName + '; ' + fieldVal + '\n';
		                        allFieldErrorMessagesValidationMap.put(pf11Note.Id, errMsg);
                            }else{
                            	//passed all validation rules.
                            	allRowsHitErrors = false;
                            }
                        }
                    }
                    
                }
            } //end of field loop
            
            if(allRowsHitErrors) {
            	allFieldsFailedValidation.put(pf11Note.Id, true);
            }
            
    	}
    }
    
    private Map<String,Boolean> fieldFailedValidationMap = new Map<String,Boolean>();
    private Map<String,String> allFieldErrorMessagesValidationMap = new Map<String,String>();
    private Map<Id,Boolean> allFieldsFailedValidation = new Map<Id,Boolean>();
    
    private Map<String,String> fieldPrefixValidationMap = new Map<String,String>{
        'Notes_4__c' => 'PHN',
        'Notes_5__c' => 'PHN',
        'Notes_6__c' => 'PHN',
        'Notes_7__c' => 'PHN',
        'Notes_8__c' => 'PHN',
        'Notes_9__c' => 'PHN',
        'Notes_10__c' => 'PHN',
        'Notes_11__c' => 'C/A',
        'Notes_12__c' => 'X/A',
        'Notes_13__c' => 'CAC',
        'Notes_15__c' => 'AKA',
        'Notes_17__c' => 'OA#',
        'Notes_18__c' => 'OA#',
        'Notes_19__c' => 'AAD',
        'Notes_20__c' => 'CEA',
        'Notes_21__c' => 'XEA',
        'Notes_22__c' => 'SPC',
        'Notes_23__c' => 'MSC',
        'Notes_25__c' => 'INN',
        'Notes_26__c' => 'FDA',
        'Notes_27__c' => 'ACC'
    };
    
    
    private List<Account> accountsToUpdateForAKA = new List<Account>();
    private void updateRelatedSkipTraceRecords(List<PF11_Notes__c> newList, Boolean isInsert) {
    	
    	if(TFSC_PF11NotesSkipTraceSyncHandler.runningTests) {
    		System.Debug('***** updateRelatedSkipTraceRecords');
    	}
    	
    	
    	Set<Id> faIdSet = generateFaListFromPF11List(newList);
    	List<PF11_Notes__c> notesToReUpdate = new List<PF11_Notes__c>();
    	
    	//for multiple reasons, Skip_Trace__c will/should always be a 1:1 on FA
    	Map<Id,Skip_Trace__c> mapOfFaIdToSkipTrace = buildSkipTraceMap(faIdSet);
    	Map<Id,Financial_Account_Customer__c> mapOfFaIdToFac = buildMapOfFAIDtoFac(faIdSet);
    	
    	List<Skip_Trace__c> listOfSkipTracesToUpdate = new List<Skip_Trace__c>();
    	
    	Boolean insertingSkipTrace;
    	for(PF11_Notes__c noteObj : newList) {
    		
    		if(allFieldsFailedValidation.get(noteObj.Id) != null && allFieldsFailedValidation.get(noteObj.Id) == true) {
    			continue;
    		}
    		
    		if(TFSC_PF11NotesSkipTraceSyncHandler.runningTests) {
	    		System.Debug('***** continue allFieldsFailedValidation');
	    	}
    		
    		insertingSkipTrace = false;
    		Skip_Trace__c skipTrace = mapOfFaIdToSkipTrace.get(noteObj.Financial_Account__c);
    		Financial_Account_Customer__c primaryFac = mapOfFaIdToFac.get(noteObj.Financial_Account__c);
    		
    		if(skipTrace == null) {
    			skipTrace = new Skip_Trace__c( Financial_Account__c = noteObj.Financial_Account__c );
    			if( !TFSC_Utils.isNullOrEmpty(noteObj.Financial_Account_Number__c) ) {
    				skipTrace.Name = noteObj.Financial_Account_Number__c;
    			}
    			
    			insertingSkipTrace = true;
    		}
    		
    		
    		//bottom date fields:	
			updateSkipTraceValuesFromF11NoteOnUpdateAndInsert(skipTrace, noteObj, isInsert);
			
			if(primaryFac != null) {
				updateAKAWhereNecessaryAndAppendToUpdateList(skipTrace, noteObj, primaryFac);
				if( TFSC_Utils.isNullOrEmpty(skipTrace.Name) || primaryFac.Financial_Account__r.Financial_Account_Number__c != skipTrace.Name ) {
					//should be set above from noteObj.Financial_Account_Number__c, but if it's not:
					skipTrace.Name = primaryFac.Financial_Account__r.Financial_Account_Number__c;
				}
			}
			
			
			if(insertingSkipTrace == true) {
				setValuesForInsertOnlyFields(skipTrace, noteObj, isInsert);
			}else{
				setValuesForBiDirectionalFields(skipTrace, noteObj);
			}
			
			listOfSkipTracesToUpdate.add(skipTrace);
    		
    	}
    	
    	//PREVENT AN UNNEEDED LOOP WHEN THE PF11_NOTES TRIGGER UPDATES SKIP_TRACE (AND CALLS THIS TRIGGER AGAIN).
        TFSC_SkipTraceUpdateSyncPF11Handler.CALL_STACK_IN_HAS_ALREADY_EXECUTED_SKIPTRACE_UPDATE = true;
    	
    	upsert listOfSkipTracesToUpdate;
    	update accountsToUpdateForAKA;
    	
    	//A SECOND NOTES UPDATE IS BEING DONE HERE BECAUSE
    	//  I NEED THE RECORD-ID IN ORDER TO GRACEFULLY (and 'bulkify-ing-ly') PROCESS VALIDATIONS
    	//  (RecordId is the only trusted unique field on this object, AFTER INSERT IS REQUIRED.)
    	//ALSO, THE VAR [PF11_TRIGGER_FIRED_ONCE_IN_STACK] WILL PREVENT MULTIPLE ENTRIES AND UNNEEDED OVER-PROCESSING. 
    	for(PF11_Notes__c noteObj2 : newList) {
    		if(allFieldErrorMessagesValidationMap.get(noteObj2.Id) != null) {
				PF11_Notes__c hackForUpdate = new PF11_Notes__c();
				hackForUpdate.Id = noteObj2.Id;
				hackForUpdate.Validation_Errors__c = allFieldErrorMessagesValidationMap.get(noteObj2.Id);
				notesToReUpdate.add(hackForUpdate);
			}
    	}
    	update notesToReUpdate;
    	
    }
    
    
    private void setValuesForBiDirectionalFields(Skip_Trace__c skipTrace, PF11_Notes__c noteObj) {
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_4__c') == null) {
    		setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_4__c, skipTrace);
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_5__c') == null) {
    		setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_5__c, skipTrace);
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_6__c') == null) {
    		setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_6__c, skipTrace);
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_7__c') == null) {
    		setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_7__c, skipTrace);
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_8__c') == null) {
    		setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_8__c, skipTrace);
    	}
        if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_9__c') == null) {
        	setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_9__c, skipTrace);
        }
        if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_10__c') == null) {
        	setPhoneValuesWithoutDuplicatingPhoneNumbers(noteObj.Notes_10__c, skipTrace);
        }
    }
    
    private void setPhoneValuesWithoutDuplicatingPhoneNumbers(String incomingNoteValue, Skip_Trace__c skipTrace) {
    	
    	if( !TFSC_Utils.isNullOrEmpty(incomingNoteValue) ) {
    		
    		String[] strList = incomingNoteValue.split(',');
            if(strList.size() >= 2) {
                PhoneObject phoneObj = new PhoneObject(strList);
                
                if(phoneObj.phone1 != null && phoneObj.phone1.length() > 0) {
                	checkOverwriteValsForDuplicatePhoneNumberAndSaveToSObject(skipTrace, phoneObj.phone1, phoneObj.date1, phoneObj.status1, phoneObj.phoneType1);
                }
                if(phoneObj.phone2 != null && phoneObj.phone2.length() > 0) {
                	checkOverwriteValsForDuplicatePhoneNumberAndSaveToSObject(skipTrace, phoneObj.phone2, phoneObj.date2, phoneObj.status2, phoneObj.phoneType2);
                }
            }
            
    	}
    }
    
    private void checkOverwriteValsForDuplicatePhoneNumberAndSaveToSObject(Skip_Trace__c skipTrace, 
                                                                            String phone,
                                                                            Date dateObj,
                                                                            String phoneStatus,
                                                                            String phoneType) 
    {
    	PhoneFieldMarshaller phoneMarshallerObj = mapOfSkipTraceIdToPhoneMarshaller.get(skipTrace.Id);
    	
    	if(phoneMarshallerObj != null) {
    		String existingPhoneField = phoneMarshallerObj.mapOfCleanedPhoneToField.get(phone);
    		if(existingPhoneField == null) {
    			//then phone IS NOT on the skipTrace record;
    			String firstAvailableField = phoneMarshallerObj.getFirstUnusedFieldForUpdate();
    			if(firstAvailableField != null) {
    				//then fewer than 51 phone fields are on the skip trace object.
    				phoneMarshallerObj.usedFields.add(firstAvailableField);
    				String newPhonePrefix = firstAvailableField.substring(0, firstAvailableField.length() - 2);
    				skipTrace.put( newPhonePrefix + 'Date__c', dateObj );
	                skipTrace.put( newPhonePrefix + 'Status__c', phoneStatus );
	                skipTrace.put( newPhonePrefix + 'Type__c', phoneType );
	                skipTrace.put( newPhonePrefix + '_c', phone );
	                skipTrace.put( newPhonePrefix + 'CS_CX__c', 'CS' );
    			}
    		}else{
    			//then phone IS on the skipTrace record;
    			String phoneFieldPrefix = existingPhoneField.substring(0, existingPhoneField.length() - 2);
                skipTrace.put( phoneFieldPrefix + 'Date__c', dateObj );
                skipTrace.put( phoneFieldPrefix + 'Status__c', phoneStatus );
                skipTrace.put( phoneFieldPrefix + 'Type__c', phoneType );
                skipTrace.put( phoneFieldPrefix + '_c', phone );
    			skipTrace.put( phoneFieldPrefix + 'CS_CX__c', 'CS' );
                //skipTrace.put( phoneFieldPrefix + 'Source__c', phone1Source );
    		}
            
    	}
    	
    }
    
    
    
    
    
    
    private void updateSkipTraceValuesFromF11NoteOnUpdateAndInsert(Skip_Trace__c skipTrace, PF11_Notes__c noteObj, Boolean isInsert) {
    	
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_25__c') == null) {
    		setDateField(noteObj.Notes_25__c, skipTrace, 'Innovis_Date__c');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_26__c') == null) {
    		setDateField(noteObj.Notes_26__c, skipTrace, 'Fast_Data_Date__c');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_27__c') == null) {
    		setDateField(noteObj.Notes_27__c, skipTrace, 'Accurint_Date__c');
    	}
    	
    }
    
    private void setValuesForInsertOnlyFields(Skip_Trace__c skipTrace, PF11_Notes__c noteObj, Boolean isInsert) {
    	if(TFSC_PF11NotesSkipTraceSyncHandler.runningTests) {
    		System.Debug('***** setValuesForInsertOnlyFields');
    	}
    	//---------------------Bi-directional fields
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_4__c') == null) {
	    	parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_4__c, skipTrace, 'Phone1_', 'Phone2_', '', '', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_5__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_5__c, skipTrace, 'Phone3_', 'Phone4_', '', '', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_6__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_6__c, skipTrace, 'Phone5_', 'Phone6_', '', '', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_7__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_7__c, skipTrace, 'Phone7_', 'Phone8_', '', '', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_8__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_8__c, skipTrace, 'Phone9_', 'Phone10_', '', '', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_9__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_9__c, skipTrace, 'Phone11_', 'Phone12_', '', '', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_10__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_10__c, skipTrace, 'Phone13_', 'Phone14_', '', '', 'CS', 'CS');
    	}
    	
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_11__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_11__c, skipTrace, 'Phone15_', 'Phone16_', 'Credit App', 'Credit App', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_12__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_12__c, skipTrace, 'Phone18_', 'Phone19_', 'Credit App', 'Credit App', 'CX', 'CX');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_13__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_13__c, skipTrace, 'Phone17_', 'Phone20_', 'Credit App', 'Credit App', 'CS', 'CX');
    	}
    	
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_17__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_17__c, skipTrace, 'Phone21_', 'Phone22_', 'Multiple Accounts', 'Multiple Accounts', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_18__c') == null) {
    		parseAndWritePhoneNumberLineToSkipTrace(noteObj.Notes_18__c, skipTrace, 'Phone23_', 'Phone24_', 'Multiple Accounts', 'Multiple Accounts', 'CS', 'CS');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_19__c') == null) {
    		//Note19 = address 1 and prepend ALT + \n beginning of field, use MM/DD/YY for Address1_Date_Range__c)
            parseAndWriteAddressLineToSkipTrace(noteObj.Notes_19__c, skipTrace, 'ALT\n', 'Address1__c', 'Address1_Date_Range__c', 'Address1_Source__c', '');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_20__c') == null) {
    		//Note20 - (address 2 and prepend CS + \n beginning of field, Source = "Credit App", use MM/DD/YY for Address2_Date_Range__c)
            parseAndWriteAddressLineToSkipTrace(noteObj.Notes_20__c, skipTrace, 'CS\n', 'Address2__c', 'Address2_Date_Range__c', 'Address2_Source__c', 'Credit App');
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_21__c') == null) {
    		parseAndWriteAddressLineToSkipTrace(noteObj.Notes_21__c, skipTrace, 'CX\n', 'Address3__c', 'Address3_Date_Range__c', 'Address3_Source__c', 'Credit App');
    	}
        
        //22, 23
        setMiscNotes(noteObj, skipTrace);
        
    }
    
    
    //destinationField is validated for MM/DD/YY
    private void setDateField( String noteValue, Skip_Trace__c skipTrace, String destinationField ) {
    	String dateString = substringTrimAndRemoveTrailingComma(noteValue);
    	system.debug( '***** ' + dateString );
    	if(dateString != null && dateString.length() == 8) {
    		Date dateObj = getDateFromMMDDYYString(dateString);
    		if(dateObj != null) {
    			skipTrace.put(destinationField, dateObj);
    		}
    	}
    }
    
    
    private void setMiscNotes(PF11_Notes__c noteObj, Skip_Trace__c skipTrace) {
    	String spcNotes;
    	String mscNotes;
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_22__c') == null) {
    		spcNotes = substringTrimAndRemoveTrailingComma(noteObj.Notes_22__c);
    	}
    	if(fieldFailedValidationMap.get(noteObj.Id + 'Notes_23__c') == null) {
    		mscNotes = substringTrimAndRemoveTrailingComma(noteObj.Notes_23__c);
    	}
        String miscNotes = '';
        if( !TFSC_Utils.isNullOrEmpty(spcNotes)) {
            miscNotes = 'SPC: ' + spcNotes;
        }
        if( !TFSC_Utils.isNullOrEmpty(spcNotes)) {
            if( miscNotes != '' ){
                miscNotes += '\n';
            }
            miscNotes += 'MSC: ' + mscNotes;
        }
        skipTrace.Miscellaneous_Notes__c = miscNotes;
    }
    
    private void parseAndWriteAddressLineToSkipTrace(String incomingNoteValue, 
                                        Skip_Trace__c skipTrace,
                                        String startingText,
                                        String skipTraceAddressFieldname,
                                        String dateRangeFieldName,
                                        String sourceFieldName,
                                        String sourceValue) 
    {
    	String cleanedAddressValue = substringTrimAndRemoveTrailingComma(incomingNoteValue);
        if( !TFSC_Utils.isNullOrEmpty(cleanedAddressValue) ) {
        	cleanedAddressValue = startingText + cleanedAddressValue;
            skipTrace.put(skipTraceAddressFieldname, cleanedAddressValue) ;
            Date dateObj = getDateFromMMDDAtTheEndOfAString(incomingNoteValue) ;
            if(dateObj != null) {
            	skipTrace.put(dateRangeFieldName, dateObj.format()) ;
            }
            
            skipTrace.put(sourceFieldName, sourceValue);
        }
    }
    
    
    private void parseAndWritePhoneNumberLineToSkipTrace(String incomingNoteValue, 
                                        Skip_Trace__c skipTrace, 
                                        String phone1FieldPrefix, 
                                        String phone2FieldPrefix,
                                        String phone1Source,
                                        String phone2Source,
                                        String phone1CSCX,
                                        String phone2CSCX)
    {
    	
    	//PHN: ___9517199254 G# 06/09, ___9517199255 G# 06/09,   06/09
    	//PHN:  #            ___     ,  #            ___     ,   06/13
    	if( !TFSC_Utils.isNullOrEmpty(incomingNoteValue) && incomingNoteValue.length() == 60) {
    		String[] strList = incomingNoteValue.split(',');
    		
    		//["PHN: ___9517199254 G# 06/09"," ___9517199255 G# 06/09","   06/09"]
    		if(strList.size() >= 2) {
    			
	    		if(TFSC_PF11NotesSkipTraceSyncHandler.runningTests) {
		    		System.Debug('***** parseAndWritePhoneNumberLineToSkipTrace; field prefix =' + phone1FieldPrefix);
		    	}
    			
    			PhoneObject phoneObj = new PhoneObject(strList);  
    			
    			if(TFSC_PF11NotesSkipTraceSyncHandler.runningTests && phoneObj.phone1 != null) {
		    		System.Debug('***** parseAndWritePhoneNumberLineToSkipTrace; phoneObj.phone1 = ' + phoneObj.phone1);
		    	}
    			
    			//Phone1_CS_CX__c, Phone1_Date__c, Phone1_Source__c, Phone1_Status__c, Phone1_Type__c
    			skipTrace.put( phone1FieldPrefix + 'CS_CX__c', phone1CSCX );
                skipTrace.put( phone1FieldPrefix + 'Source__c', phone1Source );
                skipTrace.put( phone1FieldPrefix + 'Date__c', phoneObj.date1 );
                skipTrace.put( phone1FieldPrefix + 'Status__c', phoneObj.status1 );
                skipTrace.put( phone1FieldPrefix + 'Type__c', phoneObj.phoneType1 );
                skipTrace.put( phone1FieldPrefix + '_c', phoneObj.phone1 );
                
                skipTrace.put( phone2FieldPrefix + 'CS_CX__c', phone2CSCX );
                skipTrace.put( phone2FieldPrefix + 'Source__c', phone2Source );
                skipTrace.put( phone2FieldPrefix + 'Date__c', phoneObj.date2 );
                skipTrace.put( phone2FieldPrefix + 'Status__c', phoneObj.status2 );
                skipTrace.put( phone2FieldPrefix + 'Type__c', phoneObj.phoneType2 );
                skipTrace.put( phone2FieldPrefix + '_c', phoneObj.phone2 );
    		}
    		
    	}
    }
    
    
    
    public static String getPhoneTypeFromAbrev(String str) {
    	String strToReturn = '';
    	
    	if(str.length() > 0) {
    		String firstChar = str.substring(0,1);
    		if(firstChar == 'W') {
    			strToReturn = 'Work';
    		}else if(firstChar == 'H') {
    			strToReturn = 'Home';
    		}else if(firstChar == 'M') {
    			strToReturn = 'Mobile';
    		}
    	}
    	
    	return strToReturn;
    }
    
    private Date getDateFromMMDDAtTheEndOfAString(String mmddEndingString) {
    	Date dateToReturn;
    	
    	Integer stringLength = mmddEndingString.length();
    	if(stringLength >= 5) {
    		dateToReturn = TFSC_PF11NotesSkipTraceSyncHandler.getDateFromMMDDString( mmddEndingString.substring(stringLength - 5, stringLength), null );
    	}
    	
    	return dateToReturn;
    }
    
    private Date dateToday = Date.today();
    public static Date dateToday2 = Date.today(); //just trying to cut-down on the 1000+ lines of code (minimum) that will be executed in this trigger.
    public static Date getDateFromMMDDString(String mmddString, Date dateToday) {
        if(dateToday == null) {
        	dateToday = dateToday2;
        }
        Date dateToReturn;
        
        try {
            String mm;
            String dd;
            if(mmddString.length() > 4) 
            {
                mm = mmddString.substring(0,2);
                dd = mmddString.substring(3,5);
                
                if(mm.substring(0,1) == '0') {
                    mm = mm.substring(1); //get last character
                }
                if(dd.substring(0,1) == '0') {
                    dd = dd.substring(1); //get last character
                }
                
                Integer day = Integer.valueOf(dd);
                Integer month = Integer.valueOf(mm);
                Integer year = dateToday.year();
                if(month > dateToday.month() || (month == dateToday.month() && day > dateToday.day()) ) {
                    year = dateToday.year() -1; //dates are always from today back.
                }
                
                dateToReturn = date.newinstance(year, month, day);
                
            }
        }
        catch (Exception e) {
        }
        
        return dateToReturn;
    }
    
    private Date getDateFromMMDDYYString(String mmddString) {
        Date dateToReturn;
        
        try {
	        String mm = mmddString.substring(0,2);
	        String dd = mmddString.substring(3,5);
	        String yy = mmddString.substring(6,8);
	        if(mm.substring(0,1) == '0') {
	            mm = mm.substring(1);
	        }
	        if(dd.substring(0,1) == '0') {
	            dd = dd.substring(1);
	        }
	        if(yy.substring(0,1) == '0' || yy.substring(0,1) == '1' || yy.substring(0,1) == '2') {
	            yy = '20' + yy;
	        }
	        
	        Integer day = Integer.valueOf(dd);
	        Integer month = Integer.valueOf(mm);
	        Integer year = Integer.valueOf(yy);
	        
	        dateToReturn = date.newinstance(year, month, day);
        }catch (Exception e) {
        }
        
        return dateToReturn;
    }
    
    
    private void updateAKAWhereNecessaryAndAppendToUpdateList(Skip_Trace__c skipTrace, PF11_Notes__c noteObj, Financial_Account_Customer__c primaryFac) {
    	
    	if(primaryFac.Account__r.AKA__c == null || primaryFac.Account__r.AKA__c == '') {
            String cleanedAKA = substringTrimAndRemoveTrailingComma(noteObj.Notes_15__c);
            if( !TFSC_Utils.isNullOrEmpty(cleanedAKA) ) {
                primaryFac.Account__r.AKA__c = cleanedAKA;
                accountsToUpdateForAKA.add( primaryFac.Account__r );
            }
        }
    	
    }
    
    
    private String substringTrimAndRemoveTrailingComma(String str) {
    	if(!TFSC_Utils.isNullOrEmpty(str) && str.length() == 60) {
    		str = str.substring(5, 54);
            str = str.trim();
            Integer strLength = str.length() ;
            if(strLength > 0) {
            	String tmpBigOLogNSaverForLastCharacter = str.substring( strLength - 1, strLength );
            	if(tmpBigOLogNSaverForLastCharacter == ',') {
            		if(strLength == 1){
            			str = '';
            		}else{
            			str = str.substring(0, strLength - 1);
            		}
            	} 
            }
    	}
    	return str;
    }
    
    
    public static Map<String,String> statusMap = new Map<String,String>{
        '?' => '? - Unverified',
        'G' => 'G - Good Number (C,A)',
        'C' => 'C - Cell/Mobile (C-auth, B-no)',
        'L' => 'L - Land Line (C-valid, X-no)',
        'S' => 'S - Same as System (A, S)',
        'M' => 'M - Multiple Work Number',
        'D' => 'D - Disconnected (X)',
        'B' => 'B - Bad Number (X)',
        'T' => 'T - Toyota Financial/Vendor',
        'H' => 'H - DNC but Good (C,A)',
        'N' => 'N - Do Not Call Number (D, S)'
    };
    
    
    private Set<Id> generateFaListFromPF11List(List<PF11_Notes__c> newList) {
    	Set<Id> listToReturn = new Set<Id>();
    	for(PF11_Notes__c noteObj : newList) {
    		listToReturn.add( noteObj.Financial_Account__c );
    	}
    	
    	return listToReturn;
    }
    
    
    private Map<Id,PhoneFieldMarshaller> mapOfSkipTraceIdToPhoneMarshaller = new Map<Id,PhoneFieldMarshaller>();
    private Map<Id,Skip_Trace__c> buildSkipTraceMap(Set<Id> faIdSet) {
    	Map<Id,Skip_Trace__c> mapToReturn = new Map<Id,Skip_Trace__c>();
    	
    	for( Skip_Trace__c strace : [select Id, Financial_Account__c, name,
                    Phone1__c, Phone10__c, Phone11__c, Phone12__c, Phone13__c, Phone14__c, Phone15__c, 
                    Phone16__c, Phone17__c, Phone18__c, Phone19__c, Phone2__c, Phone20__c, Phone21__c,  
                    Phone22__c, Phone23__c, Phone24__c, Phone25__c, Phone26__c, Phone27__c, Phone28__c, Phone29__c, 
                    Phone3__c, Phone30__c, Phone31__c, Phone32__c, Phone33__c, Phone34__c, Phone35__c, Phone36__c, 
                    Phone37__c, Phone38__c, Phone39__c, Phone4__c, Phone40__c, Phone41__c, Phone42__c, 
                    Phone43__c, Phone44__c, Phone45__c, Phone46__c, Phone47__c, Phone48__c, Phone49__c, 
                    Phone5__c, Phone50__c, Phone6__c, Phone7__c, Phone8__c, Phone9__c
                                       from Skip_Trace__c
                                       where Financial_Account__c in :faIdSet] )
        {
        	mapToReturn.put(strace.Financial_Account__c, strace);
        	mapOfSkipTraceIdToPhoneMarshaller.put( strace.Id, new PhoneFieldMarshaller(strace) );
        }
    	
    	return mapToReturn;
    }
    
    
     
    private Map<Id,Financial_Account_Customer__c> buildMapOfFAIDtoFac(Set<Id> faIdSet) {
    	Map<Id,Financial_Account_Customer__c> mapToReturn = new Map<Id,Financial_Account_Customer__c>();
    	
    	for(Financial_Account_Customer__c fac : [select id, Financial_Account__c, Account__r.AKA__c,
    	                                           Financial_Account__r.RecordType.Name, Financial_Account__r.Financial_Account_Number__c
    	                                           from Financial_Account_Customer__c
    	                                           where Borrower_Position__c = 'Primary'
    	                                           and Financial_Account__c in :faIdSet
    	                                           and (not Financial_Account_Customer__c like '%Inactive%') ])
        {
        	mapToReturn.put(fac.Financial_Account__c, fac);
        }
    	
    	return mapToReturn;
    }
    
    
    private class PhoneFieldMarshaller {
    	
    	public Map<String,String> mapOfCleanedPhoneToField = new Map<String,String>();
    	public Set<String> usedFields = new Set<String>();
    	 
    	
    	public PhoneFieldMarshaller(Skip_Trace__c strace) {
    		for(Integer i=1; i<51; i++){
	            String strIteration = String.valueOf(i); 
	            String phoneFieldPrefix = 'Phone' + strIteration + '_';
	            String phoneFieldApiName = phoneFieldPrefix + '_c';
	            
	            String phoneNum = (String)strace.get(phoneFieldApiName);
	            
	            if( !TFSC_Utils.isNullOrEmpty(phoneNum) ) {
	            	phoneNum = phoneNum.replaceAll('[^0-9]','');
	            	if(phoneNum.length() > 0) {
	            		mapOfCleanedPhoneToField.put(phoneNum, phoneFieldApiName);
	            		usedFields.add(phoneFieldApiName);
	            	}
	            }
	        }
    	}
    	
    	public String getFirstUnusedFieldForUpdate() {
    		for(Integer i=1; i<51; i++){
    			String strIteration = String.valueOf(i);
                String phoneFieldApiName = 'Phone' + strIteration + '__c';
                if(!usedFields.contains(phoneFieldApiName)) {
                	return phoneFieldApiName;
                }
    		}
    		return null;
    	}
    }
    
    
    private class PhoneObject {
        
        public String phoneType1;
        public String phone1;
        public Date date1;
        public String status1;
        public String phoneType2;
        public String phone2;
        public Date date2;
        public String status2;
        
        public PhoneObject(List<String> strList) {
            setValsFromStringList(strList);
        }
        
        private void setValsFromStringList(List<String> strList) {
            if(strList.size() >= 2) {
                String str1 = strList[0];
                String str2 = strList[1];
                this.phoneType1 = TFSC_PF11NotesSkipTraceSyncHandler.getPhoneTypeFromAbrev( getSubstr(str1,5,6) );
                this.phone1     = getSubstr(str1,8,18);
                if(str1.length() > 22) {
                	this.date1 = TFSC_PF11NotesSkipTraceSyncHandler.getDateFromMMDDString(str1.substring(22).trim(), null);
                }
                this.status1    = TFSC_PF11NotesSkipTraceSyncHandler.statusMap.get( getSubstr(str1,19,20) );
                
                this.phoneType2 = TFSC_PF11NotesSkipTraceSyncHandler.getPhoneTypeFromAbrev( getSubstr(str2,1,2) );
                this.phone2     = getSubstr(str2,4,14);
                if(str2.length() > 18) {
                	this.date2  = TFSC_PF11NotesSkipTraceSyncHandler.getDateFromMMDDString(str2.substring(18).trim(), null);
                }
                this.status2    = TFSC_PF11NotesSkipTraceSyncHandler.statusMap.get(getSubstr(str2,15,16));
            }
        }
        
        private String getSubstr(String str, Integer fromx, Integer tox) {
        	String strToReturn = '';
        	
        	if(str.length() >= tox) {
        		strToReturn = str.substring(fromx,tox);
        	}
        	
        	return strToReturn;
        }
    }
    
    

}