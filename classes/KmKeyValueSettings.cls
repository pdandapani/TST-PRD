public class KmKeyValueSettings {
	
	//KmKeyValueSettings.ProdSetupCustomSettings();   <==== should be used for FULL2 as well 
	public static void ProdSetupCustomSettings() {
		List<KB_App_Settings__c> delSettings = [select id from KB_App_Settings__c];
		delete delSettings;
		
		List<KB_App_Settings__c> settings = new List<KB_App_Settings__c>();
			
		settings.add(createSetting('kmEngineArticleToPdfUrl',
			'https://intsvcs.services.toyotafinancial.com/SFDCweblinkKM/kmArticleToPdf'));
			
		settings.add(createSetting('kmEnginePrintBinderBaseDir',
			'd:\\kmbinders\\'));
			
		settings.add(createSetting('kmEnginePrintBinderUrl',
			'https://intsvcs.services.toyotafinancial.com/SFDCweblinkKM/kmPdfMerger?printJobName='));
			
		settings.add(createSetting('kmEngineReadBinderURL',
			'http://xpvwwb0155.tfs.toyota.com/KMbinders/'));
			
		settings.add(createSetting('sfDocUseProxy','true'));
		settings.add(createSetting('internetLinkUseProxy','true'));
		settings.add(createSetting('kmEngineDebug','false'));
		settings.add(createSetting('kmEnginePrintStackTrace','false'));
		
		insert settings;
	}


	public static void LinuxSetupCustomSettings() {
		List<KB_App_Settings__c> delSettings = [select id from KB_App_Settings__c];
		delete delSettings;
		
		List<KB_App_Settings__c> settings = new List<KB_App_Settings__c>();
		
		KB_App_Settings__c setting1 = createSetting('kmEngineArticleToPdfUrl',
			'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmArticleToPdf');
			
		KB_App_Settings__c setting2 = createSetting('kmEnginePrintBinderBaseDir',
			'/opt/local/crectjba/');
		KB_App_Settings__c setting3 = createSetting('kmEnginePrintBinderUrl',
			'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmPdfMerger?printJobName=');
		KB_App_Settings__c setting4 = createSetting('kmEngineReadBinderURL',
			'https://extapptest.services.toyotafinancial.com/SFDCweblinkKM/kmGetPdf?pdfFileName=');
		
		KB_App_Settings__c setting5 = createSetting('sfDocUseProxy','true');
		KB_App_Settings__c setting6 = createSetting('internetLinkUseProxy','true');
		
		settings.add(setting1);
		settings.add(setting2);
		settings.add(setting3);
		settings.add(setting4);
		settings.add(setting5);
		settings.add(setting6);
		settings.add(createSetting('kmEngineDebug','false'));
		settings.add(createSetting('kmEnginePrintStackTrace','false'));
		
		insert settings;
	}


	private static KB_App_Settings__c createSetting(String name, String value ) {
		KB_App_Settings__c result = new KB_App_Settings__c();
		result.name = name;
		result.value__c = value;
		return result;
	}
}