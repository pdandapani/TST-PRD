public class TFS_GetSchemaDescribe {
    
    public static void getFieldLabelAndNameCSV(String objectName)
    {
        
        String fldLabelCSV = '';
        String fldNameCSV = '';
        
        // get meta-data field names using schema describe
        Schema.DescribeSObjectResult[] descResults = Schema.describeSObjects(new String[]{ objectName });

        for(Schema.DescribeSobjectResult res : descResults) {
            
            Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
            
            for(String key : fieldsMap.keySet() ) {

                Schema.SObjectField fld = fieldsMap.get(key);
                
                Schema.DescribeFieldResult dfr = fld.getDescribe();

                if( fldLabelCSV != '' ) 
                    fldLabelCSV = fldLabelCSV + ',';
                    
                if( fldNameCSV != '' )   
                    fldNameCSV = fldNameCSV + ',';
                    
                fldLabelCSV = fldLabelCSV + dfr.getLabel();
                fldNameCSV = fldNameCSV + dfr.getName();
            }
        } 
        System.debug( 'Label = ' + fldLabelCSV );
        System.debug( 'Name = ' + fldNameCSV );
    }
}