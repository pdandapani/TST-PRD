<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <flowActions>
        <fullName>Change_Control_Backend_Processing</fullName>
        <description>This is part of Change Control process and the flow submits backend processing to next group (Training and/or KM) team</description>
        <flow>Change_Control_Backend_Processing_V3</flow>
        <flowInputs>
            <name>vCaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <label>Change Control - Backend Processing</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>RL_Close_Parent_Case</fullName>
        <flow>RL_Close_Parent_Case</flow>
        <flowInputs>
            <name>sRLChildCase</name>
            <value>{!this}</value>
        </flowInputs>
        <label>RL Close Parent Case</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>RL_Create_Child_Quality_Review_Case</fullName>
        <flow>RL_Create_Rights_Letter_Quality_Review_Case</flow>
        <flowInputs>
            <name>sRLParentCase</name>
            <value>{!this}</value>
        </flowInputs>
        <label>RL Create Child Quality Review Case</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Update_Children_Cases</fullName>
        <description>Updates all children cases when Parent case owner is changed,</description>
        <flow>Change_Control_Update_Child_Cases</flow>
        <flowInputs>
            <name>vCaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>vChangeOwner</name>
            <value>True</value>
        </flowInputs>
        <flowInputs>
            <name>vOwnerId</name>
            <value>{!OwnerId}</value>
        </flowInputs>
        <label>Update Children Cases</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Update_Parent_Case_Approval_Count</fullName>
        <description>This flow subtracts by one and updates Parent case approval count for Change Control Case</description>
        <flow>KM_Update_Approval_Count</flow>
        <flowInputs>
            <name>vNewApprovaCount</name>
            <value>{!Parent.KM_approval_Count__c}</value>
        </flowInputs>
        <flowInputs>
            <name>vParentCaseId</name>
            <value>{!Parent.Id}</value>
        </flowInputs>
        <label>Update Parent Case Approval Count</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Update_children_Cases_Change_Status_Submitted_for_Approval</fullName>
        <description>Change Control - When Parent Case status is changed to Closed - Cancelled or On Hold and prior value is Submitted for Approval, this flow updates all children Case status to &quot;Closed - Cancelled&quot; and adds a case comment</description>
        <flow>Change_Control_Update_Child_Cases_Submitted_for_Approval</flow>
        <flowInputs>
            <name>vCaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>vStatus</name>
            <value>{!Status}</value>
        </flowInputs>
        <label>Update children Cases - Change Status - Submitted for Approval</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>Update_children_Cases_Change_Status_Submitted_to_Backend</fullName>
        <description>Change Control - When Parent Case status is changed to Closed - Cancelled and prior value is Submitted to Backend, this flow Sends email to all Backend processing teams that are affected</description>
        <flow>Change_Control_Update_Child_Cases_Submitted_to_Backend</flow>
        <flowInputs>
            <name>vCaseId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>vFOPPImpact</name>
            <value>{!KM_FOPP_Impact__c}</value>
        </flowInputs>
        <flowInputs>
            <name>vKMImpact</name>
            <value>{!KM_Impact__c}</value>
        </flowInputs>
        <flowInputs>
            <name>vSystemsImpact</name>
            <value>{!KM_Systems_Impact__c}</value>
        </flowInputs>
        <flowInputs>
            <name>vTrainingImpact</name>
            <value>{!KM_Training_Impact__c}</value>
        </flowInputs>
        <label>Update children Cases - Change Status - Submitted to Backend</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
</Workflow>
