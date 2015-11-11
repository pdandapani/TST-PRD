/*
@httpget - return value associated with key in KB_App_Settings__c custom setting
*/

@RestResource(urlMapping='/KmKeyValueWebService/v1/*')
global class KmKeyValueWebService {
	
	@httpGet
	global static KeyValueReply getValueForKey() {
		//return value based on Key for KmEngine
		RestRequest req = RestContext.request;
		if ( req <> null) {
			String key = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
			return getValueForKey(key);
		} else {
			return null;
		}
	}
	
	public static KeyValueReply getValueForKey(String key) {
		String value = 'cannot locate value for ' + key; //set an error message by default - then overwrite if no error
		KB_App_Settings__c kmEngineSettings = KB_App_Settings__c.getInstance(key);
	  	if (kmEngineSettings != null ) {
	  		value = kmEngineSettings.Value__c;
	  	}
	  	
	  	KeyValueReply reply = new KeyValueReply(key, value);
	  	return reply;
	}
	
	
	@httpPost
	global static List<KeyValueReply> getValuesForKeys(List<String> keys) {
		if ( keys == null) {
			return new List<KeyValueReply>();
		}
		List<KeyValueReply> reply = new List<KeyValueReply>();
		for(String key : keys) {
			KB_App_Settings__c kmEngineSettings = KB_App_Settings__c.getInstance(key);
			if ( kmEngineSettings <> null) {
				reply.add(new KeyValueReply(key, kmEngineSettings.Value__c));
			}
		}
		return reply;
	}
	
	/*
	@httpPatch 
	global static void updateValueForKey(String key, String value) {
		
	}

	
	@httpDelete
	global static String deleteKeyValuePair() {
		return '';
	}
	*/
	
	global class KeyValueReply {
		global String Key;
		global String Value;
		
		global KeyValueReply(String Key, String Value) {
			this.Key = Key;
			this.Value = Value;
		}
	}
}