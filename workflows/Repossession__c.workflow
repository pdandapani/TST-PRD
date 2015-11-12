<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
</Workflow>
