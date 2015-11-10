<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CaptureCollection_Primary_Note_Edit_Date</fullName>
        <description>Fill-in Collection_Primary_Note_Edit_Date__c with current datetime</description>
        <field>Collection_Primary_Note_Edit_Date__c</field>
        <formula>NOW()</formula>
        <name>CaptureCollection Primary Note Edit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Capture_Last_UI_Edit_Date</fullName>
        <description>Fill-in Last_UI_Edit_Date__c with current datetime</description>
        <field>Last_UI_Edit_Date__c</field>
        <formula>NOW()</formula>
        <name>Capture Last UI Edit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_CO_Host_Account_Number</fullName>
        <description>Sets the formatting for the CO Host field on the financial account record.</description>
        <field>CO_Host_Account_Number__c</field>
        <formula>IF(
 RecordType.DeveloperName = &apos;Retail&apos;,
 &apos;000704&apos; &amp; Financial_Account_Number__c &amp; &apos;0001&apos;,
 &apos;0000000000&apos; &amp; LEFT(Financial_Account_Number__c,2) &amp; 
   RIGHT(Financial_Account_Number__c,LEN(Financial_Account_Number__c) - 3)
)</formula>
        <name>Set CO Host Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Exchange_Account_Number</fullName>
        <description>Sets the formatted value for the Exchange Account Number field on the financial account record.</description>
        <field>Exchange_Account_Number__c</field>
        <formula>IF(
 RecordType.DeveloperName = &apos;Retail&apos;,
 RIGHT(Financial_Account_Number__c, LEN(Financial_Account_Number__c) - 3),
 RIGHT(Financial_Account_Number__c, LEN(Financial_Account_Number__c) - 6)
)</formula>
        <name>Set Exchange Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_WUSP_Account_Number</fullName>
        <description>Sets the WUSP account number value for the financial account record</description>
        <field>WUSP_Account_Number__c</field>
        <formula>IF(
 RecordType.DeveloperName = &apos;Retail&apos;,
 LEFT(Financial_Account_Number__c,3) &amp; &apos;-&apos; &amp; 
  RIGHT(Financial_Account_Number__c, (LEN(Financial_Account_Number__c) - 3)),
 LEFT(Financial_Account_Number__c,2) &amp; &apos;-&apos; &amp; 
  MID(Financial_Account_Number__c,3,4) &amp; &apos;-&apos; &amp;
  RIGHT(Financial_Account_Number__c,(LEN(Financial_Account_Number__c) - 6))
)</formula>
        <name>Set WUSP Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_iVault_Account_Number</fullName>
        <description>Sets the formatting for the iVault Account Number field on the financial account record.</description>
        <field>iVault_Account_Number__c</field>
        <formula>IF(
 RecordType.DeveloperName = &apos;Retail&apos;,
 TEXT(VALUE(Financial_Account_Number__c)),
 IF(
  ISNUMBER(Financial_Account_Number__c),
  /* Numeric lease account numbers have 2 formats to display */
  MID(Financial_Account_Number__c,4,3) &amp; &apos;0&apos; &amp; RIGHT(Financial_Account_Number__c,LEN(Financial_Account_Number__c) - 5) &amp; BR() &amp; 
   TEXT(VALUE(Financial_Account_Number__c)) &amp; &apos; (Bill Pay)&apos;,
  /* Alphanumeric lease account numbers have only 1 format to display */
  MID(Financial_Account_Number__c,4,3) &amp; 
  CASE(
   MID(Financial_Account_Number__c,7,1),
   &apos;A&apos;,&apos;10&apos;,
   &apos;B&apos;,&apos;11&apos;,
   &apos;C&apos;,&apos;12&apos;,
   &apos;D&apos;,&apos;13&apos;,
   &apos;E&apos;,&apos;14&apos;,
   &apos;F&apos;,&apos;15&apos;,
   &apos;G&apos;,&apos;16&apos;,
   &apos;H&apos;,&apos;17&apos;,
   &apos;I&apos;,&apos;18&apos;,
   &apos;J&apos;,&apos;19&apos;,
   &apos;K&apos;,&apos;20&apos;,
   &apos;L&apos;,&apos;21&apos;,
   &apos;M&apos;,&apos;22&apos;,
   &apos;N&apos;,&apos;23&apos;,
   &apos;O&apos;,&apos;34&apos;,
   &apos;P&apos;,&apos;25&apos;,
   &apos;Q&apos;,&apos;26&apos;,
   &apos;R&apos;,&apos;27&apos;,
   &apos;S&apos;,&apos;28&apos;,
   &apos;T&apos;,&apos;29&apos;,
   &apos;U&apos;,&apos;30&apos;,
   &apos;V&apos;,&apos;31&apos;,
   &apos;W&apos;,&apos;32&apos;,
   &apos;X&apos;,&apos;33&apos;,
   &apos;Y&apos;,&apos;34&apos;,
   &apos;Z&apos;,&apos;35&apos;,
   &apos;&apos;
  ) &amp;
  CASE(
   MID(Financial_Account_Number__c,8,1),
   &apos;A&apos;,&apos;10&apos;,
   &apos;B&apos;,&apos;11&apos;,
   &apos;C&apos;,&apos;12&apos;,
   &apos;D&apos;,&apos;13&apos;,
   &apos;E&apos;,&apos;14&apos;,
   &apos;F&apos;,&apos;15&apos;,
   &apos;G&apos;,&apos;16&apos;,
   &apos;H&apos;,&apos;17&apos;,
   &apos;I&apos;,&apos;18&apos;,
   &apos;J&apos;,&apos;19&apos;,
   &apos;K&apos;,&apos;20&apos;,
   &apos;L&apos;,&apos;21&apos;,
   &apos;M&apos;,&apos;22&apos;,
   &apos;N&apos;,&apos;23&apos;,
   &apos;O&apos;,&apos;34&apos;,
   &apos;P&apos;,&apos;25&apos;,
   &apos;Q&apos;,&apos;26&apos;,
   &apos;R&apos;,&apos;27&apos;,
   &apos;S&apos;,&apos;28&apos;,
   &apos;T&apos;,&apos;29&apos;,
   &apos;U&apos;,&apos;30&apos;,
   &apos;V&apos;,&apos;31&apos;,
   &apos;W&apos;,&apos;32&apos;,
   &apos;X&apos;,&apos;33&apos;,
   &apos;Y&apos;,&apos;34&apos;,
   &apos;Z&apos;,&apos;35&apos;,
   &apos;&apos;
  ) &amp; 
  RIGHT(Financial_Account_Number__c,3)
 )
)</formula>
        <name>Set iVault Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Extensions_Deferrals_Lease_Only</fullName>
        <description>Sets the extensions/deferrals value for lease accounts</description>
        <field>History_Counter_Extensions_Deferrals__c</field>
        <formula>IF(
 AND(
  RecordType.DeveloperName = &apos;Lease&apos;,
  NOT(ISBLANK(Revised_Maturity_Date__c)),
  MOD(Maturity_Dates_Difference_in_Months__c,6) &lt;&gt; 0,
  Maturity_Dates_Difference_in_Months__c &lt; 6
 ),
 Maturity_Dates_Difference_in_Months__c,
 IF(
  AND(
   RecordType.DeveloperName = &apos;Lease&apos;,
   NOT(ISBLANK(Revised_Maturity_Date__c)),
   MOD(Maturity_Dates_Difference_in_Months__c,6) &lt;&gt; 0,
   Maturity_Dates_Difference_in_Months__c &gt; 6,
   Maturity_Dates_Difference_in_Months__c &lt; 12
  ),
  Maturity_Dates_Difference_in_Months__c - 6,
  IF(
   AND(
    RecordType.DeveloperName = &apos;Lease&apos;,
    NOT(ISBLANK(Revised_Maturity_Date__c)),
    MOD(Maturity_Dates_Difference_in_Months__c,6) &lt;&gt; 0,
    Maturity_Dates_Difference_in_Months__c &gt; 12,
    Maturity_Dates_Difference_in_Months__c &lt; 18
   ),
   Maturity_Dates_Difference_in_Months__c - 12,
    IF(
    AND(
     RecordType.DeveloperName = &apos;Lease&apos;,
     NOT(ISBLANK(Revised_Maturity_Date__c)),
     MOD(Maturity_Dates_Difference_in_Months__c,6) &lt;&gt; 0,
     Maturity_Dates_Difference_in_Months__c &gt; 18,
     Maturity_Dates_Difference_in_Months__c &lt; 24
    ),
    Maturity_Dates_Difference_in_Months__c - 18,
    IF(
     AND(
      RecordType.DeveloperName = &apos;Lease&apos;,
      NOT(ISBLANK(Revised_Maturity_Date__c)),
      MOD(Maturity_Dates_Difference_in_Months__c,6) &lt;&gt; 0,
      Maturity_Dates_Difference_in_Months__c &gt; 18,
      Maturity_Dates_Difference_in_Months__c &lt; 24
     ),
     Maturity_Dates_Difference_in_Months__c - 18,
     IF(
      AND(
       RecordType.DeveloperName = &apos;Lease&apos;,
       NOT(ISBLANK(Revised_Maturity_Date__c)),
       MOD(Maturity_Dates_Difference_in_Months__c,6) &lt;&gt; 0,
       Maturity_Dates_Difference_in_Months__c &gt; 24,
       Maturity_Dates_Difference_in_Months__c &lt; 30
      ),
      Maturity_Dates_Difference_in_Months__c - 24,
      0
     )
    )
   )
  )
 )
)</formula>
        <name>Update Extensions/Deferrals - Lease Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Collection Primary Note Last Edit Date</fullName>
        <actions>
            <name>CaptureCollection_Primary_Note_Edit_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture the last time an edit was made to Collection Primary Note by an end user so integration can perform targeted outgoing updates</description>
        <formula>AND(   ISCHANGED(Collection_Primary_Note__c),   NOT($Profile.Name=&quot;System Administrator&quot;||$Profile.Name=&quot;API Only&quot;||$Profile.Name=&quot;System Administrator Clone&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FA is created or updated</fullName>
        <actions>
            <name>Set_CO_Host_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Exchange_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_WUSP_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_iVault_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Actions occurring every time a financial account record is created or updated.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Last UI Edit Date</fullName>
        <actions>
            <name>Capture_Last_UI_Edit_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture the last time an edit was made to the record by an end user so integration can perform targeted outgoing updates</description>
        <formula>AND(   Name != &quot;&quot;,   NOT($Profile.Name=&quot;System Administrator&quot;||$Profile.Name=&quot;API Only&quot;||$Profile.Name=&quot;System Administrator Clone&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lease Financial Account is Created or Updated</fullName>
        <actions>
            <name>Update_Extensions_Deferrals_Lease_Only</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  RecordType.DeveloperName = &apos;Lease&apos;,  NOT(ISBLANK(Maturity_Date__c)),  NOT(ISBLANK(Revised_Maturity_Date__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
