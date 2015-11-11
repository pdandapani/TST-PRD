
var CTI_EVENT_GENERIC = "genericCtiEvent";
var CTI_EVENT_CONSOLE_MANAGER_READY = "consoleManagerReadyCtiEvent";
var CTI_CLICK_TO_DIAL_EXECUTED_FROM_SFDC = "clickToDialExecutedFromSfdcEvent";
var CTI_PHONE_ANSWERED = "phoneAnsweredCtiEvent";

//Event message will hold [faId + CONSOLE_MESSAGE_PROPERTY_DELIMITER + interactionId] string
var CTI_DIALED_AND_TABS_SYNCED_NOW_SENDING_INTERACTIONID_AND_FAID = "dialedSyncedAndNowSendingInteractionIdAndFaid";
var CTI_PUSH_TAB_OBJECT_FROM_MANAGER = "pushTabObjectFromManagerEvent";
var CTI_PUSH_LAST_INTERACTION_OBJECT_FROM_MANAGER = "pushTabObjectFromManagerEvent";

var CONSOLE_EVENT_RIGHT_PANEL_LOADED = "consoleRightPanelLoadedEvent";

var CONSOLE_EVENT_FA_POPPED = "consoleFaPoppedEvent"; //NEW FOR THE URL_Parameter_Handler____
var CONSOLE_EVENT_NEW_FA_OPENED = "consoleNewFaOpenedEvent";
var CONSOLE_EVENT_FA_TAB_ID_RETRIEVED = "consoleFaTabIdRetrievedEvent";
var CONSOLE_EVENT_FA_TAB_CLOSED = "consoleFaTabClosedEvent";
var CONSOLE_EVENT_SOFT_PHONE_EXCEPTION_OPENED = "consoleSoftPhoneExcOpened";
var CONSOLE_EVENT_CONSOLE_MAN_DISPATCHED_LAST_FANUM = "consoleSendLastFANum";

var CONSOLE_EVENT_ON_SAVE_ACTIVITY_UPDATE_SOFTPHONE_WITH_DETAILS = "consoleOnActivitySaveUpdateSoftPhone";
var CONCOLE_EVENT_CONSOLIDATED_NOTES_UPDATE = "ConsolidatedNotesUpdateEvent";
var CONSOLE_EVENT_SKIP_TRACE_SAVED_AND_OPEN_CASE_EDITED = "consoleEventSkipTraceSavedAndOpenCaseEdited";
var CONSOLE_EVENT_JS_NUMBER_DIALED = "consoleEventJsNumberDialed";
var CONSOLE_EVENTS_LAST_INTERACTION_IS_ROUTED_WITH_NO_ACCOUNT = "consoleLastIntIsRoutedWithNoAcct";

//RM - 10/21/2014 - US512
var CONSOLE_EVENT_INBOUND_ROUTED_CALL_RECEIVED = "consoleEventInboundRoutedCallReceived";
var CONSOLE_EVENTS_ON_NEXT_ACCT_AFTER_INBOUND_ERROR_SYNC = "consoleEvtSyncTNextAcctAfterInboundError";


function cleanPhoneNumberOfNonNumericCharacters(phoneNumString) {
    var strToReturn = phoneNumString.replace(new RegExp('[^0-9]', 'g'), '');
    if(strToReturn.length == 11 && strToReturn.slice(0,1) == '1') {
    	strToReturn = strToReturn.slice(1);
    }
    return strToReturn;
}


var CONSOLE_MESSAGE_PROPERTY_DELIMITER = '/|';
function buildConsoleEventString(faId, faAcctNum) {
    var strToReturn = '';
    var delimiter = CONSOLE_MESSAGE_PROPERTY_DELIMITER;
    if(faId) {
        strToReturn += faId;
    }
    
    strToReturn += delimiter;
    if(faAcctNum) {
        strToReturn += faAcctNum;
    }
    
    return strToReturn;
}

function getConsoleEventObjectFromString(str) {
    var objToReturn = {};
    var strArray = [];
    if(str && str.length > 2) {
       strArray = str.split(CONSOLE_MESSAGE_PROPERTY_DELIMITER);
    }
    
    if(strArray.length > 0) {
        objToReturn.faId = strArray[0];
    }
    
    if(strArray.length > 1) {
        objToReturn.faAcctNum = strArray[1];
    }
    
    return objToReturn;
}




function buildLastInteractionObject(faid, interactionId, phoneDialed, campaignId) {
    var obj = {};
    obj.faId = faid;
    obj.interactionId = interactionId;
    obj.phoneDialed = phoneDialed;
    obj.campaignId = campaignId;
    
    return obj;
}

function buildTabObjectThatOpenedTab(relatedSoftPhoneData, interactionId, faId) {
    var obj = {};
    obj.relatedSoftPhoneData = relatedSoftPhoneData;
    obj.relatedParentSoftPhoneData = null;
    obj.interactionId = interactionId;
    obj.faId = faId;
    
    return obj;
}


function stringifyObjectForEventMessage(obj) {
    var stringToReturn = JSON.stringify(obj);
    return stringToReturn;
}

function deStringifyObjectFromEventMessageString(str) {
    var objToReturn = JSON.parse(str);
    return objToReturn;
}


function buildCtiAnchorString(phoneNumber, phonetype, mobilePhoneUrl, enableClickToDial, faid, acctNum) {
    var stringToReturn;
    var closingString;
    if(enableClickToDial === 'false'){
        stringToReturn = '<span class="customPhoneAnchorTag" ';
        closingString = "</span>";
    }  else{
        stringToReturn = '<a class="customPhoneAnchorTag" ';
        stringToReturn += 'onclick="dialFromCustomAnchorTag(this)" href="#" ';
        closingString = "</a>";
    }
    var cleanedPhoneNum = '';
    if(phoneNumber != null && phoneNumber.length > 0) {
        cleanedPhoneNum = cleanPhoneNumberOfNonNumericCharacters(phoneNumber);
        stringToReturn += "cleanedNum='" + cleanedPhoneNum + "' ";
        stringToReturn += "faid='" + faid + "' ";
        stringToReturn += "acctNum='" + acctNum + "' ";
        stringToReturn += "keyedPhoneNum='" + phoneNumber + "' ";
        stringToReturn += ">" + phoneNumber; 
        if(mobilePhoneUrl && phonetype && phonetype == 'Mobile') {
            stringToReturn += ' <img src="' + mobilePhoneUrl + '" />';
        }
        + closingString;
        
        
    }else{
        stringToReturn += "cleanedNum=''>" + closingString;
    }
    
    //console.log('RESULT_stringToReturn = ' + stringToReturn);
    return stringToReturn;
}

function dialFromCustomAnchorTag(anchorThis) {
    //going to avoid jquery, just in case resource is included on page without it.
    var cleanedPhoneNum = anchorThis.getAttribute('cleanedNum');
    var faid = anchorThis.getAttribute('faid');
    var acctNum = anchorThis.getAttribute('acctNum');
    
    if(typeof updateLastCalledTimeStamp == 'function') {
    	updateLastCalledTimeStamp(cleanedPhoneNum);
    }
    
    //console.log('In dialFromCustomAnchorTag');
    try {
        if(cleanedPhoneNum && cleanedPhoneNum.length > 0) {
            if(sforce.console.isInConsole()){
                //sforce.console.fireEvent(CONSOLE_EVENT_JS_NUMBER_DIALED, faid + '--' + cleanedPhoneNum + '--' + acctNum);
            }
            var argsObj = {};
                argsObj.destination = cleanedPhoneNum;
            aria.api.voice.dial(argsObj);
        }
    }
    catch(err) {}
    
    return false; //for preventing href="#"
}




