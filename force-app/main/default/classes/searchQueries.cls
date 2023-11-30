public class searchQueries {
//save queries on opportunity line item save
//TEST CLASS IS IN test_cpqApexTags --> https://advancedturf--full.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage
    @AuraEnabled
    public static string createQueries(List<Query__c> queryList){
        string mess; 
        list<Query__c> toUpsert = new list<Query__c>();

            for(Query__c x : queryList){
            	Query__c ol = new Query__c();
                system.debug(x.recordTypeId); 
                ol.RecordTypeId = x.recordTypeId;
                ol.Opportunity__c = x.Opportunity__c;
                ol.Term__c = x.Term__c;
                ol.Query_Size__c = x.Query_Size__c;
                ol.Search_Index__c = x.Search_Index__c;
        		ol.Opportunity_Product__c = x.Opportunity_Product__c;
                ol.ATS_Score__c = x.ATS_Score__c;
                ol.Tag__c = x.Tag__c;
                ol.Search_Label__c	= x.Search_Label__c;
                ol.Device_Type__c = x.Device_Type__c; 
      
            toUpsert.add(ol);
        }
      		
            
        
        try{
           Database.UpsertResult[] res = Database.upsert(toUpsert);
            
            mess = 'success';
        }catch(exception e){
            mess = string.valueOf(e);
            system.debug(e); 
        }
        system.debug('mess ------>'+mess); 
        return mess; 
    }
}