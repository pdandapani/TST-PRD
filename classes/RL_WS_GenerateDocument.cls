global without sharing class RL_WS_GenerateDocument {
    
    public class GenDocRequest{
        //request params   
    }

    global class GenDocResponse{
        
        public GenDocResponse() {
            this.StatusParams = new StatusParams(); 
            this.responseRecord = new ResponseRecord();
        }
        
        public ResponseRecord responseRecord {get;set;}
        public StatusParams StatusParams {get;set;}
    }
    
    // Response structure for the web service wrapper
    public class ResponseRecord{
        public Integer ResultCode;
        public String ResultDesc;
        public String ResultString;
        public String RequestString;
    }
    
    public class StatusParams{
        public String Status{get;set;} // SUCCESS or FAIL
        public String Error{get;set;} // Populated only if Status = FAIL
    }
    
    
    
    
    public static void testHttpRequest() {
        
        String bodyString = buildXmlString();
        String username = System.UserInfo.getOrganizationId();
        String password = username;            
        Blob authCredBlob = Blob.valueOf(username + ':' + password);
        String authCred = EncodingUtil.base64Encode(authCredBlob);
        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://intsvcs-tst.services.toyotafinancial.com/TFS/Services/RightsLetterForms');
        req.setMethod('POST');
        req.setBody(bodyString);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
        //req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Authorization', 'Basic ' + authCred);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('**** response:'+res.getBody()) ;
    }
    
    private static String buildXmlString() {
        
        String strToReturn = '<env:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
        '<env:Body>'+
        '<FormsReqSync xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/FormsReqSync">'+
        '<ProcessService>'+
        '<ServiceApplicationArea>'+
        '<ConversationID xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea">1a87fb82-dca3-5f7b-ce37-5fd2fcb9de04</ConversationID>'+
        '<MessageType xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea">REQ</MessageType>'+
        '<Mode xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea"/>'+
        '<OrganizationId xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea">012n00000008WTuAAM</OrganizationId>'+
        '<SenderID xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea"/>'+
        '<SentTimeStamp xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea">2015-01-08T19:22:57.966Z</SentTimeStamp>'+
        '<ServiceType xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea"/>'+
        '<TargetID xmlns="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea"/>'+
        '</ServiceApplicationArea>'+
        '<FormsReqBOD>'+
        '<ListOfForms>'+
        '<LCForms>'+
        '<Request xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<CreationDate xmlns="">2015-01-08</CreationDate>'+
        '<FormType xmlns="">Interactive</FormType>'+
        '<Dispatches xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<Dispatch xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<Name xmlns="">Print Central</Name>'+
        '</Dispatch>'+
        '</Dispatches>'+
        '<Targets xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<Target xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<SystemName xmlns="">FileNet</SystemName>'+
        '<DocumentProperties xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<AccountNumber xmlns="">0016788912</AccountNumber>'+
        '<DocumentType xmlns="">4015</DocumentType>'+
        '</DocumentProperties>'+
        '</Target>'+
        '</Targets>'+
        '</Request>'+
        '<Source xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<RequestId xmlns="">46c64803-59b0-2438-8de5-7b8893fb0b39</RequestId>'+
        '<SystemName xmlns="">SFDC</SystemName>'+
        '<SourceFormIdentifier1 xmlns="">4015</SourceFormIdentifier1>'+
        '<EffectiveStateCode xmlns="">MT</EffectiveStateCode>'+
        '</Source>'+
        '<RecipientAddress xmlns="http://tfs.toyota.com/LCFORMS/">'+
        '<Recipient xmlns="">Customer</Recipient>'+
        '<NameLine1 xmlns="">Bob Man</NameLine1>'+
        '<Address1 xmlns="">123 State Street</Address1>'+
        '<CityStateZipCode xmlns="">Glendive, MT 59330</CityStateZipCode>'+
        '</RecipientAddress>'+
        '<Entity xmlns="">'+
        '<Logo xmlns="">TFS</Logo>'+
        '<EntityShortName xmlns="">TFS</EntityShortName>'+
        '<EntityLongName xmlns="">Toyota Financial Services</EntityLongName>'+
        '<Phone xmlns="">800-555-1234</Phone>'+
        '<Locations>'+
        '<ReturnAddress>'+
        '<Name>String</Name>'+
        '<Address1>String</Address1>'+
        '<Address2>String</Address2>'+
        '</ReturnAddress>'+
        '</Locations>'+
        '</Entity>'+
        '<Account xmlns="">'+
        '<AccountNumber xmlns="">0016788912</AccountNumber>'+
        '<AccountType xmlns="">Retail</AccountType>'+
        '<Lang xmlns="">en</Lang>'+
        '<FinanceCharge xmlns="">100</FinanceCharge>'+
        '</Account>'+
        '<Customers xmlns=""/>'+
        '<Vehicle xmlns="">'+
        '<IdentificationNumber xmlns="">2T1BU4EE3BC694894</IdentificationNumber>'+
        '<Model xmlns="">Camry</Model>'+
        '<Make xmlns="">Toyota</Make>'+
        '<Year xmlns="">2010</Year>'+
        '</Vehicle>'+
        '</LCForms>'+
        '</ListOfForms>'+
        '</FormsReqBOD>'+
        '</ProcessService>'+
        '</FormsReqSync>'+
        '</env:Body>'+
        '</env:Envelope>';
        
        
        return strToReturn;
    }
    
    
    private static XMLNode recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany(XMLNode parentNode, String destString, FormField formField, sObject sObjWithValues) {
        String[] splitObjProps = destString.split('\\.',0);
        
        String finalProp = splitObjProps[splitObjProps.size() - 1];
        String currentProp = splitObjProps[0];
        XMLNode tmpNodeNextChild;
        //BEGIN RECURRSIVE LOOP
        if(splitObjProps.size() > 1 || 
            ( currentProp.contains('\\|') || currentProp.contains('\\&\\#\\1\\2\\4\\;') || currentProp.contains('|') || currentProp.contains('&#124;') )) 
        {
            if(currentProp.contains('\\|') || currentProp.contains('\\&\\#\\1\\2\\4\\;') || currentProp.contains('|') || currentProp.contains('&#124;')) {
                //then we're looking at a 1:many node.
                //we do not create anything beyond the '|' -- child "Lists" will be added after this recursive loop.
                currentProp = currentProp.replace('\\&\\#\\1\\2\\4\\;', '\\|');
                currentProp = currentProp.split('\\|',0)[0]; //CLEAN OUT PIPE
                System.debug(LoggingLevel.ERROR, '***** current propx = ' +  currentProp +' *****');
                tmpNodeNextChild = parentNode.get(currentProp);
                if(tmpNodeNextChild == null) {
                    tmpNodeNextChild = createAndAppendContainerNode(parentNode, currentProp);
                }
                //RETURN ONE-TO-MANY PARENT NODE
                return tmpNodeNextChild;
            }else{
                String remainingProps = destString.replaceFirst(currentProp + '.', '');
                System.debug(LoggingLevel.ERROR, '***** currentProp = ' +  currentProp +' *****');
                tmpNodeNextChild = parentNode.get(currentProp);
                if(tmpNodeNextChild == null) {
                    tmpNodeNextChild = createAndAppendContainerNode(parentNode, currentProp);
                }
                //RECURSIVE CALL -- pass in remaining properties
                //e.g. "Requests.Request.Blah.CreatedDate" to "Request.Blah.CreatedDate" (passing in parent tmpNodeNextChild called "Requests") 
                return recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany(tmpNodeNextChild, remainingProps, formField, sObjWithValues);
            }
        }else{
            appendPropertyNode(parentNode, formField, currentProp, sObjWithValues);
        }
        
        //RETURN NULL BECAUSE THIS IS NOT A ONE-TO-MANY PARENT NODE
        return null;
    }
    
    private static XMLNode createAndAppendContainerNode(XMLNode directParentNode, String nodeName) {
        XMLNode nodeToReturn = new XMLNode(true,nodeName,'','');
        directParentNode.addChild(nodeToReturn);
        return nodeToReturn;
    }
    
    private static String getYYYYMMDDStringFromDate(Date d) {
        String strToReturn = '';
        if(d != null) {
            //yyyy-mm-dd
            strToReturn += String.valueOf(d.year());
            strToReturn += '-';
            if(d.month() < 10) {
                strToReturn += '0';
            }
            strToReturn += String.valueOf(d.month());
            strToReturn += '-';
            if(d.day() < 10) {
                strToReturn += '0';
            }
            strToReturn += String.valueOf(d.day());
            
            
        }
        return strToReturn;
    }
    
    private static String getYYYYMMDDStringFromDateTimeInGMT(DateTime d) {
        String strToReturn = '';
        if(d != null) {
            //yyyy-mm-dd
            strToReturn += String.valueOf(d.yearGmt());
            strToReturn += '-';
            if(d.monthGmt() < 10) {
                strToReturn += '0';
            }
            strToReturn += String.valueOf(d.monthGmt());
            strToReturn += '-';
            if(d.dayGmt() < 10) {
                strToReturn += '0';
            }
            strToReturn += String.valueOf(d.dayGmt());
            
            
        }
        return strToReturn;
    }
    
    private static XMLNode lastPropertyNode;
    private static void appendPropertyNode(XMLNode directParentNode, FormField formField, String nodeName, sObject sObjWithValues) {
        String value = '';
        Object objectValue;
        if(sObjWithValues != null) {
            objectValue = sObjWithValues.get(formField.targetField);
            if(objectValue == null) {
                value = '';
            }else if((Object)objectValue instanceof Date) {
                Date tmpD = (Date)objectValue;
                value = getYYYYMMDDStringFromDate(tmpD);
            }else if((Object)objectValue instanceof DateTime) {
                DateTime tmpDT = (DateTime)objectValue;
                value = getYYYYMMDDStringFromDateTimeInGMT(tmpDT);
            }else{
                value = String.valueOf(objectValue);
            }
        }
        if(value == null || value == 'null') {
            value = '';
        }
        
        value = value.replaceAll('&','&amp;');
        //value = value.replace('/&/g','&amp;');
        
        XMLNode newNode = directParentNode.get(nodeName);
        if(newNode == null){
            newNode = new XMLNode(nodeName,value);
            directParentNode.addChild(newNode);
        }else{
            newNode.value = value;
        }
        
        lastPropertyNode = newNode;
    }
    
    
    private static void addStaticValues(XMLNode grandParentNode, Id docRequestId) {
        FormField servAppFormField = new FormField();
        servAppFormField.destinationNode = 'soapenv:Body.for:FormsReqSync.for:ProcessService.for:ServiceApplicationArea|x.x';
        servAppFormField.lineItemField = true;
        servAppFormField.lineItemType = null;
        servAppFormField.targetField = '';
        
        DateTime dt = DateTime.now();
        String formattedDt = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        XMLNode servAppNode = recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany(grandParentNode, servAppFormField.destinationNode, servAppFormField, null);
        servAppNode.addChild( new XMLNode('ser:RefToSequenceNo','1') );
        servAppNode.addChild( new XMLNode('ser:SenderID',UserInfo.getUserId()) );
        servAppNode.addChild( new XMLNode('ser:ServiceType','WS') );
        servAppNode.addChild( new XMLNode('ser:ConversationID',docRequestId) );
        servAppNode.addChild( new XMLNode('ser:OrganizationId',System.UserInfo.getOrganizationId()) );
        servAppNode.addChild( new XMLNode('ser:Mode','ASYNC') );
        servAppNode.addChild( new XMLNode('ser:SentTimeStamp',formattedDt) );
        servAppNode.addChild( new XMLNode('ser:MessageType','REQUEST') );
        servAppNode.addChild( new XMLNode('ser:TargetID','LiveCycle') );
        
    }
    
    /*
     *  buildFormFieldMap is the main method
     *  FormName is Form_Rule__c.Name; '4015' for example.
     *  
     *
    */
    private static XMLNode buildFormFieldMap(String formName, Id docRequestId) {
        
        XMLNode grandParentNode = new XMLNode(true, 'Envelope', 
                                            'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:for="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/FormsReqSync" xmlns:ser="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ServiceApplicationArea" xmlns:lcf="http://tfs.toyota.com/LCFORMS/"', 
                                            'soapenv');
        
        addStaticValues(grandParentNode, docRequestId);
        
        FormField firstChildTmpFormField = new FormField();
        firstChildTmpFormField.destinationNode = 'soapenv:Body.for:FormsReqSync.for:ProcessService.for:FormsReqBOD.for:ListOfForms.for:LCForms|x.x';
        firstChildTmpFormField.lineItemField = true;
        firstChildTmpFormField.lineItemType = null;
        firstChildTmpFormField.targetField = '';
        //PARENT NODE IS THE ListOfForms.LCForms level.
        XMLNode parentNode = recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany(grandParentNode, firstChildTmpFormField.destinationNode, firstChildTmpFormField, null);
        
        
        
        
        Form_Field_Junction__c[] junctObjList = new Form_Field_Junction__c[]{};
        FormField[] formFieldList = new FormField[]{};
        Set<String> docRequestFields = new Set<String>();
        Set<String> lineItemFields = new Set<String>();
        String fieldName;
        for(Form_Field_Junction__c junctObj : [select form__r.name, Form_Field__r.Source_Field__c, Form_Field__r.Source_Object__c, 
                                                Form_Field__r.Target_Field__c, Form_Field__r.Line_item_field__c, 
                                                Form_Field__r.Line_item_type__c, Form_Field__r.WS_DestinationNode__c, 
                                                Form_Field__r.WS_Sequence__c
                                                from form_field_junction__c
                                                where form__r.name = :formName
                                                and Form_Field__r.WS_DestinationNode__c <> ''
                                                and Form_Field__r.WS_DestinationNode__c <> '#N/A'
                                                order by Form_Field__r.WS_Sequence__c]) 
        {
            //junctObjList.add(junctObj);
            formFieldList.add( new FormField(junctObj.Form_Field__r) );
            fieldName = junctObj.Form_Field__r.Target_Field__c.toUpperCase();
            if(junctObj.Form_Field__r.Line_item_field__c == true) {
                if(!lineItemFields.contains(fieldName)) {
                    lineItemFields.add(fieldName);
                }
            }else{
                if(!docRequestFields.contains(fieldName)) {
                    docRequestFields.add(fieldName);
                }
            }
        }
        
        Document_Request__c docRequest = queryDocRequest(docRequestId, docRequestFields, lineItemFields);
        
        XMLNode oneToManyNode;
        XMLNode dispatchesPrinterNode; //lcf:Request.lcf:Dispatches.lcf:Dispatch.DeviceName
        Map<String,XMLNode> mapOfOneToManyParentNodes = new Map<String,XMLNode>();
        Map<String,List<FormField>> oneToManyFormFieldRecords = new Map<String,List<FormField>>();
        
        //MAIN XML NODE GENERATION LOOP.
        for(FormField formFieldObj : formFieldList) {
            
            String destString = formFieldObj.destinationNode;
            //destString = object notation of data's destination; e.g. "Request.CreatedDate"
            
            //add node to main parent node.
            oneToManyNode = recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany(parentNode, destString, formFieldObj, docRequest);
            
            if( lastPropertyNode != null && formFieldObj.targetField == 'Dispatches_DeviceNameTransformed__c') {
                dispatchesPrinterNode = lastPropertyNode;
            }
            
            if(oneToManyNode != null) {
                //THEN THIS IS A ONE-TO-MANY DATUM.  ADD TO LISTS FOR LATER USE.
                String keyName = formFieldObj.lineItemType; //picklist; e.g. "CoCustomer"
                
                List<FormField> childListInMap = oneToManyFormFieldRecords.get(keyName);
                if(childListInMap == null) {
                    childListInMap = new List<FormField>(); 
                }
                childListInMap.add(formFieldObj);
                oneToManyFormFieldRecords.put(keyName, childListInMap);
                mapOfOneToManyParentNodes.put(keyName, oneToManyNode);
            }
            
        }
        
        
        if(docRequest.Document_Request_Line_Items__r != null && docRequest.Document_Request_Line_Items__r.size() > 0 && mapOfOneToManyParentNodes.size() > 0) {
            //the fields in Document_Request_Line_Items__r were dynamically appended to the soql query.
            //also, mapOfOneToManyParentNodes contains unique 'parent' nodes that should be populated with Document_Request_Line_Items__c.
            //so, here, we are looping through the nodes and populating them with the related data.
            System.debug(LoggingLevel.ERROR, '***** Document_Request_Line_Items__r not null *****');
            Map<String,List<Document_Request_Line_Item__c>> releventLineItems = new Map<String,List<Document_Request_Line_Item__c>>();
            for(Document_Request_Line_Item__c docLineItem : docRequest.Document_Request_Line_Items__r) {
                
                List<FormField> fieldListForType = oneToManyFormFieldRecords.get(docLineItem.Type__c);
                XMLNode parentNode1 = mapOfOneToManyParentNodes.get(docLineItem.Type__c);
                Boolean childrenAdded = false;
                Boolean allValuesEmpty = true;
                for(FormField fieldFormField : fieldListForType) {
                    childrenAdded = true;
                    if(docLineItem.get(fieldFormField.targetField) != null && docLineItem.get(fieldFormField.targetField) != '') {
                        allValuesEmpty = false;
                    }
                    String newDestString = fieldFormField.destinationNode;
                           newDestString = newDestString.substring(newDestString.indexOf('|') + 1);
                    //add datum and relevent nodes to parentNode1
                    recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany(parentNode1, newDestString, fieldFormField, docLineItem);
                }
                if(childrenAdded) {
                    Integer childNodeIndex = parentNode1.children.size() - 1;
                    XMLNode lastChildAdded = parentNode1.children.get(childNodeIndex);
                    parentNode1.childrenNodesByName.remove(lastChildAdded.name); //THIS IS DONE SO THAT Customers.Customer.Address(eg) DOES NOT GET OVERWRITTEN
                                                             //TWO XML-NODES WITH THE SAME NAME IN THE PARENT NODE WILL USE MAP.GET() (in recursivelyAppendNodesAndReturnLastChildNodeIfOneToMany) 
                                                             //TO DETERMINE IF CREATE-NEW AND TRAVERSE [OR ONLY TRAVERSE] TO NEXT CHILD NODE
                    if(allValuesEmpty) {
                        //completely remove node.
                        parentNode1.children.remove(childNodeIndex);
                    }
                }
            } //END docRequest.Document_Request_Line_Items__r LOOP
            
        }
        
        if( mapOfOneToManyParentNodes.size() > 0 ) {
            //now, Customers.CoCustomer cannot be empty if Customers exists.  Remove if empty.
            for(XMLNode nodeToPotentiallyRemove : mapOfOneToManyParentNodes.values()) {
                if(nodeToPotentiallyRemove.children == null || nodeToPotentiallyRemove.children.size() == 0) {
                    //then empty, remove from parent.
                    nodeToPotentiallyRemove.removeFromParent();
                }
            }
        }
        
        
        if(dispatchesPrinterNode != null && (dispatchesPrinterNode.value == null || dispatchesPrinterNode.value == '') ) {
            //then no printer selected.  remove node.
            XMLNode dispatchesNode = dispatchesPrinterNode.myParentNode.myParentNode ;
            dispatchesNode.removeFromParent();
            //lcf:Request.lcf:Dispatches.lcf:Dispatch.DeviceName
        }
            
        
        System.debug(LoggingLevel.ERROR, '***** xmlJive - ' + grandParentNode.getXmlString() + ' *****');
        
        return grandParentNode;
    }
    
    
    
    
    
    
    private static Document_Request__c queryDocRequest(Id docRequestId, Set<String> docRequestFields, Set<String> lineItemFields) {
        String queryString = 'select ';
        Boolean appendComma = false;
        for(String field : docRequestFields) {
            if(appendComma) {
                queryString += ', ';
            }
            queryString += field + ' ';
            appendComma = true;
        }
        
        if(lineItemFields.size() > 0) {
            queryString += ', (select Type__c ';
            for(String field2 : lineItemFields) {
                queryString += ', ';
                queryString += field2 ;
            }
            queryString += ' from Document_Request_Line_Items__r) ';
        }
            
        //queryString += ' from document_request__c where id = :docRequestId';
        if (!Test.isRunningTest()) {
            queryString += ' FROM document_request__c WHERE id = \'' + docRequestId +'\'';
        } else {
            queryString += ' Id FROM document_request__c WHERE id = \'' + docRequestId +'\'';
        }
        
        System.debug(LoggingLevel.ERROR, '***** queryString - ' + queryString + ' *****');
        
        Document_Request__c docRequest = database.query(queryString);
        return docRequest;
    }
    
    
    private static ResponseRecord executeHttpRequest(XMLNode parentNode) {
        String bodyString = parentNode.getXmlString();
        String username = System.UserInfo.getOrganizationId();
        String password = username;            
        Blob authCredBlob = Blob.valueOf(username + ':' + password);
        String authCred = EncodingUtil.base64Encode(authCredBlob);
        
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.RL_Document_Generation_Endpoint);
        req.setMethod('POST');
        req.setBody(bodyString);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '""');
        //req.setHeader('Accept-Encoding', 'gzip,deflate');
        req.setHeader('Authorization', 'Basic ' + authCred);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        ResponseRecord responseRecord = parseXmlResponse(res);
        
        System.debug(LoggingLevel.ERROR, '**** response:'+res.getBody()) ;
        return responseRecord;
    }
    
    private static ResponseRecord parseXmlResponse(HTTPResponse response) {
        
        String xml = response.getBody();
        XmlStreamReader reader = new XmlStreamReader(xml);
        
        String resultCode;
        String resultDesc;
        String resultString;
        
        if(xml.contains('ns1:ResultDesc')) {
            resultDesc = xml.substring( xml.indexOf('<ns1:ResultDesc xmlns:ns1="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ResultBOD">') + 100 );
            resultDesc = resultDesc.substring(0, resultDesc.indexOf('<')); 
        }
        if(xml.contains('ns1:ResultString')) {
            resultString = xml.substring( xml.indexOf('<ns1:ResultString xmlns:ns1="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ResultBOD">') + 102 );
            resultString = resultString.substring(0, resultString.indexOf('<')); 
        }
        if(xml.contains('ns1:ResultCode')) {
            resultCode = xml.substring( xml.indexOf('<ns1:ResultCode xmlns:ns1="http://www.tfs.com/TFS/SharedComponents/ServiceSchemas/Common/ResultBOD">') + 100 );
            resultCode = resultCode.substring(0, resultCode.indexOf('<')); 
        }
        
        
        
        ResponseRecord responseObj = new ResponseRecord();
        responseObj.ResultString = resultString;
        responseObj.ResultDesc = resultDesc;
        if(resultCode != null) {
            responseObj.ResultCode = Integer.valueOf(resultCode);
        }else{
            if(resultString == null) {
                responseObj.ResultCode = -225;
                responseObj.ResultString = xml;
            }
        }
        
        System.debug(LoggingLevel.ERROR, '**** ResponseRecord: ' + '; ' + resultDesc + '; ' + resultCode + '; ' + resultString) ;
        
        return responseObj;
    }
    
    public static ResponseRecord callDocGenerationWebService(String formName, Id docRequestId) {
        
        //XMLNode parentNode = buildFormFieldMap('4015CA', 'a0WQ0000003eck0MAA');
        XMLNode parentNode = buildFormFieldMap(formName, docRequestId);
        ResponseRecord responseRecord = executeHttpRequest(parentNode);
        responseRecord.RequestString = parentNode.getXmlString();
        return responseRecord;
        /*
        XMLNode parentNode = new XMLNode('Envelope', 
                                            'xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"', 
                                            true);
        
        XMLNode requestNode = new XMLNode('Request','',true);
        requestNode.addChild( new XMLNode('CreationDate', '2012-12-13','') );
        requestNode.addChild( new XMLNode('MailingDate', '2012-12-13','') );
        requestNode.addChild( new XMLNode('PrintDate', '2012-12-13','') );
        requestNode.addChild( new XMLNode('FormType', 'Interactive','') );
        requestNode.addChild( new XMLNode('ReturnDocument', 'true','') );
        requestNode.addChild( new XMLNode('ReturnEnvelope', 'true','') );
        requestNode.addChild( 
            new XMLNode('Dispatches', '',true).addChild(
                new XMLNode('Dispatch', '',true).addChildren(
                    new XMLNode[]{
                        new XMLNode('Name','Print Central'),
                        new XMLNode('DocumentOutput','Flattern PDF'),
                        new XMLNode('DeviceName','str1234')
                    }
                )
            )
        );
        parentNode.addChild(requestNode);
        
        
        System.debug('***** xmlJive - ' + parentNode.getXmlString() + ' *****');
        */
        
    }
    
    
    
    private class XMLNode {
        
        public String name;
        public String value;
        public String nameSpaceString;
        public String nameSpacePrefix;
        
        public XMLNode myParentNode;
        
        public List<XMLNode> children;
        public Map<String,XMLNode> childrenNodesByName;
        
        public XMLNode get(String propName) {
            return childrenNodesByName.get(propName);
        }
        
        public String getXmlString() {
            String strToReturn = '<';
            if(nameSpacePrefix != null && nameSpacePrefix != '') {
                strToReturn += nameSpacePrefix + ':';
            }
            strToReturn += name;
            if(nameSpaceString != null && nameSpaceString != '') {
                strToReturn += ' ' + nameSpaceString;
            }
            strToReturn += '>';
            
            //GET CHILD XML STRINGS
            if(children != null) {
                for(XMLNode childNode : children) {
                    strToReturn += childNode.getXmlString();
                }
            }else if(value != null && value != ''){
                strToReturn += value;
            }
            
            strToReturn += '</';
            if(nameSpacePrefix != null && nameSpacePrefix != '') {
                strToReturn += nameSpacePrefix + ':';
            }
            strToReturn += name + '>';
            
            return strToReturn;
        }
        
        
        public XMLNode(String nodeName, String nodeValue) {
            this.name = nodeName;
            this.value = nodeValue;
            this.nameSpaceString = '';
            this.nameSpacePrefix = '';
        }
        public XMLNode(String nodeName, String nodeValue, String nameSpaceString, String nameSpacePrefix) {
            this.name = nodeName;
            this.value = nodeValue;
            this.nameSpaceString = nameSpaceString;
            this.nameSpacePrefix = nameSpacePrefix;
        }
        public XMLNode(Boolean initChildren, String nodeName, String nameSpaceString, String nameSpacePrefix) {
            this.name = nodeName;
            this.nameSpaceString = nameSpaceString;
            this.nameSpacePrefix = nameSpacePrefix;
            
            this.children = new List<XMLNode>();
            this.childrenNodesByName = new Map<String,XMLNode>();
        }
        
        public XMLNode addChildren(List<XMLNode> childrenToAdd) {
            //children.addAll(childrenToAdd);
            for(XMLNode child : childrenToAdd) {
                addChild(child);
            }
            return this;
        }
        public XMLNode addChild(XMLNode child) {
            child.myParentNode = this;
            children.add(child);
            childrenNodesByName.put(child.name, child);
            return this;
        }
        
        public void removeFromParent() {
            if(myParentNode != null) {
                myParentNode.childrenNodesByName.put(this.name,null);
                Integer i = -1;
                Integer n = 0;
                for(XMLNode parentsChild : myParentNode.children) {
                    if(parentsChild == this) {
                        i = n;
                    }
                    n++;
                }
                if(i > -1) {
                    myParentNode.children.remove(i);
                }
            }
        }
        
    }
    
    
    private class FormField {
        
        public String destinationNode;
        public String targetField;
        public String lineItemType;
        public Boolean lineItemField;
        
        public FormField(Form_Field__c ff) {
            this.destinationNode = ff.WS_DestinationNode__c;
            this.targetField = ff.Target_Field__c;
            this.lineItemField = ff.Line_item_field__c;
            this.lineItemType = ff.Line_Item_type__c;
        }
        
        public FormField() {
        }
        
    }
    

}