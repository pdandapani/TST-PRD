@isTest
private class RL_RepossessionValidateDynamicTest {

    static testMethod void testValidationRules() {
        
        
        List<Form_Validation__c> validations = generateListOfValidations();
        insert validations;
        
        RL_GenerateTestData.createTimezoneIndicators();
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
        Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
        Account dealer = RL_GenerateTestData.createTestDealer(dealerRTId);

        Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');
        Id leaseRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Lease');
        Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
        faRetail.Collection_List_Number_1__c = '1812';
        update faRetail;
        Financial_Account__c faLease = RL_GenerateTestData.createFALeaseIL(dealer, leaseRTId);        

        // Create Case
        Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
        Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);
        aCase.Form_Rule__c = formRuleMap.get('4015IL').Id;
        update aCase;

        // Create Repossession
        Id repoRTId = RL_GenerateTestData.getRecordType('Repossession__c', 'RL Retail-Generic');
        Repossession__c repo = RL_GenerateTestData.createRepossession(aCase, faRetail, repoRTId);
        
        
        List<Form_Rule_Validation_Junction__c> junctionObjs = new List<Form_Rule_Validation_Junction__c>(); 
        for(Form_Validation__c v1 : validations) {
        	junctionObjs.add( new Form_Rule_Validation_Junction__c(Form_Rule__c = formRuleMap.get('4015IL').Id, Form_Validation__c = v1.Id) );
        }
        insert junctionObjs;
        
        
        Date badDate = date.today();
        repo.Local_Repo_Date__c = badDate;
        //repo.Collection_List_Number_1__c = '1812';
        repo.iRepo_RepoState__c = 'NV';
        update repo;
        
        Map<Id,Repossession__c> repoMap = new Map<Id,Repossession__c>();
        repo = [select id, Case__r.Form_Rule__c, Account_Terminated__c, Local_Repo_Date__c,
        			Conditional_Reinstatement__c, Personal_Property_Fee__c,
        			iRepo_RepoState__c, United_Road_Transport_Fees__c, Salvage__c,
        			Impound_Fee__c, irepo_assignmenttype__c,
        			RepoLocationName__c, Title_Full_Address__c
        		from Repossession__c where id = :repo.id] ;
        repoMap.put(repo.Id, repo);
        Set<Id> repoListForValidation = new Set<Id>();
        repoListForValidation.add(repo.Id);
        
        
        Test.startTest();
        	
        	RL_RepossessionValidateDynamically validationClass = new RL_RepossessionValidateDynamically();
        	//validationClass.updateSObjectValidationErrorValues(repoMap, 'Case__r.Form_Rule__c', 'Validation_Issues__c', true);
        	validationClass.updateSObjectValidationErrorValues(repoListForValidation, 'Repossession__c', 'Case__r.Form_Rule__c', 'Validation_Issues__c', true);
        	
        Test.StopTest();
        
    }
    
    private static Form_Validation__c generateFormValidation(Boolean hardErr, String errMsg,
    									String fieldName1, String fieldType1, String operator1, String value1,
    									String fieldName2, String fieldType2, String operator2, String value2) {
    	
    	Form_Validation__c validation = new Form_Validation__c(
    	    Error_Message__c = errMsg, Hard_Error__c = hardErr, 
    	    RL_Field_Name1__c = fieldName1, RL_Field_Name2__c = fieldName2, 
    	    RL_Field1_Type__c = fieldType1, RL_Field2_Type__c = fieldType2, 
    	    RL_Operator1__c = operator1, RL_Operator2__c = operator2, 
    	    RL_Value1__c = value1, RL_Value2__c = value2 ,
    	    SObject__c = 'Repossession__c'
    	);
    	
    	return validation; 
    }
    
    private static List<Form_Validation__c> generateListOfValidations() {
    	List<Form_Validation__c> listToReturn = new List<Form_Validation__c>();
    	
    	//DateTime, Date, Number, Boolean, Picklist, String
    	// == (Equal To), <> (Not Equal To), >= Greater Than or Equal To, >= Greater Than or Equal To, > (Greater Than), < (Less Than), IN 
    	
    	listToReturn.add( generateFormValidation(false, 'error occurred', 'Account_Terminated__c', 'Boolean', '<> (Equal To)', 'TRUE', null, null, null, null) );
    	listToReturn.add( generateFormValidation(false, 'error occurred', 'Salvage__c', 'Boolean', '== (Equal To)', 'FALSE', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '>= (Greater than or EQ2)', 'TODAY', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '<= (LTE)', 'TODAY', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '== (EQ)', 'TODAY', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '>  (GT)', 'TODAY', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '< (LT)', 'TODAY', null, null, null, null) );
    	
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '>= (Greater than or EQ2)', 'TODAY', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '<= (LTE)', '2010-10-10', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '== (EQ)', '2010-10-10', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '>  (GT)', '2010-10-10', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Local_Repo_Date__c', 'Date', '< (LT)', '2020-10-10', null, null, null, null) );
    	
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Conditional_Reinstatement__c', 'String', '==', '', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Conditional_Reinstatement__c', 'String', '<>', 'asdf', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Personal_Property_Fee__c', 'Number', '< (Greater than)', '100', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Personal_Property_Fee__c', 'Number', '> (Greater than)', '100', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Personal_Property_Fee__c', 'Number', '== (Greater than)', '100', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Personal_Property_Fee__c', 'Number', '>= (Greater than)', '100', null, null, null, null) );
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'Personal_Property_Fee__c', 'Number', '<= (Greater than)', '100', null, null, null, null) );
    	
    	//Transportation Expenses = Blank AND [Recovery State is not CT] 
    	listToReturn.add( generateFormValidation(true, 'error occurred', 'United_Road_Transport_Fees__c', 'Number', '== (equal)', '', 'iRepo_RepoState__c', 'String', '<>', 'CT') );
    	
    	//listToReturn.add( generateFormValidation(false, 'error occurred', 'Impound_Fee__c', 'Number', '== (Equal To)', '', 'IRepo_AssignmentType__c', 'String', '==', 'Impound') );
    	listToReturn.add( generateFormValidation(false, 'error occurred', 'Impound_Fee__c', 'Number', '== (Equal To)', '', null, null, null, null) );
    	
    	//[Vehicle Location does not match Titles Services Address AND salvage checkbox = false]
    	Form_Validation__c fv = generateFormValidation(false, 'error occurred', 'RepoLocationName__c', 'String', '== (Equal To)', 'Title_Full_Address__c', 'Salvage__c', 'Boolean', '== ', 'false');
    	fv.Is_Validation_Val_A_Field1__c = true;
    	listToReturn.add( fv );
    		
    	return listToReturn;
    }
}