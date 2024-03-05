public with sharing class getPriceBooks {
    @AuraEnabled(cacheable=true)
  public static list<buyergrouppricebook> getPriceBookIds(string accountId){
        list<String> multiGroups = new list<string>();        
            for(buyergroupmember x: [select buyergroupid, name from buyergroupmember where buyerid =: accountId ]){
                multiGroups.add(x.buyergroupid);
            }
            list<buyergrouppricebook> pricebookIds = new list<buyergrouppricebook>();
            if(multiGroups.size()>0){
                
                //limit to active price book
                for(buyergrouppricebook y: [select Pricebook2Id, Pricebook2.Name, Name from buyergrouppricebook where buyergroupid IN: (multiGroups)]){
                    system.debug('y '+ y); 
                    
                    pricebookIds.add(y);
                }
           } 
        return pricebookIds; 
         
    }
}