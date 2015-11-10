/**
* @author       Benjamin Lau
* @date         09/30/2014
* @description  PrintJobTrigger - invoke BinderModel.PrintJobTriggerHandler to start print job
*
**/
trigger PrintJobTrigger on PrintJob__c (after insert) {
   	BinderModel.PrintJobTriggerHandler(Trigger.new);
}