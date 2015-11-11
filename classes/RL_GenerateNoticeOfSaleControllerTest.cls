@isTest
private class RL_GenerateNoticeOfSaleControllerTest {
    
    @isTest static void test_method_one() {
        //Setup Data
      Test.startTest();
      Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
      Id dealerRTId = RL_GenerateTestData.getRecordType('Account', 'Dealer');
      Account dealer = RL_GenerateTestData.createTestDealer(dealerRtId);
      
      Id retailRTId = RL_GenerateTestData.getRecordType('Financial_Account__c', 'Retail');        
      Financial_Account__c faRetail = RL_GenerateTestData.createFARetailIL(dealer, retailRTId);
      
      Collateral__c collateral = new Collateral__c(Name='Test Collateral');
      insert collateral;
      
      faRetail.Collateral__c = collateral.Id;
      update faRetail;
              
      Id caseRTId = RL_GenerateTestData.getRecordType('Case', 'Rights Letter');        
      Case aCase = RL_GenerateTestData.createCase(faRetail, caseRTId);  
      aCase.Form_Rule__c = formRuleMap.get('4015IL').Id;
      aCase.RL_System_Required_Notice_Date_Time__c = DateTime.now();
      update aCase;
      
      Repossession__c repo = RL_GenerateTestData.createRepossession(aCase, faRetail);     

      Form_Field__c formField = new Form_Field__c(Primary_FAC__c = FALSE, Source_Field__c='Financial_Account_Number__c', Source_Object__c='Financial_Account__c', Target_Field__c='AccountNumber__c');      
      insert formField;

      Case_Skills__c cs = RL_GenerateTestData.createCaseSkills();

      List<Form__c> formList = new Form__c[] {new Form__c(Copy_per_FAC__c = TRUE, Name='4028MD', Document_request_record_type__c=RL_Constants.DR_NOS_RT), new Form__c(Name=RL_Constants.COVER_LETTER_FORM, Document_request_record_type__c=RL_Constants.DR_RL_RT, Copy_per_FAC__c = TRUE)};
      insert formList;

      Form_Rule_Junction__c formRuleJunction2 = new Form_Rule_Junction__c(Form_Rule__c=formRuleMap.get('4028MD').Id, Form__c=formList[0].Id);
      insert formRuleJunction2;

      Form_Field_Junction__c ffJunction2 = new Form_Field_Junction__c(Form__c=formList[0].Id, Form_Field__c=formField.Id);
      insert ffJunction2;

      Id childCaseRT = RL_GenerateTestData.getRecordType('Case', 'RL Notice of Sale');  
      Case childCase = new Case(recordTypeId=childCaseRT, Financial_Account__c=faRetail.Id, ParentId=aCase.Id);
      childCase.Form_Rule__c = formRuleMap.get('4028MD').Id;
      childCase.RL_Physical_Sale_Date_1__c = Date.today() + 11;
      childCase.RL_Physical_Sale_Date_2__c = Date.today() + 12;
      childCase.RL_Online_Sale_1_From__c = Date.today() + 13;
      childCase.RL_Online_Sale_1_To__c = Date.today() + 14;
      childCase.RL_Online_Sale_2_From__c = Date.today() + 15;
      childCase.RL_Online_Sale_2_To__c = Date.today() + 16;
      childCase.RL_Physical_Sale_Time_1__c = '12:00 AM';
      childCase.RL_Physical_Sale_Time_2__c = '12:00 AM';
      childCase.RL_Auction_Agency_URL__c = 'www.iaai.com';
      insert childCase;
      System.debug('child case form rule: ' + childCase.Form_Rule__c);

      PageReference nosPageRef = Page.RL_GenerateNoticeOfSalePage;
      ApexPages.currentPage().getParameters().put('Id', childCase.Id);        
      ApexPages.StandardController caseStdController = new ApexPages.StandardController(childCase);
      RL_GenerateNoticeOfSaleController nosController = new RL_GenerateNoticeOfSaleController(caseStdController);
      Test.setCurrentPage(nosPageRef);
      nosController.generateNoticeOfSale();
      
      //Assertions
      Document_Request__c docRequest = [SELECT Id, Case__c FROM Document_Request__c WHERE Case__c =: childCase.Id];
      System.AssertEquals(docRequest.Case__c, childCase.Id);

      childCaseRT = RL_GenerateTestData.getRecordType('Case', 'RL Notice of Sale-Salvage');
      Case salvageChildCase = new Case(recordTypeId=childCaseRT, Financial_Account__c=faRetail.Id, ParentId=aCase.Id);
      salvageChildCase.Form_Rule__c = formRuleMap.get('4028MD').Id;
      salvageChildCase.RL_Salvage_Sale_Date_1__c = Date.today() + 11;
      salvageChildCase.RL_Salvage_Sale_Date_2__c = Date.today() + 12;
      salvageChildCase.RL_Salvage_Sale_Date_3__c = Date.today() + 13;
      salvageChildCase.RL_Salvage_Sale_Date_4__c = Date.today() + 14;
      salvageChildCase.RL_Salvage_Sale_Time_1__c = '12:00 AM';
      salvageChildCase.RL_Salvage_Sale_Time_2__c = '12:00 AM';
      salvageChildCase.RL_Salvage_Sale_Time_3__c = '12:00 AM';
      salvageChildCase.RL_Salvage_Sale_Time_4__c = '12:00 AM';
      insert salvageChildCase;

      ApexPages.currentPage().getParameters().put('Id', salvageChildCase.Id);        
      ApexPages.StandardController caseStdController2 = new ApexPages.StandardController(salvageChildCase);
      RL_GenerateNoticeOfSaleController nosController2 = new RL_GenerateNoticeOfSaleController(caseStdController2);
      Test.setCurrentPage(nosPageRef);
      nosController2.generateNoticeOfSale();        

      salvageChildCase.RL_Salvage_Sale_Time_1__c = null;
      salvageChildCase.RL_Salvage_Sale_Date_1__c = date.today();
      update salvageChildCase;
      nosController2.generateNoticeOfSale();  
      boolean errMsg = ApexPages.getMessages().get(0).getDetail().contains('Auction agency URL') ? true : false;
      System.assert(errMsg);            
      
      salvageChildCase.RL_Auction_Agency_URL__c = 'www.iaai.com';
      update salvageChildCase;
      nosController2.generateNoticeOfSale();  
      //errMsg = ApexPages.getMessages().get(1).getDetail().contains('Sale time fields are required') ? true : false;
      //System.assert(errMsg);

      salvageChildCase.RL_Salvage_Sale_Time_1__c = '12:00 AM';
      update salvageChildCase;
      nosController2.generateNoticeOfSale();  
      //errMsg = ApexPages.getMessages().get(2).getDetail().contains('greater than 10 days') ? true : false;
      //System.assert(errMsg);

/*      salvageChildCase.RL_Salvage_Sale_Date_1__c = null;
      update salvageChildCase;
      nosController2.generateNoticeOfSale();  
      //errMsg = ApexPages.getMessages().get(3).getDetail().contains('Sale date fields are required') ? true : false;
      //System.assert(errMsg);

      salvageChildCase.RL_Salvage_Sale_Date_1__c = date.today() + 11;
      salvageChildCase.RL_Salvage_Sale_Date_4__c = date.today() + 61;
      update salvageChildCase;
      nosController2.generateNoticeOfSale();  
      //errMsg = ApexPages.getMessages().get(4).getDetail().contains('more than 60 days') ? true : false;
      //System.assert(errMsg);

      salvageChildCase.RL_Salvage_Sale_Date_4__c = date.today() + 14;
      update salvageChildCase;    
*/
      Test.stopTest();
    }
}