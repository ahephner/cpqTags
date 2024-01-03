public with sharing class cpqTagsSearch {
    @AuraEnabled(cacheable = true)
       public static list<tag__c> searchTag(string searchKey){
            string searchterm = '%' + searchKey + '%'; 
            
           list<tag__c> tags = Database.query('select Id, Product_Name__c, ATS_Score__c, Tag_description__c, Product__c ' 
                                              +' from tag__c where Search_Slug_2__c like :searchterm order by ATS_Score__c desc nulls last'); 
           return tags; 
       }
       
       
               @AuraEnabled(cacheable = true)
       public static list<Tag__c> searchTagSOSL(string searchKey){
            //string searchTerm = searchKey +' order by ATS_Score__c desc nulls last)'; 
           list<Tag__c> tagList = new list<Tag__c>();
            
           //String searchquery='FIND \''+searchKey+'\'IN ALL FIELDS RETURNING Tag__c(id, Tag_Description__c, Search_Slug_2__c,'
                               //+' Product__c, Product_Name__c, ATS_Score__c where product__r.IsActive = true)'; 
           string inputs = searchKey; 
           List<List<SObject>>searchList=search.query(searchKey);
            
           //List<List<sObject>> searchList = [FIND 'ants or stock' IN ALL FIELDS RETURNING Tag__c(id, Tag_Description__c, Search_Slug_2__c,Product__c, Product_Name__c, ATS_Score__c where product__r.IsActive = true)];
           tagList = searchList[0]; 
           return tagList;
       }
       
       //Used to search the tag system. The query is created in tagHelper and prodSearchTags. 
       //We are slow rolling out the product update insert from Tracie's GP job to append the WH123 to the new tag to the tail end
       //In an effort to not disappoint users we look and see if the tag that contains the warehouse number exisits. If not we have a fallback search
       //that removes the wh123 from the search string and pass to apex. 
       public with sharing class searchWrapper {
           @AuraEnabled
           public list<Tag__c> tags {get; set;}
           @AuraEnabled 
           public boolean backUpSearchUsed {get; set;}
       }
       @AuraEnabled(cacheable = true)
       public static searchWrapper cpqSearchTag(string searchKey, boolean searchWareHouse, string backUpSearch ){
           searchWrapper sw = new searchWrapper(); 
           List<List<SObject>>searchList = new List<List<SObject>>();	
           
           searchList=search.query(searchKey);    
     
           
           if(searchWarehouse && searchList[0].isEmpty()){
               searchList=search.query(backUpSearch);
               sw.tags = searchList[0];
               sw.backUpSearchUsed = true;
           }else if(!searchList[0].isEmpty()){
               sw.tags = searchList[0];
               sw.backUpSearchUsed = false; 
           }
           
           return sw;
       }
           @auraEnabled(cacheable = true)
       public static list<Search_Label__c> searchPromos(string query){
           date today = date.today();
           string searchTerm = '%'+query+'%';
           //IF I give up on the idea of being able to display products on the promo card and onlly search labels
           //list<Search_Label__c> currentPromos = [select id,Name, Expiration_Date__c, Description__c from Search_Label__c
             //                   				  where Expiration_Date__c >= :today and Label_Category__c= 'Promotional' 
             //                                    and Name like : searchTerm order by Expiration_Date__c DESC]; 
           
           list<Search_Label__c> searchRes = [select id,Name, Expiration_Date__c,Description__c,
                                        Promo_Discount__c from Search_Label__c
                                        where Expiration_Date__c >= :today and Label_Category__c = 'Promotional'
                                        and Name like : searchTerm order by Expiration_Date__c DESC limit 10];
           return searchRes; 
       }
       
           @auraEnabled(cacheable = true)
       public static list<Search_Label__c> onLoadPromos(){
           date today = date.today();
           
           list<Search_Label__c> currentPromos = [select id, name, expiration_date__c, description__c, promo_discount__c 
                                                   from search_label__c
                                                   where expiration_date__c >=: today and Label_Category__c = 'Promotional'
                                                   order by Expiration_Date__c ASC limit 10];
   
           return currentPromos; 
       }
       @auraEnabled(cacheable = true)
       public static list<Tag__c> onLoadTagPromos(){
           date today = date.today();
                   
           list<tag__c> promoTag = [select id, name, Product_Name__c, Search_Label__r.Name, Search_Label__r.Expiration_Date__c,
                                   Search_Label__r.Description__c
                                   from Tag__c where Search_Label__r.expiration_date__c >=: today and Search_Label__r.Label_Category__c = 'Promotional'];
           return promoTag; 
       }
       
       //get selected products
       //@AuraEnabled
       //public static PricebookEntry selectedProducts(string productIds, string priceBookId){
         //string pbId = priceBookId;  
         //string pClass = 'Simple';
         
         //String query = 'Select Id,'
                   //+ '  Product2.ProductCode, Product2.Name, Product2.Product_Status__c, Product2.Product_Family__c, Product2.Subcategory__c, Product2.Ship_Weight__c, Product2.Pallet_Qty__c,'
                   //+ '  Product2.Floor_Type__c, Product2.Floor_Price__c, Product2.Last_Purchase_Price__c, Agency_Product__c, product2.Total_Product_Items__c, Product2.Temp_Unavailable__c,'
                     //+ ' Floor_Price__c, Level_1_UserView__c, Level_One_Margin__c, Level_2_UserView__c, Level_2_Margin__c, Product_Cost__c, Product2.Temp_Mess__c, Product2.SGN__C'
                   //+ ' From PricebookEntry Where IsActive = True and Pricebook2Id =: pbId AND Product2.ProductClass =:pClass AND Product2Id =:productIds' ; 
                  
         //PricebookEntry results = Database.query(query);
               
         //return results; 
       //}
   }