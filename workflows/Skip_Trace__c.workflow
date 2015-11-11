<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>X120_day_Reset_Innovis</fullName>
        <field>Innovis_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>120-day Reset  Innovis</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_Accurint</fullName>
        <field>Accurint_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset  Accurint</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_DMS</fullName>
        <field>DMS_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset DMS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_DMS_Credit</fullName>
        <field>DMS_Credit_App_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset DMS Credit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_Fast_Data</fullName>
        <field>Fast_Data_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset Fast Data</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_Innovis</fullName>
        <field>Innovis_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset  Innovis</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_Multiple_Accounts</fullName>
        <field>Multiple_Accounts_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset  Multiple Accounts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>X30_day_Reset_Payment_Review</fullName>
        <field>Payment_Review_Checkbox__c</field>
        <literalValue>0</literalValue>
        <name>30-day Reset  Payment Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>120-day Reset Innovis</fullName>
        <active>true</active>
        <formula>Innovis_Checkbox__c = TRUE &amp;&amp;
NOT(ISBLANK(Innovis_Date__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X120_day_Reset_Innovis</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Skip_Trace__c.Innovis_Date__c</offsetFromField>
            <timeLength>120</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset  Accurint</fullName>
        <active>true</active>
        <formula>Accurint_Checkbox__c  = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_Accurint</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset  DMS Credit</fullName>
        <active>true</active>
        <formula>DMS_Credit_App_Checkbox__c  = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_DMS_Credit</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset  Innovis</fullName>
        <active>false</active>
        <formula>Innovis_Checkbox__c    = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_Innovis</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset  Multiple Accounts</fullName>
        <active>true</active>
        <formula>Multiple_Accounts_Checkbox__c    = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_Multiple_Accounts</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset  Payment Review</fullName>
        <active>true</active>
        <formula>Payment_Review_Checkbox__c = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_Payment_Review</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset DMS</fullName>
        <active>true</active>
        <formula>DMS_Checkbox__c  = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_DMS</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>30-day Reset Fast Data</fullName>
        <active>true</active>
        <formula>Fast_Data_Checkbox__c   = TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X30_day_Reset_Fast_Data</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
