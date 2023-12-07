public with sharing class lwcHelper {

    //This will allow you to get picklist values back from any object. Passs objectname then field API name
    public class pickListBack {
    @AuraEnabled public String label;
    @AuraEnabled public String value;
}
    @AuraEnabled(cacheable = true)
    public static List<pickListBack> getPickListValues(string objName, string fieldAPI){
        Schema.SObjectType sob = Schema.getGlobalDescribe().get(objName) ;
		Schema.DescribeSObjectResult dr = sob.getDescribe();
		Map<String,Schema.SObjectField> fields = dr.fields.getMap() ;
		Schema.DescribeFieldResult fieldResult = fields.get(fieldAPI).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<pickListBack> mapBack = new List<pickListBack>();
        
        for(Schema.PicklistEntry x: ple){
            pickListBack singlePLB = new pickListBack();
            singlePLB.label = x.getLabel(); 
            singlePLB.value = x.getValue(); 
            mapBack.add(singlePLB); 
        }
     
        return mapBack; 
    }
    
    //This will return the location # that is the main location for user. Will allow you to start searchs to my location
        @AuraEnabled(cacheable = true)
    public static string userLocation(string userId){
        string warehouse = [select my_location__c from user where id =:userId].My_Location__c; 
        return warehouse; 
    }
    
    
    //get all warehouse that store product items. 
	@AuraEnabled(cacheable = true)
    public static List<Schema.Location> getWarehouse(){
        List<Schema.Location> warehouse = [select id, name, Location_Number__c from Location 
                                           where IsInventoryLocation =true and LocationType = 'ATS' and name like '%ATS%'
                                          order by Location_Number_Number__c asc];
        
        return warehouse; 
    }
     

     @AuraEnabled(cacheable = true) 
public static Map<String, List<Map<String,String>>> multiplePicklists2(String objectName, String picklistFields) {

    if(string.isNotBlank(picklistFields)){            
        Map<String, List<Map<String,String>>> picklistValuesMap = new Map<String, List<Map<String,String>>>();

        for(String picklistField : picklistFields.split(',')){                
            picklistField = picklistField.trim();
            
            Schema.DescribeFieldResult stagesFR = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(picklistField).getDescribe();
            List<Schema.PicklistEntry> stagesPle = stagesFR.getPicklistValues();

              List<Map<String,String>> valuesList = new List<Map<String,String>>();

            for( Schema.PicklistEntry s : stagesPle){
              
                valuesList.add(new Map<String, String> {
                    	'label' => s.getLabel(),
                        'value' => s.getValue()
                        });
            }                
            picklistValuesMap.put(picklistField, valuesList);                
        }            
        return picklistValuesMap;            
    }        
    return null;        
}   
         @AuraEnabled(cacheable = true) 
    public static id getRecordTypeId(string objectName, string recTypeName){
        Id recId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
        return recId; 
    }
    //public static ConnectApi.CommerceSearchIndex postCommerceSearchIndex(String webstoreId){
        //string storeId = webStoreId;
       // ConnectApi.CommerceSearchIndex searchIndex = ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(storeId, ConnectApi.CommerceSearchIndexBuildType.Incremental);
        //searchIndex.CommerceSearchIndexBuildType();  
       // system.debug(searchIndex);
     //   return null;
        
   // }
    
}