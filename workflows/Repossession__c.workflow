<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_rights_letters_management_for_template_before_recovery</fullName>
        <description>Notify rights letters management for template before recovery</description>
        <protected>false</protected>
        <recipients>
            <recipient>Rights_Letters_Management_Reports</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Rights_Letters/Template_Before_Recovery_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Next_Payment_Due_Date_for_Repossession</fullName>
        <field>Payment_Date_and_Contract_Date_differs__c</field>
        <literalValue>1</literalValue>
        <name>Next Payment Due Date for Repossession</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Next_Payment_Due_Date_for_Repossession_u</fullName>
        <field>Payment_Date_and_Contract_Date_differs__c</field>
        <literalValue>0</literalValue>
        <name>Next Payment Due Date for Repossession u</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Unset_Re_evaluate_State_of_Jurisdicti</fullName>
        <field>Re_evaluate_State_of_Jurisdiction__c</field>
        <literalValue>0</literalValue>
        <name>RL Unset Re-evaluate State of Jurisdicti</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Title_City</fullName>
        <field>Title_City__c</field>
        <formula>Auction_Agency_City__c</formula>
        <name>RL Update Title City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Title_Name</fullName>
        <field>Title_Name__c</field>
        <formula>Auction_Agency_Name__c</formula>
        <name>RL Update Title Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Title_State</fullName>
        <field>Title_State__c</field>
        <formula>TEXT(Auction_Agency_State__c)</formula>
        <name>RL Update Title State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Title_Street1</fullName>
        <field>Title_Street1__c</field>
        <formula>Auction_Agency_Street1__c</formula>
        <name>RL Update Title Street1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Title_Street2</fullName>
        <field>Title_Street2__c</field>
        <formula>Auction_Agency_Street2__c</formula>
        <name>RL Update Title Street2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Title_Zip</fullName>
        <field>Title_Zip__c</field>
        <formula>Auction_Agency_Zip__c</formula>
        <name>RL Update Title Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <flowActions>
        <fullName>RL_Set_Proposed_Notice_Date_Override</fullName>
        <flow>RL_Set_Proposed_Notice_Date_Override</flow>
        <flowInputs>
            <name>sRepossession</name>
            <value>{!this}</value>
        </flowInputs>
        <label>RL Set Proposed Notice Date Override</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>RL_Set_State_Conditions</fullName>
        <flow>RL_Set_State_Conditions</flow>
        <flowInputs>
            <name>sCase</name>
            <value>{!Case__r}</value>
        </flowInputs>
        <flowInputs>
            <name>sFinancialAccount</name>
            <value>{!Financial_Account__r}</value>
        </flowInputs>
        <flowInputs>
            <name>sRepossession</name>
            <value>{!this}</value>
        </flowInputs>
        <label>RL Set State Conditions</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>RL_Sync_Case_Flags</fullName>
        <flow>RL_Sync_Case_Flags</flow>
        <flowInputs>
            <name>sCase</name>
            <value>{!Case__r}</value>
        </flowInputs>
        <flowInputs>
            <name>sRepo</name>
            <value>{!this}</value>
        </flowInputs>
        <label>RL Sync Case Flags</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <flowActions>
        <fullName>RL_Update_Title_Fields_for_Salvage</fullName>
        <flow>RL_Update_Title_Address_for_Salvage</flow>
        <flowInputs>
            <name>sRepo</name>
            <value>{!this}</value>
        </flowInputs>
        <flowInputs>
            <name>vDefaultSalvageAuctionAccountNumber</name>
            <value>{!$Setup.General_Settings__c.Repo_Default_Salvage_Auction__c}</value>
        </flowInputs>
        <label>RL Update Title Fields for Salvage</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Next Payment Due Date for Repossession Check</fullName>
        <actions>
            <name>Next_Payment_Due_Date_for_Repossession</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( (NOT(ISNULL(Financial_Account__r.Contract_Date__c)) &amp;&amp; NOT(ISBLANK(Financial_Account__r.Contract_Date__c))), (NOT(ISNULL( Financial_Account__r.Payment_Date_Next__c )) &amp;&amp; NOT(ISBLANK( Financial_Account__r.Payment_Date_Next__c ))), (DAY( Financial_Account__r.Contract_Date__c )  &lt;&gt; DAY( Next_Payment_Date__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Next Payment Due Date for Repossession uncheck</fullName>
        <actions>
            <name>Next_Payment_Due_Date_for_Repossession_u</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ( Payment_Date_and_Contract_Date_differs__c  = true), (NOT(ISNULL(Financial_Account__r.Contract_Date__c)) &amp;&amp; NOT(ISBLANK(Financial_Account__r.Contract_Date__c))), (NOT(ISNULL( Financial_Account__r.Payment_Date_Next__c )) &amp;&amp; NOT(ISBLANK( Financial_Account__r.Payment_Date_Next__c ))), (DAY( Financial_Account__r.Contract_Date__c ) = DAY( Next_Payment_Date__c )) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Set Proposed Notice Date Override</fullName>
        <actions>
            <name>RL_Set_Proposed_Notice_Date_Override</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Set the Proposed Notice Date Override enabling the associate to change the date to today</description>
        <formula>ISCHANGED(Proposed_Notice_Date__c) &amp;&amp; PRIORVALUE(Proposed_Notice_Date__c) &gt; TODAY() &amp;&amp; Proposed_Notice_Date__c = TODAY()</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Set State Conditions</fullName>
        <actions>
            <name>RL_Unset_Re_evaluate_State_of_Jurisdicti</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Set_State_Conditions</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Set the State of Jurisdiction on repossession and determine relevant Form Rule upon request by a non-admin user, i.e. filling the Re-evaluate State of Jurisdiction checkbox, or any time relevant information is updated by an admin or automated process</description>
        <formula>Re_evaluate_State_of_Jurisdiction__c  ||  $Setup.General_Settings__c.Data_Admin_Exemption__c &amp;&amp;  (ISNEW() ||   Financial_Account__c &lt;&gt; NULL &amp;&amp;  ISCHANGED(Financial_Account__c) ||    iRepo_AccountNumber__c &lt;&gt; NULL &amp;&amp;  ISCHANGED(iRepo_AccountNumber__c) ||   iRepo_VIN__c &lt;&gt; NULL &amp;&amp;  ISCHANGED(iRepo_VIN__c) ||   iRepo_RepoZip__c &lt;&gt; NULL &amp;&amp; ISCHANGED(iRepo_RepoZip__c) ||  ISCHANGED(iRepo_RecoveryDateTime__c) ||  TEXT(iRepo_RepoState__c) &lt;&gt; NULL &amp;&amp; ISCHANGED(iRepo_RepoState__c) ||  ISCHANGED(Voluntary_Surrender__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Sync Case Flags</fullName>
        <actions>
            <name>RL_Sync_Case_Flags</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Synchronize fields on case with the values set on repossession - Account Terminated, Template Available</description>
        <formula>ISNEW() || ISCHANGED(Account_Terminated__c) || ISCHANGED(iRepo_TemplateAvailable__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Template Data Before Recovery</fullName>
        <actions>
            <name>Notify_rights_letters_management_for_template_before_recovery</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Repossession__c.CreatedById</field>
            <operation>equals</operation>
            <value>Integration User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Repossession__c.iRepo_RecoveryDateTime__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Notify rights letters management when a repossession is created by the Integration User and initial recovery data does not exist</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RL Update Title Fields</fullName>
        <actions>
            <name>RL_Update_Title_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Update_Title_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Update_Title_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Update_Title_Street1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Update_Title_Street2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Update_Title_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Any change to auction fields by updates from United Road should be copied to title fields unless the title destination has been overridden</description>
        <formula>!Title_Override__c &amp;&amp; ( ISNEW() || ISCHANGED(Auction_Agency_Name__c) ||  ISCHANGED(Auction_Agency_Street1__c) ||  ISCHANGED(Auction_Agency_Street2__c) ||  ISCHANGED(Auction_Agency_City__c) ||  ISCHANGED(Auction_Agency_State__c) ||  ISCHANGED(Auction_Agency_Zip__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Update Title Fields for Salvage</fullName>
        <actions>
            <name>RL_Update_Title_Fields_for_Salvage</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Repossession__c.Salvage__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the title fields to the data from the default salvage auction agency when salvage is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
