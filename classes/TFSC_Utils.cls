public with sharing class TFSC_Utils {
    
    
    private static Map<Id,Profile> parsedProfileMap;
    public static String getProfileNameFromProfileId(Id profileId) {
        
        if(parsedProfileMap == null) {
            parsedProfileMap = new Map<Id,Profile>( [select id,name from Profile limit 1000] );
        }
        String strToReturn;
        Profile selectedProfile = parsedProfileMap.get(profileId);
        if(selectedProfile != null) {
            strToReturn = selectedProfile.Name;
        }
        return strToReturn;
        
    }
    
    private static Map<String,RecordType> parsedRecordTypeMap;
    public static Id getRecordTypeIdFromDeveloperNameAndsObjectName(String developerName, String sObjectName) {
        
        if(parsedRecordTypeMap == null) {
            parsedRecordTypeMap = new Map<String,RecordType>();
            for(RecordType rt : [select id, DeveloperName, Name, SobjectType from RecordType where IsActive = true limit 1000]) {
                parsedRecordTypeMap.put(rt.SobjectType + '_' + rt.DeveloperName, rt);
            }
        }
        
        Id idToReturn;
        RecordType requestedRt = parsedRecordTypeMap.get( sObjectName + '_' + developerName );
        if(requestedRt != null) {
            idToReturn = requestedRt.Id;
        }
        return idToReturn;
    }
    
    private static Map<String,RecordType> parsedRecordTypeMapByName;
    public static Id getRecordTypeIdFromNameAndsObjectName(String name, String sObjectName) {
        Id idToReturn;
        if( !isNullOrEmpty(name) && !isNullOrEmpty(sObjectName) ) {
            
            if(parsedRecordTypeMapByName == null) {
                parsedRecordTypeMapByName = new Map<String,RecordType>();
                for(RecordType rt : [select id, DeveloperName, Name, SobjectType from RecordType where IsActive = true limit 1000]) {
                    parsedRecordTypeMapByName.put(rt.SobjectType + '_' + rt.Name, rt);
                }
            }
            
            
            RecordType requestedRt = parsedRecordTypeMapByName.get( sObjectName + '_' + name );
            if(requestedRt != null) {
                idToReturn = requestedRt.Id;
            }
        }
        
        return idToReturn;
        
    }
    
    
    public static Financial_Account_Customer__c getPrimaryFinancialAccountCustomer(String financialAccountId) {
        Financial_Account_Customer__c facToReturn;
        
        try {
            facToReturn = [select id, Financial_Account__c, Borrower_Position__c, Account__c, 
                                    Account__r.Name, Account__r.IsPersonAccount, Account__r.Tax_Identification_Number__c, 
                                    Account__r.Social_Security_Number__pc, Account__r.RecordType.Name, 
                                    Financial_Account__r.RecordType.Name,
                                    Account__r.AKA__c,
                                    Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                                    Flag_Home_Phone_IsMobile_BillTo__c, Flag_Work_Phone_Is_Mobile_BillTo__c,
                                    Flag_Home_Phone_IsMobile_Garage__c,
                                    Election_Language_Preference__c, HomePhone_BillTo__c,
                                    Home_Phone_Garage__c, Home_Phone_No_Call_Reason_Code_Garage__c,
                                    Home_Phone_No_Call_Reason_Code_BillTo__c, Mobile_Phone__c,
                                    Mobile_Phone_No_Call_Reason_Code__c, Work_Phone_Bill_To__c,
                                    Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                                    Work_Phone_No_Call_Reason_Code_Bill_To__c, Mailing_Street_BillTo__c, Mailing_City_BillTo__c,
                                    Mailing_State_BillTo__c, Mailing_CountryCode_BillTo__c, Mailing_PostalCode_BillTo__c, Mailing_Street_Garage__c, Mailing_City_Garage__c,
                                    Mailing_State_Garage__c, Mailing_Country_Code_Garage__c, Mailing_Postal_Code_Garage__c
                                   from Financial_Account_Customer__c
                                   where Borrower_Position__c = 'Primary'
                                   and Financial_Account__c = :financialAccountId
                                   and (not Financial_Account_Customer__c like '%Inactive%')  
                                   limit 1]; 
        }
        catch (Exception e) {
            
        }
        
        
        return facToReturn;
    }
    
    
    
    public static Financial_Account_Customer__c getCoBorrowerFinancialAccountCustomer(String financialAccountId) {
        
        Financial_Account_Customer__c facToReturn;
        try {
            Financial_Account_Customer__c[] facList;
            facList = [select id, Financial_Account__c, Borrower_Position__c, Account__c, 
                        Account__r.Name, Account__r.IsPersonAccount, Account__r.Tax_Identification_Number__c, 
                        Account__r.Social_Security_Number__pc, Account__r.RecordType.Name,
                        Financial_Account__r.RecordType.Name, 
                        Account__r.AKA__c,
                        Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                        Flag_Home_Phone_IsMobile_BillTo__c, Flag_Work_Phone_Is_Mobile_BillTo__c,
                        Flag_Home_Phone_IsMobile_Garage__c,
                        Election_Language_Preference__c, HomePhone_BillTo__c,
                        Home_Phone_Garage__c, Home_Phone_No_Call_Reason_Code_Garage__c,
                        Home_Phone_No_Call_Reason_Code_BillTo__c, Mobile_Phone__c,
                        Mobile_Phone_No_Call_Reason_Code__c, Work_Phone_Bill_To__c,
                        Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                        Work_Phone_No_Call_Reason_Code_Bill_To__c, Mailing_Street_BillTo__c, Mailing_City_BillTo__c,
                        Mailing_State_BillTo__c, Mailing_CountryCode_BillTo__c, Mailing_PostalCode_BillTo__c, Mailing_Street_Garage__c, Mailing_City_Garage__c,
                        Mailing_State_Garage__c, Mailing_Country_Code_Garage__c, Mailing_Postal_Code_Garage__c
                       from Financial_Account_Customer__c
                       where Borrower_Position__c = 'Co-X'
                       and Financial_Account__c = :financialAccountId  
                       and (not Financial_Account_Customer__c like '%Inactive%')
                       limit 1];
            
            if(facList != null && facList.size() > 0) {
                    facToReturn = facList[0];
            }
                
        }
        catch (Exception e) {
        }
        
        return facToReturn;
    }
    
    
    public static Financial_Account_Customer__c getCoBorrowerFinancialAccountCustomerFromPhoneNumber(String financialAccountId, String phoneNumber) {
        Financial_Account_Customer__c facToReturn;
        
        if(phoneNumber == null || phoneNumber == '') {
            facToReturn = getPrimaryFinancialAccountCustomer(financialAccountId);
        }else{
            facToReturn = getPrimaryFinancialAccountCustomer(financialAccountId);
        }
        
        
        return facToReturn;
    }
    
    public static Financial_Account_Customer__c getFinancialAccountCustomer(String financialAccountCustomerId) {
        
        Financial_Account_Customer__c facToReturn;
        try {
            Financial_Account_Customer__c[] facList;
            facList = [select id, Financial_Account__c, Borrower_Position__c, Account__c, 
                        Account__r.Name, Account__r.IsPersonAccount, Account__r.Tax_Identification_Number__c, 
                        Account__r.Social_Security_Number__pc, Account__r.RecordType.Name,
                        Financial_Account__r.RecordType.Name, 
                        Account__r.AKA__c,
                        Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                        Flag_Home_Phone_IsMobile_BillTo__c, Flag_Work_Phone_Is_Mobile_BillTo__c,
                        Flag_Home_Phone_IsMobile_Garage__c,
                        Election_Language_Preference__c, HomePhone_BillTo__c,
                        Home_Phone_Garage__c, Home_Phone_No_Call_Reason_Code_Garage__c,
                        Home_Phone_No_Call_Reason_Code_BillTo__c, Mobile_Phone__c,
                        Mobile_Phone_No_Call_Reason_Code__c, Work_Phone_Bill_To__c,
                        Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                        Work_Phone_No_Call_Reason_Code_Bill_To__c, Mailing_Street_BillTo__c, Mailing_City_BillTo__c,
                        Mailing_State_BillTo__c, Mailing_CountryCode_BillTo__c, Mailing_PostalCode_BillTo__c, Mailing_Street_Garage__c, Mailing_City_Garage__c,
                        Mailing_State_Garage__c, Mailing_Country_Code_Garage__c, Mailing_Postal_Code_Garage__c
                       from Financial_Account_Customer__c
                       where Id = :financialAccountCustomerId
                       and (not Financial_Account_Customer__c like '%Inactive%')
                       limit 1];
            
            if(facList != null && facList.size() > 0) {
                    facToReturn = facList[0];
            }
                
        }
        catch (Exception e) {
        }
        
        return facToReturn;
    }
    
    public static List<Financial_Account_Customer__c> getAllFACsForFinancialAccount(Id faid) {
        
        List<Financial_Account_Customer__c> facList = [select Work_Phone_No_Call_Reason_Code_Bill_To__c, 
                                                       Mobile_Phone_No_Call_Reason_Code__c, Home_Phone_No_Call_Reason_Code_BillTo__c,
                                                       Home_Phone_No_Call_Reason_Code_Garage__c, 
                                                       Flag_Work_Phone_Is_Mobile_BillTo__c, Work_Phone_Bill_To__c, Mobile_Phone__c,
                                                       Work_Phone_Garage__c, Work_Phone_NoCall_Reason_Code_Garage__c,
                                                       Flag_Work_Phone_IsMobile_Garage__c,Flag_Mobile_Phone_IsMobile__c,
                                                       Flag_Home_Phone_IsMobile_Garage__c,
                                                       Flag_Home_Phone_IsMobile_BillTo__c, HomePhone_BillTo__c, Financial_Account__c,
                                                       Home_Phone_Garage__c,
                                                       Mailing_Postal_Code_Garage__c
                                                       from Financial_Account_Customer__c
                                                       where (Borrower_Position__c = 'Co-X' or Borrower_Position__c = 'Primary')
                                                       and Financial_Account__c = :faid
                                                       and (not Financial_Account_Customer__c like '%Inactive%') ];
        
        
        return facList;
    }
    
    
    public static Activity_Code__c getActivityCodeByName(String activityCodeName) {
        
        Activity_Code__c activityToReturn;
        try {
            Activity_Code__c[] activityCodesList = 
            [
                SELECT
                        Id,
                        Name,
                        Flag_Notes_Required__c,
                        Flag_Promise_Required__c
                FROM
                        Activity_Code__c
                WHERE 
                        Name = :activityCodeName
                LIMIT 
                        1
            ];
            
            if(activityCodesList != null && activityCodesList.size() > 0) {
                    activityToReturn = activityCodesList[0];
            }
                
        }
        catch (Exception e) {
        }
        
        return activityToReturn;
    }
    
    public static Boolean isWeekendDay(Date dateParam){
        
        Boolean result = false;

        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = startOfWeek.daysBetween(dateParam);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        return result;
    } 
    
    
    public static Date addBusinessDays(Date StartDate, integer businessDaysToAdd ){
        
        //Add or decrease in businessDaysToAdd days 
        Date finalDate = StartDate;
        Integer direction = businessDaysToAdd < 0 ? -1 : 1;

        while(businessDaysToAdd != 0){
            finalDate = finalDate.AddDays(direction);            

            If (!isWeekendDay(finalDate)){
                
                businessDaysToAdd -= direction;
                
            }
        }

        return finalDate;
    }
    
    public static Date getLimitDate(Date startingDate, Integer numberOfDays){
        
        Date theoriticalLimitDate = startingDate.addDays(numberOfDays);
        Integer dayOfTheWeek = getDayOfTheWeek(theoriticalLimitDate);
        if(dayOfTheWeek > 0 && dayOfTheWeek < 6){
            return theoriticalLimitDate;
        }else{
            // If the date is a Sunday, the limit is the monday after: Add one day
            if(dayOfTheWeek == 0)
                return theoriticalLimitDate.addDays(1);
            // If the date is a Saturday, the limit is the monday after: Add two days
            else
                return theoriticalLimitDate.addDays(2);
        }
    }
    
    public static Integer getDayOfTheWeek(Date varDate){
    
        Date startOfTheWeek = varDate.toStartOfWeek();
        return startOfTheWeek.daysBetween(varDate);
    
    }
    
    public static Boolean isNullOrEmpty(String str) {
        if(str == null || str.length() == 0) {
            return true;
        }
        return false;
    }
    
    public static Boolean isNotNullAndNotEmpty(String str) {
        if(str != null && str.length() > 0) {
            return true;
        }
        return false;
    }
    
    public static sObject createSObjectFromTypeName(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            return null; //or probably throw exception
        }
        
        return targetType.newSObject(); 
    }
    
    public static String getValueOrEmpty(String initialString){
        if(initialString != null)
            return initialString;
        else
            return '';
    }
    
    public static String formatPromiseForNote(String datePromise, String methodPromise, String amountPromise, String confirmationPromise){
        String note = '';
        if(isNullOrEmpty(datePromise) && isNullOrEmpty(amountPromise) && (methodPromise.equals(TFSC_Constants.PICKLIST_NONE_VALUE) || isNullOrEmpty(methodPromise))){
            note = '';
        }else{
        
            note += 'PTP: ' + getValueOrEmpty(amountPromise)
                    + ' on ' + getValueOrEmpty(datePromise)
                    + ' via ' + methodPromise + '.';
            
            if(methodPromise.equals(TFSC_Constants.PTP_METHOD_WUCQ_CODE) && !isNullOrEmpty(confirmationPromise)){
                note += ' MTCN# ' + confirmationPromise + '.';
            }else{
                note += ' Conf# ' + confirmationPromise + '.';
            }
        }
        
        return note;
    }
    
    public static String getGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(b);
        String guid = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' 
        + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        system.debug(guid);
        return guid;    
    }
    
    public static List<Boolean> getListDisplayFACNumbers(Financial_Account_Customer__c topSecFAC){
        
        Boolean isTimeZoneEnable = getEnablePhoneNumberDependingOnTimeZone(topSecFAC.Mailing_Postal_Code_Garage__c, Date.today()); 
        if(!isTimeZoneEnable){
            return new List<Boolean>{false, false, false};
        }
        List<Boolean> resultDisplayFACNumbers = new List<Boolean>{true, true, true};
        // Set enabled/disabled Home Phone
        //Check NCRC code
        if('D'.equals(topSecFAC.Home_Phone_No_Call_Reason_Code_Garage__c) || 'S'.equals(topSecFAC.Home_Phone_No_Call_Reason_Code_Garage__c) || 'A'.equals(topSecFAC.Home_Phone_No_Call_Reason_Code_Garage__c)){
            resultDisplayFACNumbers.set(0, false);
        }
        
        // Set enabled/disabled Mobile Phone
        //Check NCRC code
        if('D'.equals(topSecFAC.Mobile_Phone_No_Call_Reason_Code__c) || 'S'.equals(topSecFAC.Mobile_Phone_No_Call_Reason_Code__c) || 'A'.equals(topSecFAC.Mobile_Phone_No_Call_Reason_Code__c)){
            resultDisplayFACNumbers.set(1, false);
        }
        
        // Set enabled/disabled Work Phone
        //Check NCRC code
        if('D'.equals(topSecFAC.Work_Phone_NoCall_Reason_Code_Garage__c) || 'S'.equals(topSecFAC.Work_Phone_NoCall_Reason_Code_Garage__c) || 'A'.equals(topSecFAC.Work_Phone_NoCall_Reason_Code_Garage__c)){
            resultDisplayFACNumbers.set(2, false);
        }
        
        return resultDisplayFACNumbers;
    }
    
    public static Boolean getEnablePhoneNumberInSkipTraceTable(String phoneStatus){

                if(phoneStatus != null && phoneStatus.length() > 0){
                    String firstLetter = phoneStatus.substring(0, 1);
                    
                    if('H'.equals(firstLetter) || 'N'.equals(firstLetter)){
                        return false;
                    }
                }
                return true;

    }
    
    public static Boolean getEnablePhoneNumberDependingOnTimeZone(String zipCode, Date currentDate){
        
        Integer currentHourGMT = Datetime.now().hourGmt();
        Integer currentMinuteGMT = Datetime.now().minuteGmt();

        if(zipCode != null){
            // Get the timezone
            Integer shortZipCode;
            if(zipCode.length() <= 5)
                shortZipCode = Integer.valueOf(zipCode);
            else
                shortZipCode = Integer.valueOf(zipCode.substring(0, 5));
                
            
            TimeZone_Indicator__c timezoneIndicator = getTimeZoneIndicatorForTimeZone(shortZipCode);
            
            if(timezoneIndicator != null) {
                List<String> gtmFrom, gtmTill;
                String gtmFromString, gtmTillString;
                Boolean isDailightSavingPeriod = isDailightSavingsPeriod(currentDate);
                if(timezoneIndicator.Observe_Daylight_Saving__c && isDailightSavingPeriod){
                    
                    gtmFromString = timezoneIndicator.GMT_From_With_Daylight_Saving__c;
                    gtmTillString = timezoneIndicator.GMT_Till_With_Daylight_Saving__c; 
                    gtmFrom = gtmFromString.split(':');
                    gtmTill = gtmTillString.split(':');
                }else{
                    gtmFromString = timezoneIndicator.GMT_From_Without_Daylight_Saving__c;
                    gtmTillString = timezoneIndicator.GMT_Till_Without_Daylight_Saving__c;
                    gtmFrom = gtmFromString.split(':');
                    gtmTill = gtmTillString.split(':');
                }
                
                // Lower hour:min of range
                Integer minCallingHourGMT = Integer.valueOf(gtmFrom.get(0).trim());
                Integer minCallingMinuteGMT = Integer.valueOf(gtmFrom.get(1).trim());
                    
                // Higher hour:min of range
                Integer maxCallingHourGMT = Integer.valueOf(gtmTill.get(0).trim());
                Integer maxCallingMinuteGMT = Integer.valueOf(gtmTill.get(1).trim());
                
                System.debug('STEVIE_getEnablePhoneNumberDependingOnTimeZone minCallingHourGMT = ' + minCallingHourGMT 
                    + '; minCallingMinuteGMT = ' + minCallingMinuteGMT
                    + '; maxCallingHourGMT = ' + maxCallingHourGMT
                    + '; maxCallingMinuteGMT = ' + maxCallingMinuteGMT
                    + '; currentHourGMT = ' + currentHourGMT
                    + '; currentMinuteGMT = ' + currentMinuteGMT
                );
                // the gmt from is lower than gmt_till, then current time must be betwwen gtm_from and gtm_till
                if( (minCallingHourGMT < maxCallingHourGMT) || (minCallingHourGMT == maxCallingHourGMT && minCallingMinuteGMT < maxCallingMinuteGMT) ){
                
                    if(
                        (currentHourGMT > minCallingHourGMT || (currentHourGMT == minCallingHourGMT && currentMinuteGMT > minCallingMinuteGMT))
                        &&
                        (currentHourGMT < maxCallingHourGMT || (currentHourGMT == maxCallingHourGMT && currentMinuteGMT < maxCallingMinuteGMT))
                    ){
                        return true;
                    }else{
                        return false;
                    }
                
                }else{
                    // the gmt from is lower than gmt_till, then current time must NOT be betwwen gtm_from and gtm_till. Instead it must go around the clock
                    // Eg: gtm_from = 20:45 and gtm_till = 2:45, then the current time must not be between 2:45 and 20:45, but between 00:00 to 2:45 OR 20:45 to 00:00
                    if(
                        !(
                            (currentHourGMT < minCallingHourGMT || (currentHourGMT == minCallingHourGMT && currentMinuteGMT < minCallingMinuteGMT))
                            &&
                            (currentHourGMT > maxCallingHourGMT || (currentHourGMT == maxCallingHourGMT && currentMinuteGMT > maxCallingMinuteGMT))
                        )
                    ){
                        return true;
                    }else{
                        return false;
                    }
                
                }
            }
        }
        
        return true;
    }
    
    public static TimeZone_Indicator__c getTimeZoneIndicatorForTimeZone(Integer shortZipCode) {
        
        TimeZone_Indicator__c tzToReturn;
        
        if(shortZipCode != null) {
            
            List<TimeZone_Indicator__c> listOfTimeZoneIndicators = new List<TimeZone_Indicator__c>(
                    [
                            SELECT
                                        GMT_From_With_Daylight_Saving__c,
                                        GMT_Till_With_Daylight_Saving__c,
                                        GMT_From_Without_Daylight_Saving__c,
                                        GMT_Till_Without_Daylight_Saving__c,
                                        Timezone__c,
                                        Standard_Abbreviation__c,
                                        Timezone_Indicator__c,
                                        Observe_Daylight_Saving__c
                                        
                            FROM
                                        TimeZone_Indicator__c
                            WHERE
                                        Higher_Range_of_Zip_Code__c >= :shortZipCode
                                        AND
                                        Lower_Range_of_Zip_Code__c <= :shortZipCode
                    ]
            );
            
            if(listOfTimeZoneIndicators != null && listOfTimeZoneIndicators.size() > 0) {
                tzToReturn = listOfTimeZoneIndicators.get(0);
            }
            
        }
        
        return tzToReturn;
        
    }
    
    public static Boolean isDailightSavingsPeriod(Date currentDate){
        
        List<Dailight_Savings_Periods__c> listOfDSPeriods = new List<Dailight_Savings_Periods__c>(
                [
                        SELECT
                                Name,
                                Dailight_Savings_In_Effect__c
                        FROM
                                Dailight_Savings_Periods__c
                        WHERE
                                Start_Date__c <= :currentDate
                                AND
                                End_Date__c >= :currentDate
                ]
        );
        
        if(listOfDSPeriods.size() > 0){
            return listOfDSPeriods.get(0).Dailight_Savings_In_Effect__c;
        }else{
            return false;
        }
        
    }
    
    public static Decimal getDecimalCurrencyValue(String currencyAmount){
        if(currencyAmount != null){
            Pattern dollarPattern = Pattern.compile('[,$]');

            //replace all occurrences in a string
            String currentAmountVal = dollarPattern.matcher(currencyAmount).replaceAll('');
            if(currentAmountVal.length() > 0)
                return Decimal.valueOf(currentAmountVal.trim());
            else
                return 0;
        }
        return 0;
    }
    
    
    public class ValidatePhoneNumber {
        public String isValid(String phoneNbr) {
            String errorStr = '';
            String areaCode = phoneNbr.substring(0,3);
            String restOfNbr = phoneNbr.substring(3);
            
            // Invalid patterns
            // X11
            // X33
            // 0XX
            // 1XX
            // 37X
            // 96X
            // XXX555XXXX
            // XXX958XXXX
            // XXX959XXXX
            // 800855XXXX
            // XXX1111111
            // XXX2222222
            // XXX3333333
            // XXX4444444
            // XXX5555555
            // XXX6666666
            // XXX7777777
            // XXX8888888
            // XXX9999999
            // XXX0000000
            List<Invalid_Area_Codes__c> invalidAreaCodes = Invalid_Area_Codes__c.getAll().values();
            for (Integer i = 0; i < invalidAreaCodes.size(); i++) {
                Invalid_Area_Codes__c thisAreaCode = invalidAreaCodes[i];
                if (areaCode == thisAreaCode.Area_Code__c) {
                    if (TFSC_Utils.isNullOrEmpty(thisAreaCode.Reason_Invalid__c)) {
                        errorStr += 'The phone number you\'ve entered contains an invalid area code. ';
                    } else {
                        errorStr += thisAreaCode.Reason_Invalid__c;
                    }
                }
            }
            
            if (errorStr == '') {
                if (Pattern.matches('(^[0,1].+)|(^96.)|(^37.)|(^[0-9](11|33))', areaCode)) {
                    errorStr += 'The phone number you\'ve entered contains an invalid area code. ';
                }
                if (Pattern.matches('(^555.+|^958.+|^959.+)', restOfNbr)) {
                    errorStr += 'The phone number you\'ve entered is invalid. ';
                }
                if (Pattern.matches('(0{7}|1{7}|2{7}|3{7}|4{7}|6{7}|7{7}|8{7}|9{7})', restOfNbr)) {
                    errorStr += 'The phone number you\'ve entered is invalid. ';
                }
                
                if (areaCode == '800' && Pattern.matches('(^855.+)', restOfNbr)) {
                    errorStr += 'The phone number you\'ve entered is invalid. ';
                }
            
                if (!(errorStr == '')) {
                    errorStr += 'Click save to continue.';
                }
            }
            
            return errorStr;
        }
    }
    
    
    

}