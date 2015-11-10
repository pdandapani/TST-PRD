<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Email_Notification_when_Training_Publication_Date_is_Modified</fullName>
        <description>Change Control - Case - Email Notification when Training Publication Date is Modified</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Training_Publication_Date_Change_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Backend_Processing_FOPP</fullName>
        <description>Change Control - Backend Processing - FOPP</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Backend_Processing_FOPP</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Backend_Processing_KM</fullName>
        <description>Change Control - Backend Processing - KM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Backend_Processing_KM</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Backend_Processing_Systems</fullName>
        <description>Change Control - Backend Processing - Systems</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_Systems</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Backend_Processing_Systems</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Backend_Processing_Training</fullName>
        <description>Change Control - Backend Processing - Training</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Backend_Processing_Training</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Case_is_Declined</fullName>
        <description>Change Control - Change Control Case is Declined</description>
        <protected>false</protected>
        <recipients>
            <field>KM_Parent_Case_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_rejection_Email_to_Case_Owner</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Change_request_Close_Notification_to_requester</fullName>
        <description>Change Control - Change request Close Notification to requester</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Change_request_Close_Notification_to_requester</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Cancelled_Notification_FOPP</fullName>
        <description>Change Control - Parent Case Cancelled Notification - FOPP</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_is_cancelled</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Cancelled_Notification_KM</fullName>
        <description>Change Control - Parent Case Cancelled Notification - KM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_is_cancelled</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Cancelled_Notification_Systems</fullName>
        <description>Change Control - Parent Case Cancelled Notification - Systems</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_Systems</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_is_cancelled</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Cancelled_Notification_Training</fullName>
        <description>Change Control - Parent Case Cancelled Notification - Training</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_is_cancelled</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Resume_Notification_KM</fullName>
        <description>Change Control - Parent Case Resume Notification - KM</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_resumed</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Resume_Notification_Systems</fullName>
        <description>Change Control - Parent Case Resume Notification - Systems</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_Systems</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_resumed</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Resume_Notification_Training</fullName>
        <description>Change Control - Parent Case Resume Notification - Training</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_resumed</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Parent_Case_Resumed_Notification_FOPP</fullName>
        <description>Change Control - Parent Case Resumed Notification - FOPP</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Parent_case_resumed</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Response_to_Submitter_when_a_new_Change_Control_Case</fullName>
        <description>Change Control - Response to Submitter when a new Change Control Case</description>
        <protected>false</protected>
        <recipients>
            <field>Article_Feedback_Provided_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ChangeControlNewCaseSubmission</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Send_email_to_KM_team_on_Case_Assignment_Cosmetic</fullName>
        <description>Change Control - Send email to Case Owner on Case Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORTNewassignmentnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>Change_Control_Send_reminder_email_to_Change_Control_Approval_case_owner</fullName>
        <description>Change Control - Send reminder email to Change Control Approval case owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Approval_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Email_to_KM_team_Band5_has_approved_Change_Control_Case</fullName>
        <description>Change Control - Email to KM team - Band5 has approved Change Control Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Band5ApprovalNotification</template>
    </alerts>
    <alerts>
        <fullName>LFS_Initiated_Support_Request_Notification_to_Customer</fullName>
        <description>LFS Initiated Support Request Notification to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply_lexusfinancial@toyota.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Service_Automated/LFS_LFS_Initiated_Support_Request_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_TFS_Customer_of_Case_Created_on_their_Behalf</fullName>
        <description>Notify TFS Customer of Case Created on their Behalf</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply_toyotafinancial@toyota.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Service_Automated/TFS_TFS_Initiated_Support_Request_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_parent_case_owner_when_child_case_not_approved_declined_by_target_approva</fullName>
        <description>Change Control - Notify parent case owner when child case not approved/declined by target approval date</description>
        <protected>false</protected>
        <recipients>
            <field>KM_Parent_Case_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_not_Approved_Declined_by_Target_Approval_Date</template>
    </alerts>
    <alerts>
        <fullName>Reminder_1_Day_Prior_to_Implementation_Date</fullName>
        <description>Change Control - Reminder 1 Day Prior to Implementation Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Reminder_1_Day_Prior_to_Implementation_Date</template>
    </alerts>
    <alerts>
        <fullName>Reminder_1_Day_Prior_to_Publication_Date</fullName>
        <description>Change Control - Reminder 1 Day Prior to Publication Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Reminder_1_Day_Prior_to_Publication_Date</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_to_SOPP_Change_Control_Case_not_approved</fullName>
        <description>Change Control - Send Email to SOPP - Change Control Case not approved</description>
        <protected>false</protected>
        <recipients>
            <field>KM_Parent_Case_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Not_Approved</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_when_FOPP_Publication_Date_is_Modified</fullName>
        <description>Change Control - Send Notification when FOPP Publication Date is Modified</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/FOPP_Publication_Date_Change_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_when_Implementation_Date_is_Modified</fullName>
        <description>Change Control - Send Notification when Implementation Date is Modified</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Implementation_Date_Change_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_when_Implementation_Status_is_Modified_On_Hold_Closed_Withdraw</fullName>
        <description>Change Control - Send Notification when Implementation Status is Modified - On Hold, Closed - Withdrawn or Closed - Deleted</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_Technology</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Implementation_Status_Set_to_On_Hold_Closed_Withdrawn_or_Closed_Deleted</template>
    </alerts>
    <alerts>
        <fullName>Send_Notification_when_KM_Publication_Date_is_Modified</fullName>
        <description>Change Control - Send Notification when KM Publication Date is Modified</description>
        <protected>false</protected>
        <recipients>
            <recipient>PG_FOPP</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_KM</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>PG_Training</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/KM_Publication_Date_Change_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Case_owner_that_the_request_is_rejected</fullName>
        <description>Change Control - Send email to Case owner that the request is rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_rejection_Email_to_Case_Owner</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Change_Control_Approval_case_owner</fullName>
        <description>Change Control - Send email to Change Control Approval case owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Control_Approva_Request</template>
    </alerts>
    <fieldUpdates>
        <fullName>Append_mmddyyhhmmss_to_Integration_ID</fullName>
        <description>Append &apos;~mmddyyhhmmss&apos; to Integration ID when Collection case is closed</description>
        <field>Integration_ID__c</field>
        <formula>Integration_ID__c &amp; &quot;~&quot; &amp; LPAD(TEXT(MONTH(DATEVALUE(NOW()))),2,&quot;0&quot;) &amp; LPAD(TEXT(DAY(DATEVALUE(NOW()))),2,&quot;0&quot;) &amp; LPAD(RIGHT(TEXT(YEAR(DATEVALUE(NOW()))),2),2,&quot;0&quot;) &amp; MID(TEXT(NOW()),12,2) &amp; MID(TEXT(NOW()),15,2) &amp; MID(TEXT(NOW()),18,2)</formula>
        <name>Append &apos;~mmddyyhhmmss&apos; to Integration ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Backend_Processing_Start</fullName>
        <description>Updates Backend Processing Start field when status set to &apos;Submitted for Backend Processing&apos;</description>
        <field>Backend_Processing_Start__c</field>
        <formula>Now()</formula>
        <name>Backend Processing Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Origin_LFS</fullName>
        <description>Sets the Case Origin to LFS Community</description>
        <field>Origin</field>
        <literalValue>LFS Community</literalValue>
        <name>Case Origin LFS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Origin_TFS</fullName>
        <description>Sets the Case Origin to TFS Community</description>
        <field>Origin</field>
        <literalValue>TFS Community</literalValue>
        <name>Case Origin TFS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Ownership_to_Admin</fullName>
        <description>Change ownership on cases to an admin user to prevent editing by standard users</description>
        <field>OwnerId</field>
        <lookupValue>srv_sfdc_eai@tfs.toyota.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Change Ownership to Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Front_End_Approval_Process_Start</fullName>
        <description>Updates Front End Approval Process Start field when status set to &apos;Submitted for Approval&apos;</description>
        <field>Front_End_Approval_Process_Start__c</field>
        <formula>Now()</formula>
        <name>Front End Approval Process Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Last_Modified_Lan_Id_update</fullName>
        <description>Used to update the Last Modified By custom field with the Lan Id for TIBCO/STARS</description>
        <field>Last_Modified_by_Lan_Id__c</field>
        <formula>$User.Lan_Id__c</formula>
        <name>Last Modified Lan Id Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Capture_Initial_Assignee</fullName>
        <field>RL_Initial_Assignee__c</field>
        <formula>Owner:User.FirstName &amp; &quot; &quot; &amp; Owner:User.LastName</formula>
        <name>RL Capture Initial Assignee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Capture_Initial_Assignment_Time</fullName>
        <field>RL_Initial_Assignment_Time__c</field>
        <formula>NOW()</formula>
        <name>RL Capture Initial Assignment Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Capture_Secondary_Assignment_Time</fullName>
        <field>RL_Secondary_Assignment_Time__c</field>
        <formula>NOW()</formula>
        <name>RL Capture Secondary Assignment Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Initial_Pass_Completion_Time</fullName>
        <field>RL_Initial_Pass_Completion_Time__c</field>
        <formula>NOW()</formula>
        <name>RL Initial Pass Completion Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Secondary_Pass_Completion_Time</fullName>
        <field>RL_Secondary_Pass_Completion_Time__c</field>
        <formula>NOW()</formula>
        <name>RL Secondary Pass Completion Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Set_Hold_Status</fullName>
        <field>Status</field>
        <literalValue>On Hold</literalValue>
        <name>RL Set Hold Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RL_Update_Subject</fullName>
        <description>Updates subject for a rights letter case to the FA# - FormRule (ST)</description>
        <field>Subject</field>
        <formula>IF(ISBLANK(Financial_Account__c), &quot;Rights Letter - Needs Account Lookup&quot;, &quot;Rights Letter - &quot; &amp; Financial_Account__r.Financial_Account_Number__c &amp; &quot; - &quot; &amp; Form_Rule__r.Name &amp; IF(ISNUMBER(RIGHT(Form_Rule__r.Form__c, 1)) &amp;&amp; NOT(RIGHT(Form_Rule__r.Name, 1) = &quot;)&quot;), &quot; (&quot; &amp; RL_State_of_Jurisdiction__c &amp; &quot;)&quot;, &quot;&quot;))</formula>
        <name>RL Update Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Resolved_Web_To_Case</fullName>
        <field>OwnerId</field>
        <lookupValue>WebToCase_Contact_Us_Resolved_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Resolved Web-To-Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Initial_RL_score_value</fullName>
        <field>Initial_RL_Score__c</field>
        <formula>IF(RL_System_Required_Notice_Date_Time__c &lt; NOW(), 900, 
     IF(8 - (DATEVALUE(RL_System_Required_Notice_Date_Time__c) - TODAY()) &lt;= 1, 100, (8 - (DATEVALUE(RL_System_Required_Notice_Date_Time__c) - TODAY())) * 100)
)+
IF(Form_Rule__r.Certified__c, 50, 0)</formula>
        <name>Set Initial RL score value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Reopened_Flag</fullName>
        <field>Reopened__c</field>
        <literalValue>1</literalValue>
        <name>Set Reopened Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Upd_Owner_to_SOP_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Planning_and_Ops_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Upd Owner to SOP Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner_Group_Field</fullName>
        <description>Updates the &apos;Case Owner Group&apos; field with the original case queue name</description>
        <field>Case_Owner_Group__c</field>
        <formula>Owner:Queue.QueueName</formula>
        <name>Update Case Owner Group Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_FrontEndApproved</fullName>
        <description>Updates Change Control Case status to &quot;Front End Approved&quot;</description>
        <field>Status</field>
        <literalValue>Front End Approved</literalValue>
        <name>Update Case Status - FrontEndApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Description_for_DDC</fullName>
        <description>Support Request Description custom field limited to 1,990 characters (+10 for case number) to support STARS limits.  Standard Description field being updated because this field is being sent to STARS.</description>
        <field>Description</field>
        <formula>CaseNumber + &apos; | DDC &apos; + LPAD(BLANKVALUE(TEXT(Requested_Due_Date_Day_of_Month__c), &apos;&apos;), 2, &apos;0&apos;) + &apos; | &apos; + Support_Request_Description__c</formula>
        <name>Update Description for DDC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Description_for_Support_Request</fullName>
        <description>Support Request Description custom field limited to 1,990 characters (+10 for case number) to support STARS limits.  Standard Description field being updated because this field is being sent to STARS.</description>
        <field>Description</field>
        <formula>CaseNumber + &apos; | &apos; + Support_Request_Description__c</formula>
        <name>Update Description for Support Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Escalated_Field_on_Case</fullName>
        <description>Updates the escalated field to true</description>
        <field>IsEscalated</field>
        <literalValue>1</literalValue>
        <name>Update Escalated Field on Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Front_End_Approval_Process_End</fullName>
        <description>Updates Front End Approval Process End field when status set to &apos;Front End Approved&apos;</description>
        <field>Front_End_Approval_Process_End__c</field>
        <formula>Now()</formula>
        <name>Update Front End Approval Process End</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Recipient_Borrower</fullName>
        <description>Updates the Service Recipient to &apos;Borrower/Customer&apos;</description>
        <field>Service_Recipient__c</field>
        <literalValue>Borrower/Customer</literalValue>
        <name>Update Service Recipient Borrower</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Recipient_Co_borrower</fullName>
        <description>Updates the Service Recipient to &apos;Co-borrower/Customer&apos;</description>
        <field>Service_Recipient__c</field>
        <literalValue>Co-Borrower/Customer</literalValue>
        <name>Update Service Recipient Co-borrower</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Escalated</fullName>
        <description>Updates status on the case to &apos;Escalated&apos;</description>
        <field>Status</field>
        <literalValue>Escalated</literalValue>
        <name>Update Status to Escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Subject</fullName>
        <field>Subject</field>
        <formula>TEXT(Service_Request_Subject__c)</formula>
        <name>Update Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
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
    <outboundMessages>
        <fullName>Publish_Case_To_TFS</fullName>
        <apiVersion>30.0</apiVersion>
        <endpointUrl>https://intsvcs-tst.services.toyotafinancial.com/TFS/Services/ServiceRequest</endpointUrl>
        <fields>Abbreviated_Consent_Date__c</fields>
        <fields>Abbreviated_Consent__c</fields>
        <fields>AccountId</fields>
        <fields>Address_Type__c</fields>
        <fields>Affiliate_Marketing_Privacy__c</fields>
        <fields>All_Privacy_Options__c</fields>
        <fields>AssetId</fields>
        <fields>Attorney_If_any__c</fields>
        <fields>CaseNumber</fields>
        <fields>Certified_Used__c</fields>
        <fields>ClosedDate</fields>
        <fields>Collection_Counter_Promises_Broken__c</fields>
        <fields>Collection_Counter_Promises_Kept__c</fields>
        <fields>Collection_Current_Promise_Status__c</fields>
        <fields>Collection_Last_List__c</fields>
        <fields>Collection_List_Description__c</fields>
        <fields>Collection_List_Number_1__c</fields>
        <fields>Collection_List_Number_2__c</fields>
        <fields>Collection_List_Number_3__c</fields>
        <fields>Collection_List_Status_1__c</fields>
        <fields>Collection_List_Status_2__c</fields>
        <fields>Collection_List_Status_3__c</fields>
        <fields>Collection_Number_Of_Months_Past_Due__c</fields>
        <fields>Collection_Recourse_Code__c</fields>
        <fields>Collection_Review_Date__c</fields>
        <fields>Collection_UserID__c</fields>
        <fields>Communication_Comments__c</fields>
        <fields>Complaint_Initiated_By__c</fields>
        <fields>Complaint_Submitted__c</fields>
        <fields>ContactId</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>Credit_App_Reporting_Privacy__c</fields>
        <fields>Current_Address_Name__c</fields>
        <fields>Current_Address__c</fields>
        <fields>Current_Care_Of__c</fields>
        <fields>Current_City__c</fields>
        <fields>Current_Email_Address__c</fields>
        <fields>Current_Fax_Number__c</fields>
        <fields>Current_Foreign_Country__c</fields>
        <fields>Current_Home_Number_DNC__c</fields>
        <fields>Current_Home_Number_INVALID__c</fields>
        <fields>Current_Home_Number_MOBILE__c</fields>
        <fields>Current_Home_Number__c</fields>
        <fields>Current_Mileage__c</fields>
        <fields>Current_Mobile_Number_DNC__c</fields>
        <fields>Current_Mobile_Number_INVALID__c</fields>
        <fields>Current_Mobile_Number__c</fields>
        <fields>Current_State__c</fields>
        <fields>Current_Work_Number_DNC__c</fields>
        <fields>Current_Work_Number_INVALID__c</fields>
        <fields>Current_Work_Number_MOBILE__c</fields>
        <fields>Current_Work_Number__c</fields>
        <fields>Current_Zip_Code_Extn__c</fields>
        <fields>Current_Zipcode__c</fields>
        <fields>Date_of_Complaint__c</fields>
        <fields>Dealer__c</fields>
        <fields>Description</fields>
        <fields>Edit_Message__c</fields>
        <fields>Electronic_Business_Agreement_Date__c</fields>
        <fields>Electronic_Business_Agreement__c</fields>
        <fields>Finance_Reason__c</fields>
        <fields>Financial_Account_Customer_ID__c</fields>
        <fields>Financial_Account_Customer__c</fields>
        <fields>Financial_Account__c</fields>
        <fields>Good_Thru_Date__c</fields>
        <fields>Gross_Payoff__c</fields>
        <fields>Id</fields>
        <fields>Immediate_Action__c</fields>
        <fields>Integration_ID__c</fields>
        <fields>IsClosed</fields>
        <fields>IsClosedOnCreate</fields>
        <fields>IsDeleted</fields>
        <fields>IsEscalated</fields>
        <fields>Issue_Category__c</fields>
        <fields>Language_Preference__c</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>LastReferencedDate</fields>
        <fields>LastViewedDate</fields>
        <fields>Last_Comment__c</fields>
        <fields>Last_Modified_by_Lan_Id__c</fields>
        <fields>Make__c</fields>
        <fields>Marketing_Comm_Pref_Email__c</fields>
        <fields>Marketing_Comm_Pref_Home_Phone__c</fields>
        <fields>Marketing_Comm_Pref_Mobile_Phone__c</fields>
        <fields>Marketing_Comm_Pref_Text__c</fields>
        <fields>Marketing_Comm_Pref_Work_Phone__c</fields>
        <fields>Net_Payoff__c</fields>
        <fields>New_Address_Name__c</fields>
        <fields>New_Address__c</fields>
        <fields>New_Care_Of__c</fields>
        <fields>New_City__c</fields>
        <fields>New_Country__c</fields>
        <fields>New_Email_Address__c</fields>
        <fields>New_Home_Number_DNC__c</fields>
        <fields>New_Home_Number_INVALID__c</fields>
        <fields>New_Home_Number_MOBILE__c</fields>
        <fields>New_Home_Number__c</fields>
        <fields>New_Mobile_Number_DNC__c</fields>
        <fields>New_Mobile_Number_INVALID__c</fields>
        <fields>New_Mobile_Number__c</fields>
        <fields>New_State__c</fields>
        <fields>New_Work_Number_DNC__c</fields>
        <fields>New_Work_Number_INVALID__c</fields>
        <fields>New_Work_Number_MOBILE__c</fields>
        <fields>New_Work_Number__c</fields>
        <fields>New_Zip_Code_Extn__c</fields>
        <fields>New_Zipcode__c</fields>
        <fields>Online_Flag__c</fields>
        <fields>Origin</fields>
        <fields>Overall_Consent_Date__c</fields>
        <fields>Overall_Consent__c</fields>
        <fields>OwnerId</fields>
        <fields>ParentId</fields>
        <fields>Payment_Not_Received_Email__c</fields>
        <fields>Payment_Not_Received_Text__c</fields>
        <fields>Payment_Received_Email__c</fields>
        <fields>Payment_Received_Text__c</fields>
        <fields>Payment_Reminder_Day__c</fields>
        <fields>Payment_Reminder_Email__c</fields>
        <fields>Payment_Reminder_Text__c</fields>
        <fields>Payoff_Quote__c</fields>
        <fields>Per_Diem__c</fields>
        <fields>Preferred_Contact__c</fields>
        <fields>Priority</fields>
        <fields>Process_Date__c</fields>
        <fields>Program_III__c</fields>
        <fields>Program_II__c</fields>
        <fields>Program_I__c</fields>
        <fields>Purchase_Opt__c</fields>
        <fields>Quoted_To__c</fields>
        <fields>Reason</fields>
        <fields>Recipient__c</fields>
        <fields>RecordTypeId</fields>
        <fields>Residual_Value__c</fields>
        <fields>Response_Date_Due__c</fields>
        <fields>SR_First_Name__c</fields>
        <fields>SR_Last_Name_Business_Name__c</fields>
        <fields>Service_Recipient__c</fields>
        <fields>Service_Request_Category__c</fields>
        <fields>Service_Request_Type__c</fields>
        <fields>Service_Request_User_Group__c</fields>
        <fields>Service_Result__c</fields>
        <fields>Service_Type__c</fields>
        <fields>Source_Created_By__c</fields>
        <fields>Source_Created_Date__c</fields>
        <fields>Source_System_Created_By__c</fields>
        <fields>StarsSRNumber__c</fields>
        <fields>Status</fields>
        <fields>Subject</fields>
        <fields>SuppliedCompany</fields>
        <fields>SuppliedEmail</fields>
        <fields>SuppliedName</fields>
        <fields>SuppliedPhone</fields>
        <fields>SystemModstamp</fields>
        <fields>TFS_LFS_Dealer_Privacy__c</fields>
        <fields>TFS_LFS_Information_Email_Address__c</fields>
        <fields>Team_Lead_Name_Ext__c</fields>
        <fields>Telemarketing_Privacy__c</fields>
        <fields>Third_Party_Privacy__c</fields>
        <fields>TransferReason__c</fields>
        <fields>Type</fields>
        <fields>Warm_Transfer__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>outbound.integration@toyota.com</integrationUser>
        <name>Publish Case To TFS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Band5 Case Approved</fullName>
        <actions>
            <name>Email_to_KM_team_Band5_has_approved_Change_Control_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Band5 Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <description>Change Control -  When Band5 case is approved, a notification needs to be set to KM team so they can start working on the change and getting it ready.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case - Capture Front End Approved Date%2FTime</fullName>
        <actions>
            <name>Update_Front_End_Approval_Process_End</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Front End Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - Captures the date/time the case was updated to front end approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case - Capture Submitted for Approval Date%2FTime</fullName>
        <actions>
            <name>Front_End_Approval_Process_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted for Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - Captures the date/time the case was submitted for front end approval.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case - Email Notification 1 Day Prior to Implementation Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Implementation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Change Control - Remind case owner 1 day prior to implementation date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_1_Day_Prior_to_Implementation_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.KM_Implementation_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case - Email Notification 1 Day Prior to Publication Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Publication_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Change Control - Remind case owner 1 day prior to publication date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_1_Day_Prior_to_Publication_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.KM_Publication_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case - Email Notification when FOPP Publication Date is Modified</fullName>
        <actions>
            <name>Send_Notification_when_FOPP_Publication_Date_is_Modified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If FOPP publication date is modified, send email to Case Owner, FOPP Queue, Training Queue and KM Queue</description>
        <formula>NOT( ISBLANK (PRIORVALUE( KM_FOPP_Publication_Date__c ))) &amp;&amp; ISCHANGED( KM_FOPP_Publication_Date__c ) &amp;&amp; RecordType.Name == &quot;Change Control&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case - Email Notification when Implementation Date is Modified</fullName>
        <actions>
            <name>Send_Notification_when_Implementation_Date_is_Modified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If Implementation date is modified, send email to Case Owner, FOPP Queue, Training Queue and KM Queue</description>
        <formula>NOT( ISBLANK (PRIORVALUE( KM_Implementation_Date__c ))) &amp;&amp; ISCHANGED( KM_Implementation_Date__c ) &amp;&amp; RecordType.Name == &quot;Change Control&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case - Email Notification when Implementation Status is set to On Hold%2C Closed - Withdrawn or Closed - Deleted</fullName>
        <actions>
            <name>Send_Notification_when_Implementation_Status_is_Modified_On_Hold_Closed_Withdraw</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If implementation status  is set to On Hold, Closed - Withdrawn or Closed - Deleted, send email to Case Owner, FOPP Queue, Technology Queue and KM Queue</description>
        <formula>(ISPICKVAL( KM_System_Status__c , &quot;On Hold&quot;) ||    ISPICKVAL( KM_System_Status__c , &quot;Closed - Withdrawn&quot;) ||   ISPICKVAL( KM_System_Status__c , &quot;Closed - Deleted&quot;) ) &amp;&amp;  RecordType.Name == &quot;Change Control&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case - Email Notification when KM Publication Date is Modified</fullName>
        <actions>
            <name>Send_Notification_when_KM_Publication_Date_is_Modified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If KM publication date is modified, send email to Case Owner, FOPP Queue, Training Queue and KM Queue</description>
        <formula>NOT( ISBLANK (PRIORVALUE( KM_Publication_Date__c ))) &amp;&amp; ISCHANGED( KM_Publication_Date__c ) &amp;&amp; RecordType.Name == &quot;Change Control&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case - Email Notification when Training Publication Date is Modified</fullName>
        <actions>
            <name>Case_Email_Notification_when_Training_Publication_Date_is_Modified</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If training publication date is modified, send email to Case Owner, FOPP Queue, Training Queue and KM Queue</description>
        <formula>NOT( ISBLANK (PRIORVALUE( KM_Training_Publication_Date__c ))) &amp;&amp; ISCHANGED( KM_Training_Publication_Date__c ) &amp;&amp; RecordType.Name == &quot;Change Control&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case - Store Original Case Owner</fullName>
        <actions>
            <name>Update_Case_Owner_Group_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.ParentId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control,Change Control Approval</value>
        </criteriaItems>
        <description>Change Control - Store the original owner of the case when it&apos;s created for children cases</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case - Update Escalated Flag for Change Control Approval Cases if not Approved%2FDeclined by Target Approval Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed - Declined,Closed - Approved,Closed - Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Approval_Target_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Change Control - For child cases, if the case is not approved or declined by the Target Approval Date then we should check the Escalated flag and also send an email to Parent Case Owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_parent_case_owner_when_child_case_not_approved_declined_by_target_approva</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Update_Escalated_Field_on_Case</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Status_to_Escalated</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.KM_Approval_Target_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Reopened</fullName>
        <actions>
            <name>Set_Reopened_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set a flag on the case when it moves from a closed status to an open one</description>
        <formula>PRIORVALUE(IsClosed) &amp;&amp; !IsClosed</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Backend Processing - FOPP Email</fullName>
        <actions>
            <name>Change_Control_Backend_Processing_FOPP</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 7 AND (3 AND 4) OR (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted to Backend</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Backend_Processing_Status__c</field>
            <operation>equals</operation>
            <value>Systems Implementation Date Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Backend_Processing_Status__c</field>
            <operation>equals</operation>
            <value>Submitted to FOPP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - If Status is Submitted to Backend and there&apos;s a FOPP Impact, sends email to FOPP if 1) there&apos;s a Systems Impact and Systems has confirmed the Systems Implementation Date OR 2) there&apos;s no Systems Impact and therefore, routes to FOPP.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Backend Processing - KM Email</fullName>
        <actions>
            <name>Change_Control_Backend_Processing_KM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 8 AND (3 OR (4 AND 5 AND 6) OR (6 AND 7))</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted to Backend</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Publication_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Backend_Processing_Status__c</field>
            <operation>equals</operation>
            <value>Systems Implementation Date Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - If Status is Submitted to Backend and there&apos;s KM Impact, sends email to KM if 1) FOPP Publication Date has been or 2) No FOPP Impact, but there&apos;s Systems Impact &amp; Confirmed Date or 3) No FOPP or Systems Impact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Backend Processing - Systems Email</fullName>
        <actions>
            <name>Change_Control_Backend_Processing_Systems</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted to Backend</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Change Control - If Status is Submitted to Backend, sends email to Systems if there&apos;s a Systems Impact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Backend Processing - Training Email</fullName>
        <actions>
            <name>Change_Control_Backend_Processing_Training</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 8 AND (3 OR (4 AND 5 AND 6) OR (6 AND 7))</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted to Backend</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Training_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Publication_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Backend_Processing_Status__c</field>
            <operation>equals</operation>
            <value>Systems Implementation Date Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - If Status is Submitted to Backend and there&apos;s a Training Impact, sends email to Training if 1) FOPP Publication Date has been  or 2) No FOPP Impact, but there&apos;s Systems Impact &amp; Confirmed Date or 3) No FOPP or Systems Impact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Backend processing - Post FOPP</fullName>
        <actions>
            <name>Change_Control_Backend_Processing</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Backend_Processing_Status__c</field>
            <operation>equals</operation>
            <value>Submitted to FOPP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Publication_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Change Control - This workflow is triggered once FOPP Publication date is triggered to take backend processing to KM and/or Training as applicable</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Backend processing - Post Systems</fullName>
        <actions>
            <name>Change_Control_Backend_Processing</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Backend_Processing_Status__c</field>
            <operation>equals</operation>
            <value>Systems Implementation Date Confirmed</value>
        </criteriaItems>
        <description>Change Control - When Systems team confirms implementation Date, this workflow is called to send the process to FOPP</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Capture Submitted for Backend Processing Date%2FTime</fullName>
        <actions>
            <name>Backend_Processing_Start</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted to Backend</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - Captures the date/time the case was updated to &apos;Submitted to Backend&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Change request Close Notification to requester</fullName>
        <actions>
            <name>Change_Control_Change_request_Close_Notification_to_requester</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Change Control - Whenever a Change Control is closed, an email will be sent to original Web To Case requester.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Email Notification when Owner is KM Queue and Priority is Cosmetic</fullName>
        <actions>
            <name>Change_Control_Send_email_to_KM_team_on_Case_Assignment_Cosmetic</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>KM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Cosmetic</value>
        </criteriaItems>
        <description>Change Control - When Owner is KM Queue and Priority is Cosmetic, send email notification to KM Queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - On Hold from Submitted for Approval</fullName>
        <active>true</active>
        <description>Change Control - On Hold from Submitted for Approval</description>
        <formula>AND( RecordType.Name = &quot;Change Control&quot;, ISPICKVAL(Status, &quot;On Hold&quot;), PRIORVALUE(Status) = &quot;Submitted for Approval&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Cancelled Notification - FOPP</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Cancelled_Notification_FOPP</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR (5 AND 6))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Closed - Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Implementation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Change Control - If Status is On Hold/Closed-Cancelled and there&apos;s a FOPP Impact, sends email to FOPP if 1) there&apos;s a Systems Impact and Systems has confirmed the Systems Implementation Date OR 2) there&apos;s no Systems Impact and therefore, routes to FOPP.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Cancelled Notification - KM</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Cancelled_Notification_KM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR (5 AND 6 AND 7) OR (7 AND 8))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Closed - Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Publication_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Implementation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Change Control - If Status is On Hold/Closed - Cancelled and there&apos;s KM Impact, sends email to KM if 1) FOPP Publication Date has been or 2) No FOPP Impact, but there&apos;s Systems Impact &amp; Confirmed Date or 3) No FOPP or Systems Impact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Cancelled Notification - Systems</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Cancelled_Notification_Systems</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Closed - Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Change Control - If Status is On Hold/Closed - Cancelled, sends email to Systems if there&apos;s a Systems Impact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Cancelled Notification - Training</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Cancelled_Notification_Training</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR (5 AND 6 AND 7) OR (7 AND 8))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Closed - Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Training_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Publication_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Implementation_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_FOPP_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Systems_Impact__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>Change Control - If Status is On Hold/Closed - Cancelled and there&apos;s a Training Impact, sends email to Training if 1) FOPP Publication Date has been or 2) No FOPP Impact, but there&apos;s Systems Impact &amp; Confirmed Date or 3) No FOPP or Systems Impact.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Resume Notification - FOPP</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Resumed_Notification_FOPP</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If Case is Resumed and there&apos;s a FOPP Impact, sends email to FOPP if 1) there&apos;s a Systems Impact and Systems has confirmed the Systems Implementation Date OR 2) there&apos;s no Systems Impact and therefore, routes to FOPP.</description>
        <formula>AND( RecordType.Name = &quot;Change Control&quot;, ISPICKVAL(Status, &quot;Submitted to Backend&quot;), ISPICKVAL(PRIORVALUE(Status), &quot;On Hold&quot;), KM_FOPP_Impact__c = True, OR( KM_Systems_Impact__c = False, AND( KM_Systems_Impact__c = True, NOT(ISNULL(KM_Implementation_Date__c)) )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Resume Notification - KM</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Resume_Notification_KM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If Case is Resumed and there&apos;s KM Impact, sends email to KM if 1) FOPP Publication Date has been or 2) No FOPP Impact, but there&apos;s Systems Impact &amp; Confirmed Date or 3) No FOPP or Systems Impact.</description>
        <formula>AND( RecordType.Name = &quot;Change Control&quot;, ISPICKVAL(Status, &quot;Submitted to Backend&quot;), ISPICKVAL(PRIORVALUE(Status), &quot;On Hold&quot;), KM_Impact__c  = True, OR( NOT(ISNULL(KM_FOPP_Publication_Date__c)), AND( KM_Systems_Impact__c = True, NOT(ISNULL(KM_Implementation_Date__c)), KM_FOPP_Impact__c = False ), AND( KM_FOPP_Impact__c = False, KM_Systems_Impact__c = False) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Resume Notification - Systems</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Resume_Notification_Systems</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If  Case is Resumed, sends email to Systems if there&apos;s a Systems Impact.</description>
        <formula>AND( RecordType.Name = &quot;Change Control&quot;, ISPICKVAL(Status, &quot;Submitted to Backend&quot;), ISPICKVAL(PRIORVALUE(Status), &quot;On Hold&quot;), KM_Systems_Impact__c = True )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Parent Case Resume Notification - Training</fullName>
        <actions>
            <name>Change_Control_Parent_Case_Resume_Notification_Training</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change Control - If Case is Resumed and there&apos;s a Training Impact, sends email to Training if 1) FOPP Publication Date has been or 2) No FOPP Impact, but there&apos;s Systems Impact &amp; Confirmed Date or 3) No FOPP or Systems Impact.</description>
        <formula>AND(
RecordType.Name = &quot;Change Control&quot;,
ISPICKVAL(Status, &quot;Submitted to Backend&quot;),
ISPICKVAL(PRIORVALUE(Status), &quot;On Hold&quot;),
KM_Training_Impact__c = True,
OR(
NOT(ISNULL(KM_FOPP_Publication_Date__c)),
AND(
KM_Systems_Impact__c = True,
ISPICKVAL(KM_Backend_Processing_Status__c, &quot;Systems Implementation Date Confirmed&quot;),
KM_FOPP_Impact__c = False
),
AND(
KM_FOPP_Impact__c = False,
KM_Systems_Impact__c = False)
)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Send Email to Approver Queue</fullName>
        <actions>
            <name>Send_email_to_Change_Control_Approval_case_owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <description>Change Control - When a Change Control Approval case (child case) is Created, send email notification to the Owner (Queue Members).</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Change Control - Send Emails to Queue %26 Submitter</fullName>
        <actions>
            <name>Change_Control_Response_to_Submitter_when_a_new_Change_Control_Case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Control_Send_email_to_KM_team_on_Case_Assignment_Cosmetic</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Upd_Owner_to_SOP_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Change Control - When KM flips the Record Type from Article Feedback to Change Control, send an email notification to the SOP Queue and to the Submitter (similar to how it occurs when the Case is submitted via W2C).</description>
        <formula>AND( RecordType.DeveloperName = &quot;Change_Control&quot;, ISPICKVAL(Origin, &quot;Article Feedback&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control Approval Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed - Declined,Closed - Approved,Closed - Cancelled</value>
        </criteriaItems>
        <description>Change Control - Send email to Case approver 1 day before the Target approval date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Change_Control_Send_reminder_email_to_Change_Control_Approval_case_owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.KM_Approval_Target_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Change Control Approval case is declined</fullName>
        <actions>
            <name>Change_Control_Case_is_Declined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Declined</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <description>Change Control - If any of the change control approval case is declined then send email to parent case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Control Approval not approved by Target Date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Approval_Target_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.KM_Approval_Target_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Change Control - This Workflow is triggered when an approver has neither Approved nor declined a change request past Approval Target Date. This will send email to SOPP team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Email_to_SOPP_Change_Control_Case_not_approved</name>
                <type>Alert</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>InitiateCasePublish</fullName>
        <actions>
            <name>Publish_Case_To_TFS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Source_System_Created_By__c</field>
            <operation>equals</operation>
            <value>SFDC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Initiate Case Publishing to TFS</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>InitiateCasePublish - Complaint</fullName>
        <actions>
            <name>Publish_Case_To_TFS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Service_Request_Category__c</field>
            <operation>equals</operation>
            <value>Complaints</value>
        </criteriaItems>
        <description>Sends case data to TIBCO/STARS via outbound message for customer complaint cases</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>InitiateCasePublish - EMS</fullName>
        <actions>
            <name>Publish_Case_To_TFS</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>EMS project specific case publish criteria to send Support Request and Due Date Change Request case data to TIBCO/STARS via outbound message</description>
        <formula>AND(   Source_System_Created_By__c = &apos;SFDC&apos;,   OR(    RecordType.Name = &apos;Support Request&apos;,    RecordType.Name = &apos;Due Date Change Request&apos;  ),   OR(    ISNEW(),    PRIORVALUE(Last_Comment__c) != Last_Comment__c   )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>KM Child Case Approved</fullName>
        <actions>
            <name>Update_Parent_Case_Approval_Count</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control Approval</value>
        </criteriaItems>
        <description>Change Control - When a change control child case is approved, KM Approval Count needs to be subtracted by 1. When it becomes zero, parent case status will be changed to &quot;Front end approved&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LFS Email Notification Internally Created Cases</fullName>
        <actions>
            <name>LFS_Initiated_Support_Request_Notification_to_Customer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Origin_LFS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support Request,Due Date Change Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.eCSR_Initiated__c</field>
            <operation>equals</operation>
            <value>Yes - Lexus</value>
        </criteriaItems>
        <description>Used to send case creation notification for LFS customer if &quot;Email Notification&quot; field is set to &quot;Yes - Lexus&quot; by internal user for new Support Request and DDC cases created on the customer&apos;s behalf. Also, updates Case Origin field appropriately.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LFS Email Notification Internally Created Cases - NO</fullName>
        <actions>
            <name>Case_Origin_LFS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support Request,Due Date Change Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.eCSR_Initiated__c</field>
            <operation>equals</operation>
            <value>No - Lexus</value>
        </criteriaItems>
        <description>Used to NOT send case creation notification for LFS customer if &quot;Email Notification&quot; field is set to &quot;No - Lexus&quot; by internal user for new Support Request or DDC cases created on the customer&apos;s behalf.  Also, updates Case Origin field appropriately.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Last Modified Lan Id</fullName>
        <actions>
            <name>Last_Modified_Lan_Id_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseNumber</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Used to indicate the Lan Id of the user who last modified a case.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Close Parent Case</fullName>
        <actions>
            <name>RL_Close_Parent_Case</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Closes the parent rights letter case when the status on a quality review child case is set to closed</description>
        <formula>RecordType.Name = &quot;RL Quality Review&quot; &amp;&amp; ISCHANGED(Status) &amp;&amp; ISPICKVAL(Status, &quot;Closed&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Create Child Quality Review Case</fullName>
        <actions>
            <name>RL_Create_Child_Quality_Review_Case</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>When a rights letter or notice of sale case status changes to Quality Review, create a new quality review child case</description>
        <formula>(RecordType.Name = &quot;Rights Letter&quot; || RecordType.Name = &quot;RL Notice of Sale&quot; || RecordType.Name = &quot;RL Notice of Sale-Salvage&quot;) &amp;&amp; ISCHANGED(Status) &amp;&amp; ISPICKVAL(Status, &quot;Quality Review&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Initial Assignment</fullName>
        <actions>
            <name>RL_Capture_Initial_Assignee</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RL_Capture_Initial_Assignment_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture the initial assignment owner and time</description>
        <formula>!$Setup.General_Settings__c.Data_Admin_Exemption__c &amp;&amp; ISBLANK(RL_Initial_Assignee__c) &amp;&amp; ISBLANK(Owner:Queue.QueueName)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RL Initial Pass Completion Time</fullName>
        <actions>
            <name>RL_Initial_Pass_Completion_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture the time at which the initial assignee changes the status from In Progress</description>
        <formula>(!$Setup.General_Settings__c.Data_Admin_Exemption__c &amp;&amp;  ISBLANK(RL_Initial_Pass_Completion_Time__c) &amp;&amp;  !ISBLANK(RL_Initial_Assignee__c)) &amp;&amp;   (!ISPICKVAL(Status, &quot;In Progress&quot;) &amp;&amp;  ISCHANGED(Status)  ||   ISCHANGED(OwnerId))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Secondary Assignment</fullName>
        <actions>
            <name>RL_Capture_Secondary_Assignment_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture the secondary assignment time</description>
        <formula>!$Setup.General_Settings__c.Data_Admin_Exemption__c &amp;&amp;  ISBLANK(RL_Secondary_Assignment_Time__c) &amp;&amp;  !ISBLANK(RL_Initial_Assignee__c) &amp;&amp;  ISBLANK(Owner:Queue.QueueName) &amp;&amp;  ISCHANGED(OwnerId)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Secondary Pass Completion Time</fullName>
        <actions>
            <name>RL_Secondary_Pass_Completion_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Capture the time at which the secondary assignee changes the status from In Progress</description>
        <formula>(!$Setup.General_Settings__c.Data_Admin_Exemption__c &amp;&amp;  ISBLANK(RL_Secondary_Pass_Completion_Time__c) &amp;&amp;  !ISBLANK(RL_Secondary_Assignment_Time__c)) &amp;&amp;   (!ISPICKVAL(Status, &quot;In Progress&quot;) &amp;&amp;  ISCHANGED(Status)  ||   ISCHANGED(OwnerId))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RL Set Hold Status after Auto IMS</fullName>
        <actions>
            <name>RL_Set_Hold_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RL_Auto_IMS_Hold_Placed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update the case status to Hold after Auto IMS Hold Placed checkbox is filled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RL Update Subject</fullName>
        <actions>
            <name>RL_Update_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the subject for a rights letters case</description>
        <formula>RecordType.Name = &quot;Rights Letter&quot; &amp;&amp;   (ISNEW() || ISCHANGED(Financial_Account__c) || ISCHANGED(Form_Rule__c) || ISCHANGED(RL_State_of_Jurisdiction__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Read-only Service Requests</fullName>
        <actions>
            <name>Change_Ownership_to_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Collection,Rights Letter,RL Quality Review,RL Notice of Sale,RL Notice of Sale-Salvage,Due Date Change Request,Support Request,Web-To-Case,Change Control,Change Control Approval,Article Feedback</value>
        </criteriaItems>
        <description>Change ownership on service request cases to prevent edits after submission</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassign Web-to-Case</fullName>
        <actions>
            <name>Resolved_Web_To_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Web-To-Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <description>When a Web-To-Case (Contact Us) case is edited to change the Status field to “Resolved”, the case is automatically assigned to the Contact Us Resolved Queue as the owner.  This removes ownership of resolved Contact Us cases from eCSRs.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Service Recipient Borrower</fullName>
        <actions>
            <name>Update_Service_Recipient_Borrower</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Due Date Change Request,Support Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_Role_Type__c</field>
            <operation>equals</operation>
            <value>0-Primary Borrower</value>
        </criteriaItems>
        <description>Determines if the Service Recipient filed should be set as &apos;Borrower/Customer&apos;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Service Recipient Co-Borrower</fullName>
        <actions>
            <name>Update_Service_Recipient_Co_borrower</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Due Date Change Request,Support Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_Role_Type__c</field>
            <operation>notEqual</operation>
            <value>0-Primary Borrower</value>
        </criteriaItems>
        <description>Determines if the Service Recipient filed should be set as &apos;Co-Borrower/Customer&apos;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Initial RL score</fullName>
        <actions>
            <name>Set_Initial_RL_score_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule sets the Value from RL_Score__c to Initial_RL_Score__c at the the time of &apos;Rights Letter&apos; case creation</description>
        <formula>RecordType.Name = &apos;Rights Letter&apos; &amp;&amp;
NOT(ISBLANK(RL_System_Required_Notice_Date_Time__c)) &amp;&amp;
NOT(ISBLANK(Form_Rule__c)) &amp;&amp;
ISBLANK(Initial_RL_Score__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TFS Email Notification Internally Created Cases</fullName>
        <actions>
            <name>Notify_TFS_Customer_of_Case_Created_on_their_Behalf</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Origin_TFS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support Request,Due Date Change Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.eCSR_Initiated__c</field>
            <operation>equals</operation>
            <value>Yes - Toyota</value>
        </criteriaItems>
        <description>Used to send case creation notification for TFS customer if &quot;Email Notification&quot; field is set to &quot;Yes - Toyota&quot; by internal user for new Support Request and DDC cases created on the customer&apos;s behalf. Also, updates Case Origin field appropriately.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TFS Email Notification Internally Created Cases - NO</fullName>
        <actions>
            <name>Case_Origin_TFS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support Request,Due Date Change Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.eCSR_Initiated__c</field>
            <operation>equals</operation>
            <value>No - Toyota</value>
        </criteriaItems>
        <description>Used to NOT send case creation notification for TFS customer if &quot;Email Notification&quot; field is set to &quot;No - Toyota&quot; by internal user for new Support Request or DDC cases created on the customer&apos;s behalf.  Also, updates Case Origin field appropriately.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Status - FrontEndApproved</fullName>
        <actions>
            <name>Update_Case_Status_FrontEndApproved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.KM_approval_Count__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Change Control</value>
        </criteriaItems>
        <description>Change Control - Updates case status to &quot;Front End Approved&quot; when the Approval Count becomes 0.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Child Cases if Parent Case Owner changes</fullName>
        <actions>
            <name>Update_Children_Cases</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Change Control - Whenever Parent Case owner is updated, call a flow that updates all children &quot;KM Parent Case Owner&quot; field to Parent case&apos;s owner</description>
        <formula>ISCHANGED( OwnerId ) &amp;&amp;  RecordType.Name = &quot;Change Control&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Child Cases if Parent Case status - Cancelled or On Hold%2C Submitted for Approval</fullName>
        <actions>
            <name>Update_children_Cases_Change_Status_Submitted_for_Approval</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Change Control - This rule updates all children cases status to Closed Cancelled if parent case status is changed to Closed - Cancelled and prior case status was Submitted for Approval</description>
        <formula>AND(RecordType.Name = &quot;Change Control&quot;,  ISPICKVAL(Status, &quot;Closed - Cancelled&quot;), OR(ISPICKVAL(PRIORVALUE(Status), &quot;Submitted for Approval&quot;), ISPICKVAL(PRIORVALUE(Status), &quot;On Hold&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Child Cases if Parent Case status - Cancelled or On Hold%2C Submitted to Backend</fullName>
        <actions>
            <name>Update_children_Cases_Change_Status_Submitted_to_Backend</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <description>Change Control - This rule Sends email to all impacted backed processing teams if parent case status is changed to Closed - Cancelled and prior case status was Submitted to Backend</description>
        <formula>AND(RecordType.Name = &quot;Change Control&quot;,  ISPICKVAL(Status, &quot;Closed - Cancelled&quot;), OR(ISPICKVAL(PRIORVALUE(Status), &quot;Submitted to Backend&quot;),ISPICKVAL(PRIORVALUE(Status), &quot;KM Changes Approved&quot;), ISPICKVAL(PRIORVALUE(Status), &quot;On Hold&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Closed Collection Case Integration ID</fullName>
        <actions>
            <name>Append_mmddyyhhmmss_to_Integration_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Collection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates Collection case Integration ID by appending &apos;~mmddyyhhmmss&apos; to the end when the case is first closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update DDC Description</fullName>
        <actions>
            <name>Update_Description_for_DDC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Due Date Change Request</value>
        </criteriaItems>
        <description>Due Date Change Requests are sent to STARS which has a 2000 chr limit.  Custom fld Support Request Description (2000) will be used for data entry on theses case record types and the standard description field will be updated for STARS</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Subject</fullName>
        <actions>
            <name>Update_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Due Date Change Request,Web-To-Case,Support Request</value>
        </criteriaItems>
        <description>Updates the standard Subject field with the custom Subject picklist value for Support Request, Due Date Change Request, and Web-to-Case record types.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Support Request Description</fullName>
        <actions>
            <name>Update_Description_for_Support_Request</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Support Request</value>
        </criteriaItems>
        <description>Support Requests are sent to STARS which has a 2000 chr limit.  Custom fld Support Request Description (2000) will be used for data entry on theses case record types and the standard description field will be updated for STARS</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
