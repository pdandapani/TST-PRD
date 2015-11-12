<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Last_Comment</fullName>
        <field>Last_Comment__c</field>
        <formula>CommentBody</formula>
        <name>Update Last Comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Comment_Date</fullName>
        <field>Last_Comment_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Last Comment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update Last Comment Date</fullName>
        <actions>
            <name>Update_Last_Comment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Last_Comment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update Last Comment Date</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
