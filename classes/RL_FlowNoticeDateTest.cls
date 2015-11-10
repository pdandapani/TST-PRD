/*****
 * Salesforce.com Success Services
 * Name: RL_FlowNoticeDateTest
 * Description: Test class for RL_FlowNoticeDate
 */

@isTest
private class RL_FlowNoticeDateTest {
	
	@isTest static void test_method_one() {
        Id bhId = RL_GenerateTestData.getBusinessHoursId();
        RL_GenerateTestData.createDSTPeriods();
	RL_GenerateTestData.createTimezoneIndicators();
        Map<String, Form_Rule__c> formRuleMap = RL_GenerateTestData.insertFormRuleData();
      
        RL_FlowNoticeDate plugin = new RL_FlowNoticeDate();
        Map<String, Object> inputParams = new Map<String, Object>();

        //Test Business Days
        DateTime repoDateTime = DateTime.valueOfGmt('2014-11-20 16:00:00');
        inputParams.put('Recovery Date/Time Text', repoDateTime.format());
        inputParams.put('Repossession Zip Code', '90210');
        inputParams.put('Rule Notice Calendar', formRuleMap.get('4015IL').Notice_calendar__c);
        inputParams.put('Rule time till notice', formRuleMap.get('4015IL').Time_Till_Notice__c); 
        inputParams.put('Non working-day rule', formRuleMap.get('4015IL').Non_working_day_rule__c);
        inputParams.put('Business Hours ID', bhId); 

        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result = plugin.invoke(request);
        DateTime requiredNoticeDateTime = DateTime.newInstanceGmt(2014, 11, 24, 16, 00, 00);

        System.assertEquals(result.outputParameters.get('Local Repo Date'), Date.newInstance(2014, 11, 20));
        System.assertEquals(result.outputParameters.get('Local Repo Date Time'), '11/20/14 08:00 AM PST');
        System.assertEquals(result.outputParameters.get('Required Notice Date Time'), requiredNoticeDateTime);
        System.assertEquals(result.outputParameters.get('Required Notice Date Text'), '11/24/14 08:00 AM PST');
        System.assertEquals(result.outputParameters.get('Service Level Date'), Date.newInstance(2014, 11, 24));

        //Test Calendar Days
        inputParams.put('Rule Notice Calendar', formRuleMap.get('4015GA').Notice_calendar__c);
        inputParams.put('Rule time till notice', formRuleMap.get('4015GA').Time_Till_Notice__c); 
        inputParams.put('Non working-day rule', formRuleMap.get('4015GA').Non_working_day_rule__c);

        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request);

        requiredNoticeDateTime = DateTime.newInstanceGmt(2014, 11, 28, 16, 00, 00);
        System.assertEquals(result.outputParameters.get('Required Notice Date Time'), requiredNoticeDateTime);
        System.assertEquals(result.outputParameters.get('Required Notice Date Text'), '11/28/14 08:00 AM PST');
        System.assertEquals(result.outputParameters.get('Service Level Date'), Date.newInstance(2014, 11, 26));        

        //Test Hours: Following
        inputParams.put('Rule Notice Calendar', formRuleMap.get('4015NY').Notice_calendar__c);
        inputParams.put('Rule time till notice', formRuleMap.get('4015NY').Time_Till_Notice__c); 
        inputParams.put('Non working-day rule', formRuleMap.get('4015NY').Non_working_day_rule__c);

        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request); 

        requiredNoticeDateTime = DateTime.newInstanceGmt(2014, 11, 24, 08, 00, 00);
        System.assertEquals(result.outputParameters.get('Required Notice Date Time'), requiredNoticeDateTime);
        System.assertEquals(result.outputParameters.get('Required Notice Date Text'), '11/24/14 12:00 AM PST');
        System.assertEquals(result.outputParameters.get('Service Level Date'), Date.newInstance(2014, 11, 24));         

        //Test Hours: Preceding
        inputParams.put('Rule Notice Calendar', formRuleMap.get('Test').Notice_calendar__c);
        inputParams.put('Rule time till notice', formRuleMap.get('Test').Time_Till_Notice__c); 
        inputParams.put('Non working-day rule', formRuleMap.get('Test').Non_working_day_rule__c);

        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request);

        requiredNoticeDateTime = DateTime.newInstanceGmt(2014, 11, 22, 07, 00, 00);
        System.assertEquals(result.outputParameters.get('Required Notice Date Time'), requiredNoticeDateTime);
        System.assertEquals(result.outputParameters.get('Required Notice Date Text'), '11/21/14 11:00 PM PST');
        System.assertEquals(result.outputParameters.get('Service Level Date'), Date.newInstance(requiredNoticeDateTime.year(), requiredNoticeDateTime.month(), requiredNoticeDateTime.day()));            

        //Test invalid Zip Codes
        inputParams.put('Repossession Zip Code', '1A2B3C');
        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request);        

        System.assertEquals(result.outputParameters.get('Local Repo Date Time'), 'Invalid iRepo Repo Zip');
        System.assertEquals(result.outputParameters.get('Required Notice Date Text'), 'Invalid iRepo Repo Zip');

        inputParams.put('Repossession Zip Code', '1');
        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request);        

        inputParams.put('Repossession Zip Code', '99951');
        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request);     

        inputParams.put('Repossession Zip Code', '1234');
        request = new Process.PluginRequest(inputParams);
        result = plugin.invoke(request);     

        System.assertEquals(result.outputParameters.get('Local Repo Date Time'), 'Invalid iRepo Repo Zip');
        System.assertEquals(result.outputParameters.get('Required Notice Date Text'), 'Invalid iRepo Repo Zip');        

        plugin.describe();          

	}
	
}