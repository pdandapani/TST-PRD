/*
*  Instantiation of this class will run a query on Form_Rule_Validation_Junction__c, building mapOfFormRuleIdToValidationList
*  
*  The purpose is to take all records from Form_Rule_Validation_Junction__c and Form_Validation__c
*  and execute all hard and soft validations.  Then, either:
*    1) return a map of ValidationErrorMessages (see getDictionaryOfErrorMessages) 
*    --OR--
*    2) update an 'error' field for display. (see updateSObjectValidationErrorValues)
*
*  sObjects were used as inputs for future projects' use.
*  Also, I did not use sObject.addError becuase of the RL project's requirements.
*  If you need to use sObject.addError, call getDictionaryOfErrorMessages
*  (meaning: I tried to make this class as usable as possible for all potential future use-cases).
*
*  @Author     : Jeremy Mooer - Salesforce.com Services
*/
public with sharing class RL_RepossessionValidateDynamically {
    
    /*
    *   See comments on initValidationRuleMap() for map structure.  Also, updateSObjectValidationErrorValues will rebuild it to a specified sObject
    */
    private Map<Id,List<ValidationRule>> mapOfFormRuleIdToValidationList;
    public Map<Id,ValidationErrorMessages> errorMessagesMap;
    
    
    public RL_RepossessionValidateDynamically(String sobjectName) {
    	initValidationRuleMap(sobjectName, null);
    }
    public RL_RepossessionValidateDynamically() {
    	initValidationRuleMap('Repossession__c', null);
    }
    public RL_RepossessionValidateDynamically(String sObjectName, Id formRuleId) {
    	initValidationRuleMap('Repossession__c', new Set<Id>{formRuleId});
    }
    public RL_RepossessionValidateDynamically(String sObjectName, Set<Id> formRuleIdSet) {
    	initValidationRuleMap('Repossession__c', formRuleIdSet);
    }
    
    
    /*
    *   Use this overloaded method if you're not sure how to use this class.
    *   If you don't want the errors put onto the 'errorField' on the sobject, then look at getDictionaryOfErrorMessages.
    */
    public void updateSObjectValidationErrorValues(Set<Id> sobjIds, String sObjectName, String formRuleIdField, String errorField, Boolean executeUpdate) {
    	
    	//transform sobjIds into map queried records (objectsToValidateMap) with all DML-required fields.
    	Map<Id,sObject> objectsToValidateMap = getMapOfSObjectsBasedUponFieldsUsedInFormValidationRecords(sobjIds, sObjectName, formRuleIdField, errorField);
    	
    	updateSObjectValidationErrorValues(objectsToValidateMap, formRuleIdField, errorField, executeUpdate);
    }
    public void updateSObjectValidationErrorValues(Id sobjId, String sObjectName, String formRuleIdField, String errorField, Boolean executeUpdate) {
    	
    	Set<Id> sobjIds = new Set<Id>();
    	sobjIds.add(sobjId);
    	
    	updateSObjectValidationErrorValues(sobjIds, sObjectName, formRuleIdField, errorField, executeUpdate);
    }
    
    private Map<Id,sObject> getMapOfSObjectsBasedUponFieldsUsedInFormValidationRecords(Set<Id> sobjIds, String sObjectName, String formRuleIdField, String errorField) {
    	Map<String,String> uniqueFields = new Map<String,String>();
    	String fieldsToQuery = '';
    	uniqueFields.put(errorField.toLowerCase(), errorField); //adding the error field to query field list.
    	uniqueFields.put(formRuleIdField.toLowerCase(), formRuleIdField);
    	
    	for(List<ValidationRule> ruleList : mapOfFormRuleIdToValidationList.values()) {
	    	for(ValidationRule rule : ruleList) {
	    		if(rule.fieldName1 != null) {
	    			uniqueFields.put( rule.fieldName1.toLowerCase(), rule.fieldName1 );
	    		}
	    		if(rule.fieldName2 != null) {
	    			uniqueFields.put( rule.fieldName2.toLowerCase(), rule.fieldName2 );
	    		}
	    		if(rule.fieldName3 != null) {
	    			uniqueFields.put( rule.fieldName3.toLowerCase(), rule.fieldName3 );
	    		}
	    		if(rule.isValidationValAnSobjectFieldVal) {
	    			uniqueFields.put( rule.value1.toLowerCase(), rule.value1 );
	    		}
	    	}
    	}
    	
    	Integer i = 0;
    	for(String field : uniqueFields.keySet()) {
    		if(i > 0) {
    			fieldsToQuery += ', ';
    		}
    		fieldsToQuery += field;
    		i++ ;
    	}
    	
    	String queryString = 'SELECT ' + fieldsToQuery + ' FROM ' + sObjectName + ' where id in :sobjIds ' ;
    	Map<Id,sObject> objectsToValidateMap = new Map<Id,sObject>( database.query( queryString ) );
    	return objectsToValidateMap;
    }
    
    
    /*
    *  updateSObjectValidationErrorValues
    *  This method will loop through the list of objectsToValidateMap, and execute the related Form_Validation__c rules.
    * 
    *  objectsToValidateMap: list of sObjects to run validations upon.
    *  formRuleIdField: field name on the sObject that holds the Form_Rule__c ID value.
    *  errorField: field name on sObject record/s that will hold soft/hard validation errors.
    *  executeUpdate: should execute update after sObject.errorField values have changed? 
    *  
    */
    public void updateSObjectValidationErrorValues(Map<Id,sObject> objectsToValidateMap, String formRuleIdField, String errorField, Boolean executeUpdate) {
    	
    	List<sObject> listToUpdate = new List<sObject>();
    	
    	errorMessagesMap = getDictionaryOfErrorMessages(objectsToValidateMap.values(), formRuleIdField);
    	
    	
    	//for repos, need to clear the error string, so looping through them here instead of looping through errors:
    	ValidationErrorMessages errMsgObj;
    	for(sObject sObj : objectsToValidateMap.values()) {
    		errMsgObj = errorMessagesMap.get((Id)sObj.get('Id'));
    		if(errMsgObj != null) {
    			sObj.put(errorField, errMsgObj.fullErrorString);
    		}else{
    			sObj.put(errorField, '');
    		}
    	}
    	
    	
    	if(executeUpdate) {
    		update objectsToValidateMap.values();
    	}
    	
    }
    
    
    
    /*
    *  Initiates the map of Id to list of validation rules.
    *  Structure
    *  {
    *    //formRuleId : list of ValidationRule class instances,
    *    formRuleId : [ {ValidationRule Class}, {ValidationRule Class},... ],
    *    formRuleId : [ {ValidationRule Class}, {ValidationRule Class},... ],
    *  }
    */
    private void initValidationRuleMap(String sObjectName, Set<Id>formRuleIdSet) {
    	mapOfFormRuleIdToValidationList = new Map<Id,List<ValidationRule>>();
    	if(formRuleIdSet == null) {
    		for(Form_Rule_Validation_Junction__c junctionObj : [select Form_Validation__c, Form_Rule__c, Form_Validation__r.SObject__c,
															Form_Validation__r.Name, 
															Form_Validation__r.Error_Message__c, Form_Validation__r.RL_Value1__c, 
															Form_Validation__r.RL_Field_Name1__c, Form_Validation__r.RL_Operator1__c, 
															Form_Validation__r.RL_Value2__c, Form_Validation__r.RL_Field_Name2__c, 
															Form_Validation__r.RL_Operator2__c, Form_Validation__r.RL_Field2_Type__c,
															Form_Validation__r.RL_Field1_Type__c, Form_Validation__r.Hard_Error__c,
															Form_Validation__r.Is_Validation_Val_A_Field1__c,
															Form_Validation__r.RL_Value3__c, 
															Form_Validation__r.RL_Field_Name3__c, Form_Validation__r.RL_Operator3__c,
															Form_Validation__r.RL_Field3_Type__c
															from Form_Rule_Validation_Junction__c
															where Form_Validation__r.SObject__c = :sObjectName ] ) 
			{
				addRuleListToMap(junctionObj, mapOfFormRuleIdToValidationList);
	    	}
    	}else{
    		for(Form_Rule_Validation_Junction__c junctionObj : [select Form_Validation__c, Form_Rule__c, Form_Validation__r.SObject__c,
															Form_Validation__r.Name, 
															Form_Validation__r.Error_Message__c, Form_Validation__r.RL_Value1__c, 
															Form_Validation__r.RL_Field_Name1__c, Form_Validation__r.RL_Operator1__c, 
															Form_Validation__r.RL_Value2__c, Form_Validation__r.RL_Field_Name2__c, 
															Form_Validation__r.RL_Operator2__c, Form_Validation__r.RL_Field2_Type__c,
															Form_Validation__r.RL_Field1_Type__c, Form_Validation__r.Hard_Error__c,
															Form_Validation__r.Is_Validation_Val_A_Field1__c,
															Form_Validation__r.RL_Value3__c, 
															Form_Validation__r.RL_Field_Name3__c, Form_Validation__r.RL_Operator3__c,
															Form_Validation__r.RL_Field3_Type__c
															from Form_Rule_Validation_Junction__c
															where Form_Validation__r.SObject__c = :sObjectName
															and Form_Rule__c in :formRuleIdSet ] ) 
			{
				addRuleListToMap(junctionObj, mapOfFormRuleIdToValidationList);
	    	}
    	}
    }
    
    private void addRuleListToMap(Form_Rule_Validation_Junction__c junctionObj, Map<Id,List<ValidationRule>> mapOfFormRuleIdToValidationList) {
    	List<ValidationRule> repoList = mapOfFormRuleIdToValidationList.get(junctionObj.Form_Rule__c);
		if(repoList == null) {
			repoList = new List<ValidationRule>();
		}
		
		ValidationRule validationRule = new ValidationRule(junctionObj.Form_Validation__r);
		repoList.add(validationRule);
		mapOfFormRuleIdToValidationList.put(junctionObj.Form_Rule__c, repoList);
    }
    
    
    
    /*
    *  getDictionaryOfErrorMessages
    *  This method will loop through the list of objectsToValidate, and execute the related Form_Validation__c rules.
    *  It returns a map of Id to ValidationErrorMessages
    * 
    *  objectsToValidateMap: list of sObjects to run validations upon.
    *  formRuleIdField: field name on the sObject that holds the Form_Rule__c ID value.
    *
    *  structure of return map:
    *  {
    *     sobjectRecordId : ValidationErrorMessages,
    *     sobjectRecordId : ValidationErrorMessages,
    *  }
    *  
    */
    public Map<Id,ValidationErrorMessages> getDictionaryOfErrorMessages(List<sObject> objectsToValidate, String formRuleIdField) {
		Map<Id,ValidationErrorMessages> mapToReturn = new Map<Id,ValidationErrorMessages>();
		
		String hardErrors;
    	String softErrors;
    	List<ValidationRule> validationRules;
    	for(sObject sObj : objectsToValidate) {
    		softErrors = '';
    		hardErrors = '';
    		Id formRuleId = (Id)RL_RepossessionValidateDynamically.getSObjectFieldValue(sObj,formRuleIdField);
    		validationRules = mapOfFormRuleIdToValidationList.get( formRuleId ); //repo.Case__r.Form_Rule__c
    		if(validationRules == null) {
    			//break; don't break because we want hard-errors
    		}else{
    			for(ValidationRule rule : validationRules) {
	    			if( !rule.rulePasses(sObj) ) {
	    				if(rule.hardError) {
	    					hardErrors += rule.errorMessage + '\n';
	    				}else{
	    					softErrors += rule.errorMessage + '\n';
	    				}
	    			}
	    		}
    		}
    		
    		if(hardErrors.length() > 0 || softErrors.length() > 0) {
    			ValidationErrorMessages errObj = new ValidationErrorMessages(hardErrors, softErrors, (Id)sObj.get('Id'));
    			mapToReturn.put((Id)sObj.get('Id'), errObj);
    		}
    		
    	}
    	
    	return mapToReturn;
    	
    }
    
    
    /*
    *  the purpose of this is to dynamically give the ability to get both 'Id' on an sObject, and get 'Case__r.Form_Rule__c'
    *  consider it a DYNAMIC way of executing one of these:
    *    1) sObject.getSobject('Owner').getSobject('Profile').get('Name');
    *    OR
    *    2) sObject.get('Name');
    *  BY PASSING IN
    *    1) "Owner.Profile.Name"
    *    OR
    *    2) "Name"
    */
    public static Object getSObjectFieldValue(sObject sObj, String fieldName) {
    	Object value;
    	if(fieldName.contains('.')) {
    		List<String> fieldList = fieldName.split('\\.',0);
    		sObject tmpSobj = sObj;
    		Integer i = 0;
    		Integer fieldListLength = fieldList.size();
    		for(String field : fieldList){
    			i++;
    			//field = field.replace('__r', '__c');
    			if(i == fieldListLength) {
    				value = tmpSobj.get(field);
    			}else{
    				tmpSobj = tmpSobj.getSobject(field);
    			}
    		}
    	}else{
    		value = sObj.get(fieldName);
    	}
    	return value;
    }
    
    
    /*
    private void asdf() {
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType ctype = gd.get('Repossession__c'); 
		Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
    }
    */
    
    
    
    public class ValidationErrorMessages {
    	
    	public String hardErrors;
    	public String softErrors;
    	public Id recordId;
    	
    	public Boolean hasHardErrors {
    		get {
    			Boolean boolToReturn = false;
    			if(hardErrors != null && hardErrors.length() > 0) {
    				boolToReturn = true;
    			}
    			return boolToReturn;
    		}
    	}
    	
    	public Boolean hasSoftErrors {
    		get {
    			Boolean boolToReturn = false;
    			if(softErrors != null && softErrors.length() > 0) {
    				boolToReturn = true;
    			}
    			return boolToReturn;
    		}
    	}
    	
    	public String fullErrorString {
    		get {
    			String strToReturn = '';
    			if(hardErrors != null && hardErrors.length() > 0) {
    				strToReturn += RL_Constants.HARD_VALIDATION_MESSAGE + '\n';
    				strToReturn += hardErrors;
    			}
    			if(softErrors != null && softErrors.length() > 0) {
    				if(strToReturn.length() > 0) {
    					strToReturn += '\n';
    				}
    				strToReturn += RL_Constants.SOFT_VALIDATION_MESSAGE + '\n';
    				strToReturn += softErrors;
    			}
    			return strToReturn;
    		}
    	}
    	
    	public ValidationErrorMessages(String hardErr, String softErr, Id recordId) {
    		this.hardErrors = hardErr;
    		this.softErrors = softErr;
    		this.recordId = recordId;
    	}
    }
    
    
    public class ValidationRule {
    	
    	public String fieldName1;
    	public String fieldType1;
    	public String operator1;
    	public String value1;
    	private Object validationValue1;
    	private Boolean isValidationValAnSobjectFieldVal;
    	
    	
    	public String fieldName2;
    	public String fieldType2;
    	public String operator2;
    	public String value2;
    	private Object validationValue2;
    	
    	public String fieldName3;
    	public String fieldType3;
    	public String operator3;
    	public String value3;
    	private Object validationValue3;
    	
    	public String errorMessage;
    	public Boolean hardError;
    	public Boolean appliesToLease;
    	public Boolean appliesToRetail;
    	
    	
    	public ValidationRule() {
    		
    	}
    	public ValidationRule(Form_Validation__c validationRecord) {
    		
    		this.fieldName1 = validationRecord.RL_Field_Name1__c ;
    		this.operator1 = validationRecord.RL_Operator1__c ;
    		this.value1 = validationRecord.RL_Value1__c ;
    		this.fieldType1 = validationRecord.RL_Field1_Type__c ;
    		this.isValidationValAnSobjectFieldVal = validationRecord.Is_Validation_Val_A_Field1__c;
    		//if(!isValidationValAnSobjectFieldVal)
    		this.validationValue1 = getValidationValue(value1, fieldType1);
    		
    		
    		this.fieldName2 = validationRecord.RL_Field_Name2__c ;
    		this.operator2 = validationRecord.RL_Operator2__c ;
    		this.value2 = validationRecord.RL_Value2__c ;
    		this.fieldType2 = validationRecord.RL_Field2_Type__c ;
    		if(this.fieldName2 != null) {
    			this.validationValue2 = getValidationValue(value2, fieldType1);
    		}
    		
    		
    		this.fieldName3 = validationRecord.RL_Field_Name3__c ;
    		this.operator3 = validationRecord.RL_Operator3__c ;
    		this.value3 = validationRecord.RL_Value3__c ;
    		this.fieldType3 = validationRecord.RL_Field3_Type__c ;
    		if(this.fieldName3 != null) {
    			this.validationValue3 = getValidationValue(value3, fieldType3);
    		}
    		
    		this.errorMessage = validationRecord.Error_Message__c ;
    		this.hardError = validationRecord.Hard_Error__c;
    		//this.appliesToLease = (validationRecord.Applies_To_c != null && validationRecord.Applies_To_c.contains('Lease'));
    		//this.appliesToRetail = (validationRecord.Applies_To_c != null && validationRecord.Applies_To_c.contains('Retail'));
    	}
    	
    	public Boolean rulePasses(sObject sObj) {
    		
    		//Impound_Fee__c blank.
    		Boolean validationCondition1Triggered = false;
    		Object fieldValue1 = RL_RepossessionValidateDynamically.getSObjectFieldValue(sObj, fieldName1) ;
    		if(this.isValidationValAnSobjectFieldVal == true && this.value1 != null) {
    			validationValue1 = sObj.get(this.value1); //for when value1 is like 'CreatedDate' [isValidationValAnSobjectFieldVal == true]
    		}
    		if(checkIfConditionIsMet(fieldValue1, validationValue1, operator1, fieldType1)) {
    			validationCondition1Triggered = true;
    		}
    		
    		//IRepo_AssignmentType__c (null) = 'Impound'
    		Boolean andConditionEntered = false;
    		Boolean andConditionMet = false;
    		if(fieldName2 != null) {
    			andConditionEntered = true;
    			Object fieldValue2 = RL_RepossessionValidateDynamically.getSObjectFieldValue(sObj,fieldName2) ;
    			if(checkIfConditionIsMet(fieldValue2, validationValue2, operator2, fieldType2)) {
    				andConditionMet = true;
    			}
    		}
    		
    		Boolean andCondition2Entered = false;
    		Boolean andCondition2Met = false;
    		if(fieldName3 != null) {
    			andCondition2Entered = true;
    			Object fieldValue3 = RL_RepossessionValidateDynamically.getSObjectFieldValue(sObj,fieldName3) ;
    			if(checkIfConditionIsMet(fieldValue3, validationValue3, operator3, fieldType3)) {
    				andCondition2Met = true;
    			}
    		}
    		
    		Boolean rulePassesVal = finalRulePassBool(validationCondition1Triggered, andConditionEntered, andConditionMet, andCondition2Entered, andCondition2Met);
    		return rulePassesVal;
    	}
    	
    	private Boolean finalRulePassBool(Boolean validationCondition1Triggered, Boolean andConditionEntered, Boolean andConditionMet, Boolean andCondition2Entered, Boolean andCondition2Met) {
    		Boolean boolToReturn = true;
    		
    		if(validationCondition1Triggered && andConditionEntered == false && andCondition2Entered == false) {
    			boolToReturn = false;
    		}else if(validationCondition1Triggered && andConditionEntered == true && andConditionMet && andCondition2Entered == false) {
    			boolToReturn = false;
    		}else if(validationCondition1Triggered && andConditionEntered == true && andConditionMet && andCondition2Entered == true && andCondition2Met) {
    			boolToReturn = false;
    		}
    		
    		
    		return boolToReturn;
    	}
    	
    	private Boolean checkIfConditionIsMet(Object objectFieldValue, Object valudationValue, String operand, String fieldType) {
    		String substr = operand.substring(0,2);
    		Boolean conditionMet = false;
    		fieldType = fieldType.toUpperCase();
    		
    		System.debug('***** valudationValue  = ' + valudationValue);
			System.debug('***** objectFieldValue  = ' + objectFieldValue);
			System.debug('***** fieldType  = ' + fieldType);
    		
    		if(substr == '==') {
    			if(fieldType == 'NUMBER') {
    				System.debug('***** number val  = ' + objectFieldValue );
    				System.debug('***** validation val  = ' + valudationValue );
    				if(	((objectFieldValue == null || objectFieldValue == '') && (valudationValue == null || valudationValue == ''))
    					|| (objectFieldValue == valudationValue) ) 
					{
    					conditionMet = true;
    				}
    			}else if(fieldType == 'STRING') {
    				if( 
    					(valudationValue == null && objectFieldValue != null && objectFieldValue == '') || 
						(valudationValue != null && valudationValue == '' && objectFieldValue == null) ||
						(String.valueOf(valudationValue) == String.valueOf(objectFieldValue)) ) 
					{
						conditionMet = true;
					}
    			}else if( (valudationValue == objectFieldValue) || 
    			    (valudationValue == null && objectFieldValue != null && objectFieldValue == '') || 
    			    (valudationValue != null && valudationValue == '' && objectFieldValue == null)) {
    				conditionMet = true;
    				System.debug('***** conditionMet  = true' );
    			}
    		}else if(substr == '<>') {
    			if(valudationValue != objectFieldValue) {
    				conditionMet = true;
    			}
    		}else if(substr == '>=') {
    			//DateTime, Date, Number, Boolean, Picklist, String
    			if(fieldType == 'NUMBER') {
    				if( objectFieldValue != null) {
	    				Decimal tempNumGTEObjVal = (Decimal)objectFieldValue;
	    				Decimal tmpNumGTEValidationVal = (Decimal)valudationValue;
	    				if(tempNumGTEObjVal >= tmpNumGTEValidationVal) {
	    					conditionMet = true;
	    				}
	    			}
    			}else if(fieldType == 'DATE') {
    				if( objectFieldValue != null) {
    					Date tempDateGTERecord = date.valueOf(objectFieldValue);
    					Date tempDateGTEValidation;
    					if(valudationValue instanceOf Date) {
    						tempDateGTEValidation = (Date)valudationValue;
    					}else{
    						tempDateGTEValidation = date.valueOf((String)valudationValue);
    					}
    					if(tempDateGTERecord >= tempDateGTEValidation) {
    						conditionMet = true;
    					}
    				}
    			}else if(fieldType == 'DATETIME') {
    				if(objectFieldValue != null){
    					DateTime tempDtGteRecord = DateTime.valueOf(objectFieldValue);
    					DateTime tempDtGTEValidation;
    					if(valudationValue instanceOf Date) {
    						tempDtGTEValidation = (DateTime)valudationValue;
    					}else{
    						tempDtGTEValidation = dateTime.valueOf((String)valudationValue);
    					}
    					
    					if(tempDtGteRecord >= tempDtGTEValidation) {
    						conditionMet = true;
    					}
    				}
    			}
    		}else if(substr == '<=') {
    			if(fieldType == 'NUMBER') {
    				if( objectFieldValue != null) {
	    				Decimal tempNumLTEObjVal = (Decimal)objectFieldValue;
	    				Decimal tmpNumLTEValidationVal = (Decimal)valudationValue;
	    				if(tempNumLTEObjVal <= tmpNumLTEValidationVal) {
	    					conditionMet = true;
	    				}
	    			}
    			}else if(fieldType == 'DATE') {
    				if( objectFieldValue != null) { 
	    				Date tempDateLTERecord = date.valueOf(objectFieldValue);
    					Date tempDateLTEValidation;
    					if(valudationValue instanceOf Date) {
    						tempDateLTEValidation = (Date)valudationValue;
    					}else{
    						tempDateLTEValidation = date.valueOf((String)valudationValue);
    					}
    					if(tempDateLTERecord <= tempDateLTEValidation) {
    						conditionMet = true;
    					}
    				}
    			}else if(fieldType == 'DATETIME') {
    				if( objectFieldValue != null && DateTime.valueOf(objectFieldValue) <= DateTime.valueOf(valudationValue)) {
    					conditionMet = true;
    				}
    			}
    		}else if(substr == '> ') {
    			if(fieldType == 'NUMBER') {
    				if( objectFieldValue != null) {
	    				Decimal tempNumGteObjVal = (Decimal)objectFieldValue;
	    				Decimal tmpNumGteValidationVal = (Decimal)valudationValue;
	    				if(tempNumGteObjVal > tmpNumGteValidationVal) {
	    					conditionMet = true;
	    				}
	    			}
    			}else if(fieldType == 'DATE') {
    				if( objectFieldValue != null) {
    					Date tempDateGTRecord = date.valueOf(objectFieldValue);
    					Date tempDateGTValidation;
    					if(valudationValue instanceOf Date) {
    						tempDateGTValidation = (Date)valudationValue;
    					}else{
    						tempDateGTValidation = date.valueOf((String)valudationValue);
    					}
    					if(tempDateGTRecord > tempDateGTValidation) {
    						conditionMet = true;
    					}
    				}
    			}else if(fieldType == 'DATETIME') {
    				if(objectFieldValue != null && DateTime.valueOf(objectFieldValue) > DateTime.valueOf(valudationValue)) {
    					conditionMet = true;
    				}
    			}
    		}else if(substr == '< ') {
    			if(fieldType == 'NUMBER') {
    				
    				if( objectFieldValue != null) {
	    				Decimal tempNumLtObjVal = (Decimal)objectFieldValue;
	    				Decimal tmpNumLtValidationVal = (Decimal)valudationValue;
	    				if(tempNumLtObjVal < tmpNumLtValidationVal) {
	    					conditionMet = true;
	    				}
	    				conditionMet = true;
	    			}
    			}else if(fieldType == 'DATE') {
    				if( objectFieldValue != null) {
    					Date tempDateLTRecord = date.valueOf(objectFieldValue);
    					Date tempDateLTValidation;
    					if(valudationValue instanceOf Date) {
    						tempDateLTValidation = (Date)valudationValue;
    					}else{
    						tempDateLTValidation = date.valueOf((String)valudationValue);
    					}
    					if(tempDateLTRecord < tempDateLTValidation) {
    						conditionMet = true;
    					}
    				}
    			}else if(fieldType == 'DATETIME') {
    				if(objectFieldValue != null && DateTime.valueOf(objectFieldValue) < DateTime.valueOf(valudationValue)) {
    					conditionMet = true;
    				}
    			}
    		}else if(substr == 'IN') {
    			Set<String> inSet = (Set<String>)valudationValue;
    			if( inSet.contains( String.valueOf(objectFieldValue) ) ){
    				conditionMet = true;
    			}
    		}
    		
    		System.debug('***** conditionMet  = ' + conditionMet);
    		
    		return conditionMet;
    	}
    	
    	private Object getValidationValue(String val, String fieldType) {
    		Object objToReturn = null;
    		if(val != null && val != 'null' && val != '') {
    			String toUpper = val.toUpperCase();
    			if(toUpper == 'TODAY') {
    				if(fieldType == 'DateTime') {
    					Date dToday = date.Today();
						objToReturn = datetime.newInstance(dToday.year(), dToday.month(), dToday.day());
    				}else{
    					objToReturn = date.today();
    				}
    			}else if(toUpper == 'TRUE') {
    				objToReturn = true;
    			}else if(toUpper == 'FALSE') {
    				objToReturn = false;
    			}else if(val.substring(0,1) == '(') {
    				String tmpVal = val.trim();
    				tmpVal = tmpVal.substring(1) ;
    				tmpVal = tmpVal.substring(0,tmpVal.length()-1) ;
    				List<String> strList = tmpVal.split(',');
    				Set<String> finalSet = new Set<String>();
    				for(String tmpVal2 : strList) {
    					finalSet.add(tmpVal2.trim());
    				}
    				objToReturn = finalSet ;
    			}else if(val.isNumeric()) {
    				objToReturn = Decimal.valueOf(val) ;
    			}else{
    				objToReturn = val ;
    			}
    		}else{
    			//objToReturn = '';
    		}
    		
    		return objToReturn;
    	}
    	
    	
    }
    
}