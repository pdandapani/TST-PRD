<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateTIN_Last_6_on_Account</fullName>
        <field>SSN_TIN_Last_6__c</field>
        <formula>TRIM(RIGHT(Tax_Identification_Number__c , 6))</formula>
        <name>UpdateTIN Last 6 on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SSN_Last_4_on_Account</fullName>
        <field>SSN_TIN_Last_4__c</field>
        <formula>TRIM(RIGHT(Social_Security_Number__pc , 4))</formula>
        <name>Update SSN Last 4 on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SSN_Last_6_on_Account</fullName>
        <field>SSN_TIN_Last_6__c</field>
        <formula>TRIM(RIGHT(Social_Security_Number__pc , 6))</formula>
        <name>Update SSN Last 6 on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_TIN_Last_4_on_Account</fullName>
        <field>SSN_TIN_Last_4__c</field>
        <formula>TRIM(RIGHT(Tax_Identification_Number__c , 4))</formula>
        <name>Update TIN Last 4 on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate SSN on Account</fullName>
        <actions>
            <name>Update_SSN_Last_4_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_SSN_Last_6_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName = &apos;Customer&apos; &amp;&amp; ( ISCHANGED(Social_Security_Number__pc) || ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate TIN on Account</fullName>
        <actions>
            <name>UpdateTIN_Last_6_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_TIN_Last_4_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName = &apos;Business_Account&apos; &amp;&amp; (ISCHANGED(Tax_Identification_Number__c) || ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
