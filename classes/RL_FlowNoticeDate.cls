/*****
 * Salesforce.com Success Services
 * Name: RL_DetermineNoticeDate
 * Description: Determine the required notice date and pass it to the Set State Conditions flow
 */

global class RL_FlowNoticeDate implements Process.Plugin {

    // The main method to be implemented. The Flow calls this at runtime.
    global Process.PluginResult invoke(Process.PluginRequest request) {
        //Repossession Inputs
        String repoDateTime = (String) request.inputParameters.get('Recovery Date/Time Text');
        String repoZipCode = (String) request.inputParameters.get('Repossession Zip Code');

        //Form rule inputs
        String ruleNoticeCalendar = (String) request.inputParameters.get('Rule Notice Calendar');
        Double ruleTimeTillNotice = (Double) request.inputParameters.get('Rule time till notice');
        String nonWorkingDayRule = (String) request.inputParameters.get('Non working-day rule');

        //Business Hours input
        Id businessHoursId = (Id) request.inputParameters.get('Business Hours ID');

        //Outputs
        Map<String,Object> result;
        DateTime localDateTime = DateTime.parse(repoDateTime);
        String localDateTimeText = '';
        DateTime localRND = null;
        String requiredNoticeDateText = '';

        Double repoZip;
        try {
            repoZip = Double.valueOf(repoZipCode);
        } catch (Exception ex) {
            return invalidTimeZoneIndicator(new Map<String,Object>());
        }

        //Get TimeZone indicator row for the repossession zip code        
        TimeZone_Indicator__c theIndicator;
        if (repoZip < RL_Constants.LOWEST_ZIP_CODE) { //If the repoZip is below the TimeZone indicator table range - use the next higher record by lower zip range
            theIndicator = [SELECT Id, Timezone__c, Standard_GMT_Offset__c, Lower_Range_of_Zip_Code__c, Higher_Range_of_Zip_Code__c, Standard_Abbreviation__c, DST_Abbreviation__c 
                FROM TimeZone_Indicator__c WHERE Lower_Range_of_Zip_Code__c >= :repoZip
                ORDER BY Lower_Range_of_Zip_Code__c ASC LIMIT 1];
        } else if (repoZip > RL_Constants.HIGHEST_ZIP_CODE) { //If repoZip is above the timezone indicator table range - use the last zip code in the table
            theIndicator = [SELECT Id, Timezone__c, Standard_GMT_Offset__c, Lower_Range_of_Zip_Code__c, Higher_Range_of_Zip_Code__c, Standard_Abbreviation__c, DST_Abbreviation__c 
                FROM TimeZone_Indicator__c
                ORDER BY Higher_Range_of_Zip_Code__c DESC LIMIT 1];
        } else {
            try {
                theIndicator = [SELECT Id, Timezone__c, Standard_GMT_Offset__c, Lower_Range_of_Zip_Code__c, Higher_Range_of_Zip_Code__c, Standard_Abbreviation__c, DST_Abbreviation__c 
                    FROM TimeZone_Indicator__c WHERE Lower_Range_of_Zip_Code__c <= :repoZip
                    AND Higher_Range_of_Zip_Code__c >= :repoZip LIMIT 1];
                } catch (QueryException ex) {   //Zip code was not found in the timezone indicator table. Eg: 1234
                    return invalidTimeZoneIndicator(new Map<String,Object>());
                }
        }
        
        //Get TimeZone indicator row for the business calendar's timezone
        BusinessHours bh = [SELECT TimeZoneSidKey from BusinessHours where Id =: businessHoursId LIMIT 1];
        String timezoneSidKey = bh.TimeZoneSidKey;
        List<TimeZone_Indicator__c> offsetToCalendarIndicator = [SELECT Standard_GMT_Offset__c, Timezone__c FROM TimeZone_Indicator__c where Timezone__c =: timezoneSidKey LIMIT 1];
        Integer offsetToCalInteger = offsetToCalendarIndicator != null && offsetToCalendarIndicator.size()>0 ? Integer.ValueOf(offsetToCalendarIndicator[0].Standard_GMT_Offset__c) : 0;
        //Format repossession date in timezone corresponding to repossession zip code
        localDateTimeText = localDateTime.format(RL_Constants.DATE_FORMAT, (theIndicator.Timezone__c != null && theIndicator.Timezone__c.length() > 0) ? theIndicator.Timezone__c : RL_Constants.GMT_TIMEZONE);
        String localDateTimeStr = localDateTimeText.split(' ')[0];

        //Add Standard / Daylight Timezone abbreviation
        localDateTimeText = addDaylightAbbreviation(localDateTime, localDateTimeText, theIndicator);            
        
        localRND = localDateTime;
        //Add business days to the localDateTime
        if (ruleNoticeCalendar.equalsIgnoreCase(RL_Constants.NOTICE_CALENDAR_BUSINESS)) {
            localRND = convertToLocalRepoTimeOrGMT(localRND, theIndicator, offsetToCalInteger, false); 
            localRND = RL_Utility.AddBusinessDays(localRND.addDays(-1), Integer.valueOf(ruleTimeTillNotice), businessHoursId);

        //If Calendar days - add days and apply the non-working day rule
        }  else if (ruleNoticeCalendar.equalsIgnoreCase(RL_Constants.NOTICE_CALENDAR_CALENDAR)) {
            localRND = (localRND.addDays(-1)).addDays(Integer.valueOf(ruleTimeTillNotice));
            localRND = convertToLocalRepoTimeOrGMT(localRND, theIndicator, offsetToCalInteger, false); 
            while (!BusinessHours.isWithin(businessHoursId, localRND)) {
                if (nonWorkingDayRule.equalsIgnoreCase(RL_Constants.PRECEDING)) {
                    localRND = localRND.addDays(-1);
                } else if (nonWorkingDayRule.equalsIgnoreCase(RL_Constants.FOLLOWING)) {
                    localRND = localRND.addDays(1);
                }
            }

        //If Hours - add Hours and apply the non-working day rule    
        } else if (ruleNoticeCalendar.equalsIgnoreCase(RL_Constants.NOTICE_CALENDAR_HOURS)) {
            localRND = localDateTime.addHours(Integer.valueOf(ruleTimeTillNotice));
            localRND = convertToLocalRepoTimeOrGMT(localRND, theIndicator, offsetToCalInteger, false); 
            while (!BusinessHours.isWithin(businessHoursId, localRND)) {
                if (nonWorkingDayRule.equalsIgnoreCase(RL_Constants.PRECEDING)) {
                    localRND = localRND.addHours(-1);
                } else if (nonWorkingDayRule.equalsIgnoreCase(RL_Constants.FOLLOWING)) {
                    localRND = localRND.addHours(1);
                }
            }
        }

        //Convert the local date/time Back to GMT
        localRND = convertToLocalRepoTimeOrGMT(localRND, theIndicator, offsetToCalInteger, true); 

        //Compute required Service Level Date
        DateTime requiredServiceLevel = RL_Utility.AddBusinessDays(localDateTime-1, 5, businessHoursId);
        Date requiredServiceLevelDate = requiredServiceLevel < localRND ? Date.newInstance(requiredServiceLevel.year(), requiredServiceLevel.month(), requiredServiceLevel.day()) : Date.newInstance(localRND.year(), localRND.month(), localRND.day());

        //Add Standard / Daylight Timezone abbreviation
        requiredNoticeDateText = addDaylightAbbreviation(localRND, localRND.format(RL_Constants.DATE_FORMAT, theIndicator.Timezone__c != null ? theIndicator.Timezone__c : RL_Constants.GMT_TIMEZONE), theIndicator);      

        //Store outputs in result map
        result = new Map<String,Object>();
        //Date ld = Date.parse(localDateTimeStr);          /**** Commented as per fix according to INC0796241, CHG0046258 ****/
        Date ld = getDateFromString(localDateTimeText);         /**** Implemented as per fix according to INC0796241, CHG0046258 ****/
        result.put('Local Repo Date', ld);
        result.put('Local Repo Date Time', localDateTimeText);
        result.put('Required Notice Date Time', localRND);
        result.put('Required Notice Date Text', requiredNoticeDateText);
        result.put('Service Level Date', requiredServiceLevelDate);
        return new Process.PluginResult(result);
    }
    
    private Date getDateFromString(String dateString) {
      //MM/dd/YY
      List<String> strList = dateString.split('/');
      String monthStr = strList[0];
      String dayStr = strList[1];
      String yearStr = '20' + strList[2];
      yearStr = yearStr.substring(0,4);
      
      if(dayStr.substring(0,1) == '0') {
        dayStr = dayStr.substring(1);
      }
      if(monthStr.substring(0,1) == '0') {
        monthStr = monthStr.substring(1);
      }
      
      Integer dayInt = Integer.valueOf(dayStr);
      Integer monthInt = Integer.valueOf(monthStr);
      Integer yearInt = Integer.valueOf(yearStr);
      
      Date dateToReturn = Date.newinstance(yearInt, monthInt, dayInt);
      return dateToReturn;
    }
    
    
    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 

        result.Name = 'flowNoticeDatePlugin';
        result.Tag = 'noticeDate';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
                new Process.PluginDescribeResult.InputParameter('Recovery Date/Time Text',
                Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Repossession Zip Code',
                Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Rule Notice Calendar',
                Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Rule time till notice',
                Process.PluginDescribeResult.ParameterType.DOUBLE, true),
                new Process.PluginDescribeResult.InputParameter('Non working-day rule',
                Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Business Hours ID',
                Process.PluginDescribeResult.ParameterType.ID, true)

            }; 
        result.outputParameters = new 
           List<Process.PluginDescribeResult.OutputParameter> { new Process.PluginDescribeResult.OutputParameter('Local Repo Date', 
               Process.PluginDescribeResult.ParameterType.DATE),
           new Process.PluginDescribeResult.OutputParameter('Local Repo Date Time', 
               Process.PluginDescribeResult.ParameterType.STRING),
           new Process.PluginDescribeResult.OutputParameter('Required Notice Date Time', 
               Process.PluginDescribeResult.ParameterType.DATETIME),
           new Process.PluginDescribeResult.OutputParameter('Required Notice Date Text', 
               Process.PluginDescribeResult.ParameterType.STRING),
           new Process.PluginDescribeResult.OutputParameter('Service Level Date', 
               Process.PluginDescribeResult.ParameterType.DATE)
       }; 
        return result;     
    }

    // Adds Standard / Daylight savings abbreviation to a formatted DateTime string
    private String addDaylightAbbreviation(DateTime localDateTime, String localDateTimeText, TimeZone_Indicator__c theIndicator) {
        //Add daylight savings Abbreviation if it is in effect for the repossession date
        String strToAppend = '';
        List<Dailight_Savings_Periods__c> dstPeriods = Dailight_Savings_Periods__c.getall().values();
        for (Dailight_Savings_Periods__c dst : dstPeriods) {
            if (dst.Start_Date__c <= localDateTime && dst.End_Date__c >= localDateTime) {
                if (dst.Dailight_Savings_In_Effect__c) {
                    strToAppend = theIndicator.DST_Abbreviation__c;                    
                } else {
                    strToAppend = theIndicator.Standard_Abbreviation__c;
                }
            }
        }  
        localDateTimeText += strToAppend;
        return localDateTimeText;
    }

    //Converts GMT repo time to local repo time (as per repossession zip code)
    private DateTime convertToLocalRepoTimeOrGMT(DateTime localDateTime, TimeZone_Indicator__c theIndicator, Integer offsetToCalInteger, Boolean convertToGMT) {
        localDateTime = convertToGMT ? localDateTime.addHours(Integer.valueOf(theIndicator.Standard_GMT_Offset__c) * -1 + offsetToCalInteger) : localDateTime.addHours(Integer.valueOf(theIndicator.Standard_GMT_Offset__c) - offsetToCalInteger);
        return localDateTime;
    }

    //Returns invalid Repo Zip to the flow
    private Process.PluginResult invalidTimeZoneIndicator(Map<String,Object> result) {
        result.put('Local Repo Date', null);
        result.put('Local Repo Date Time', 'Invalid iRepo Repo Zip');
        result.put('Required Notice Date Time', null);
        result.put('Required Notice Date Text', 'Invalid iRepo Repo Zip');
        result.put('Service Level Date', null);
        return new Process.PluginResult(result);   
    }

    public class ZipCodeException extends Exception {}
}