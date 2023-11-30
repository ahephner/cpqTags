public class cpqApexTags {
    //wrapper for returning product info
    public with sharing class prodWrapper {
        @AuraEnabled
        public pricebookentry selectedProduct {get; set;}
        @AuraEnabled 
        public productitem inventory {get; set;}
        @AuraEnabled
        public Sales_Doc_Detail__c lastPaid {get; set;}
        @AuraEnabled
        public OpportunityLineItem lastQuote {get;set;}
        @AuraEnabled 
        public Object lastThirty {get;set;}
    }
    
    @AuraEnabled(cacheable = true)
    public static list<prodWrapper> getDetails(string pId, string locationId, string accId, string pc, string recId,string priceBookId){
        //wrapper to return to lwc
        List<prodWrapper> prodList = new List<prodWrapper>();
        ProductItem count = null;
        sales_doc_detail__c order = null;
        OpportunityLineItem quoteInfo;
        //set up vars
      string pbId = priceBookId;
      string productId = pId; 
      string pClass = 'Simple';
      string locId = locationId;
      string accountId = accId; 
      string code = pc; 
      string opportunityId = recId; 
      date minusThirty = Date.today().addDays( -30 );
      
        //single product query
      String query = 'Select Id,'
                + '  Product2.ProductCode, Product2.Name, Product2.Product_Status__c, Product2.Product_Family__c, Product2.Subcategory__c, Product2.Ship_Weight__c, Product2.Pallet_Qty__c,'
                + '  Product2.Floor_Type__c, Product2.Floor_Price__c, Product2.Last_Purchase_Price__c, Agency_Product__c, product2.Total_Product_Items__c, Product2.Temp_Unavailable__c,'
          		+ ' Floor_Price__c, Level_1_UserView__c, Level_One_Margin__c, Level_2_UserView__c, Level_2_Margin__c, Product_Cost__c, Product2.Temp_Mess__c, Product2.SGN__c,'
          		+ ' Product2.RUP__c'
                + ' From PricebookEntry Where IsActive = True and Pricebook2Id =: pbId AND Product2.ProductClass =:pClass AND Product2Id =:productId' ; 
     	list<PricebookEntry> results = Database.query(query);
         
      
        //Inventory query
        list<ProductItem> countList = [select id, QuantityOnHand, Quantity_Available__c from productitem 
                            	      where Product_Class__c=:pClass and LocationId =:locId 
                                      and Product2Id =:productId limit 1];
            
        
        //last paid query
        List<sales_doc_detail__c> orderList = [select id,name,Unit_Price__c,Margin__c, Doc_Date__c from sales_doc_detail__c
                				  	 			where Product_Code__c =: code and Sales_Document__r.customer__c =: accountId
                				  	 			order by Sales_Document__r.doc_date__c desc
                				  	 			limit 1];
        
        //last quote
        List<OpportunityLineItem> quoteList = [select Product2Id, Last_Quote_Price__c ,Last_Quote_Margin__c,Quote_Date__c, ProductCode
                                               from OpportunityLineItem where ProductCode =: Code and Account__c =: accountID
                                               and OpportunityId !=:opportunityId
                				  	 			order by LastModifiedDate desc limit 1];
        
        
        AggregateResult [] result = [select sum(qty__c)ttt from Sales_Doc_Detail__c where Product__r.Product_Code__c = :Code and Sales_Document__r.Doc_Date__c >=:minusThirty];
       
        if(!results.isEmpty()){
            for(pricebookentry pb:results){
                prodWrapper pw = new prodWrapper();
                pw.selectedProduct = results[0];
                pw.inventory = countList.size() > 0 ? countList[0] : null;
                pw.lastPaid = orderList.size() > 0 ? orderList[0] : null; 
                pw.lastQuote = quoteList.size() > 0 ? quoteList[0] : null;
                pw.lastThirty = result[0].get('ttt'); 
                prodList.add(pw); 
            }
        }
        
        return prodList; 
    }
    
        //wrapper for returning product info
    public with sharing class promoWrapper {
        @AuraEnabled
        public list<pricebookentry> promoProduct {get; set;}
        @AuraEnabled 
        public list<tag__c> qtyTag {get; set;}
    }
    
    //For Promo Adding products
    @AuraEnabled(cacheable = true)
    public static promoWrapper promoDetails(string pId, string locationId, string accId, string pc, string recId,string priceBookId){
      string pbId = priceBookId;
      string labelId = pId; 
      string pClass = 'Simple';
      string locId = locationId;
      string accountId = accId; 
      string code = pc; 
      string opportunityId = recId; 
      list <string> prodIds = new list<string>();    
      promoWrapper pw = new promoWrapper();
        
      list<Tag__c> tags = [select id,  Product__c,Quantity__c from Tag__c where Search_Label__c =:labelId ];
        
        for(Tag__c x :tags){
            prodIds.add(x.Product__c);
        }
        

      String query = 'Select Id,'
                + '  Product2.ProductCode, Product2.Name, Product2.Product_Status__c, Product2.Product_Family__c, Product2.Subcategory__c, Product2.Ship_Weight__c, Product2.Pallet_Qty__c,'
                + '  Product2.Floor_Type__c, Product2.Floor_Price__c, Product2.Last_Purchase_Price__c, Agency_Product__c, product2.Total_Product_Items__c, Product2.Temp_Unavailable__c,'
          		+ ' Floor_Price__c, Level_1_UserView__c, Level_One_Margin__c, Level_2_UserView__c, Level_2_Margin__c, Product_Cost__c, Product2.Temp_Mess__c, Product2.SGN__c,'
          		+ ' Product2.RUP__c'
                + ' From PricebookEntry Where IsActive = True and Pricebook2Id =: pbId AND Product2.ProductClass =:pClass AND Product2Id in :prodIds' ; 
     	list<PricebookEntry> results = Database.query(query);
		
        if(results.size()>=1){
            pw.promoProduct = results;
            pw.qtyTag = tags; 
        }
system.debug('====> '+pw); 
        return pw; 
    }
    
    
}