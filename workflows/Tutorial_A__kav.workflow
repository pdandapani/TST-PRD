<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TUT_FOPP_Field_Update</fullName>
        <description>This rules updates FOPP number from rich text field into text field</description>
        <field>FOPP_Text__c</field>
        <formula>FOPP__c</formula>
        <name>TUT - FOPP - Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TUT_Geography_CAN_Field_Update</fullName>
        <description>Country and state values converted via workflow to a searchable text field</description>
        <field>Geography_Keywords__c</field>
        <formula>TEXT(Country__c)&amp;&quot;,&quot;&amp;
IF(INCLUDES( States_Provinces__c,&quot;Ontario&quot;),&quot;Ontario,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Quebec&quot;),&quot;Quebec,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Nova Scotia&quot;),&quot;Nova Scotia,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;New Brunswick&quot;),&quot;New Brunswick,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Manitoba&quot;),&quot;Manitoba,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;British Columbia&quot;),&quot;British Columbia,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Prince Edward Island&quot;),&quot;Prince Edward Island,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Saskatchewan&quot;),&quot;Saskatchewan,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Alberta&quot;),&quot;Alberta,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Newfoundland and Labrador&quot;),&quot;Newfoundland and Labrador,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Yukon&quot;),&quot;Yukon,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Northwest Territories&quot;),&quot;Northwest Territories,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Nunavut&quot;),&quot;Nunavut&quot;,&quot;&quot;)</formula>
        <name>TUT - Geography - CAN - Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TUT_Geography_MEX_Field_Update</fullName>
        <description>Country and state values converted via workflow to a searchable text field</description>
        <field>Geography_Keywords__c</field>
        <formula>TEXT(Country__c)&amp;&quot;,&quot;&amp;
IF(INCLUDES( States_Provinces__c,&quot;Federal District&quot;),&quot;Federal District,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Mexico State&quot;),&quot;Mexico State,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Nuevo León&quot;),&quot;Nuevo León,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Jalisco&quot;),&quot;Jalisco,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Campeche&quot;),&quot;Campeche,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Veracruz&quot;),&quot;Veracruz,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Tabasco&quot;),&quot;Tabasco,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Guanajuato&quot;),&quot;Guanajuato,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Puebla&quot;),&quot;Puebla,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Coahuila&quot;),&quot;Coahuila,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Tamaulipas&quot;),&quot;Tamaulipas,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Chihuahua&quot;),&quot;Chihuahua,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Sonora&quot;),&quot;Sonora,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Baja California&quot;),&quot;Baja California,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Michoacán&quot;),&quot;Michoacán,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Sinaloa&quot;),&quot;Sinaloa,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;&quot;),&quot;Chiapas&quot;,&quot;Chiapas,&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;&quot;),&quot;Querétaro&quot;,&quot;Querétaro,&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;&quot;),&quot;San Luis Potosí&quot;,&quot;San Luis Potosí,&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Hidalgo&quot;),&quot;Hidalgo,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Oaxaca&quot;),&quot;Oaxaca,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Guerrero&quot;),&quot;Guerrero,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Quintana Roo&quot;),&quot;Quintana Roo,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Yucatán&quot;),&quot;Yucatán,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Durango&quot;),&quot;Durango,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Morelos&quot;),&quot;Morelos,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Aguascalientes&quot;),&quot;Aguascalientes,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Zacatecas&quot;),&quot;Zacatecas,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Nayarit&quot;),&quot;Nayarit,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Colima&quot;),&quot;Colima,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Baja California Sur&quot;),&quot;Baja California Sur,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Tlaxcala&quot;),&quot;Tlaxcala&quot;,&quot;&quot;)</formula>
        <name>TUT - Geography - MEX - Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TUT_Geography_Null_Field_Update</fullName>
        <description>Searchable text field updated to &apos;null&apos; when Country is &apos;none&apos;.</description>
        <field>Geography_Keywords__c</field>
        <name>TUT - Geography - Null - Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TUT_Geography_USA_Field_Update</fullName>
        <description>Country and state values converted via workflow to a searchable text field</description>
        <field>Geography_Keywords__c</field>
        <formula>TEXT(Country__c)&amp;&quot;,&quot;&amp;
IF(INCLUDES( States_Provinces__c,&quot;Alabama&quot;),&quot;Alabama,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Alaska&quot;),&quot;Alaska,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Arizona&quot;),&quot;Arizona,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Arkansas&quot;),&quot;Arkansas,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;California&quot;),&quot;California,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Colorado&quot;),&quot;Colorado,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Connecticut&quot;),&quot;Connecticut,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Delaware&quot;),&quot;Delaware,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;District of Columbia&quot;),&quot;District of Columbia,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Florida&quot;),&quot;Florida,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Georgia&quot;),&quot;Georgia,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Hawaii&quot;),&quot;Hawaii,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Idaho&quot;),&quot;Idaho,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Illinois&quot;),&quot;Illinois,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Indiana&quot;),&quot;Indiana,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Iowa&quot;),&quot;Iowa,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Kansas&quot;),&quot;Kansas,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Kentucky&quot;),&quot;Kentucky,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Louisiana&quot;),&quot;Louisiana,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Maine&quot;),&quot;Maine,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Maryland&quot;),&quot;Maryland,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Massachusetts&quot;),&quot;Massachusetts,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Michigan&quot;),&quot;Michigan,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Minnesota&quot;),&quot;Minnesota,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Mississippi&quot;),&quot;Mississippi,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Missouri&quot;),&quot;Missouri,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Montana&quot;),&quot;Montana,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Nebraska&quot;),&quot;Nebraska,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Nevada&quot;),&quot;Nevada,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;New Hampshire&quot;),&quot;New Hampshire,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;New Jersey&quot;),&quot;New Jersey,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;New Mexico&quot;),&quot;New Mexico,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;New York&quot;),&quot;New York,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;North Carolina&quot;),&quot;North Carolina,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;North Dakota&quot;),&quot;North Dakota,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Ohio&quot;),&quot;Ohio,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Oregon&quot;),&quot;Oregon,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Pennsylvania&quot;),&quot;Pennsylvania,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Puerto Rico&quot;),&quot;Puerto Rico,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Rhode Island&quot;),&quot;Rhode Island,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;South Carolina&quot;),&quot;South Carolina,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;South Dakota&quot;),&quot;South Dakota,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Tennessee&quot;),&quot;Tennessee,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Texas&quot;),&quot;Texas,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Utah&quot;),&quot;Utah,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Vermont&quot;),&quot;Vermont,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Virgin Islands&quot;),&quot;Virgin Islands,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Virginia&quot;),&quot;Virginia,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Washington&quot;),&quot;Washington,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;West Virginia&quot;),&quot;West Virginia,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Wisconsin&quot;),&quot;Wisconsin,&quot;,&quot;&quot;)&amp;
IF(INCLUDES( States_Provinces__c,&quot;Wyoming&quot;),&quot;Wyoming&quot;,&quot;&quot;)</formula>
        <name>TUT - Geography - USA - Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TUT - FOPP</fullName>
        <actions>
            <name>TUT_FOPP_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tutorial_A__kav.FOPP__c</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>This rules updates FOPP number from rich text field into text field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TUT - Geography - CAN</fullName>
        <actions>
            <name>TUT_Geography_CAN_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tutorial_A__kav.CreatedDate</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Tutorial_A__kav.Country__c</field>
            <operation>equals</operation>
            <value>Canada</value>
        </criteriaItems>
        <description>Country and state values converted via workflow to a searchable text field for Canada</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TUT - Geography - MEX</fullName>
        <actions>
            <name>TUT_Geography_MEX_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tutorial_A__kav.CreatedDate</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Tutorial_A__kav.Country__c</field>
            <operation>equals</operation>
            <value>Mexico</value>
        </criteriaItems>
        <description>Country and state values converted via workflow to a searchable text field for Mexico</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TUT - Geography - Null</fullName>
        <actions>
            <name>TUT_Geography_Null_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tutorial_A__kav.Country__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Searchable text field updated to &apos;null&apos; when Country is &apos;none&apos;.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TUT - Geography - USA</fullName>
        <actions>
            <name>TUT_Geography_USA_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tutorial_A__kav.CreatedDate</field>
            <operation>lessOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Tutorial_A__kav.Country__c</field>
            <operation>equals</operation>
            <value>United States</value>
        </criteriaItems>
        <description>Country and state values converted via workflow to a searchable text field for the United States</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
