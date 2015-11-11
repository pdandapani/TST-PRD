@IsTest
public class KmKeyValueWebServiceTest {

	@IsTest
	public static void UnitTest() {
		CreateData();		
	
		KmKeyValueWebService.getValueForKey();
		KmKeyValueWebService.getValueForKey('test');
		
		KmKeyValueWebService.getValuesForKeys(null);
		List<String> keys = new List<String>();
		KmKeyValueWebService.getValuesForKeys(keys);
		keys.add('key1');
		keys.add('key2');
		
		KmKeyValueWebService.getValuesForKeys(keys);
	}
	
	public static void CreateData() {
		List<KB_App_Settings__c> settings = new List<KB_App_Settings__c>();
		
		settings.add( createSetting('test', 'testValue'));
		settings.add( createSetting('key1', 'testValue'));
		settings.add( createSetting('key2', 'testValue'));
		insert settings;
	}
	
	public static KB_App_Settings__c createSetting(String key, String value) {
		KB_App_Settings__c setting = new KB_App_Settings__c();
		setting.name = key;
		setting.value__c = value;
		return setting;
	}
}