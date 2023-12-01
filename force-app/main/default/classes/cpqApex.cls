//due to the community using variations on the product2.productclass. We need to make sure we are only looking at the simple. 
//Needs to be declared in any product search or product item inventory search
public with sharing class cpqApex {
    
    //get pricebooks
    @AuraEnabled(cacheable = true)
    public static list<priceBookWrapper> getPriceBooks(){
        list<priceBookWrapper> pw = new list<priceBookWrapper>();
        
        for(Pricebook2 x :[select id, name from Pricebook2 where IsActive = true]){
            pw.add(new priceBookWrapper(x.name, x.id));
        }
        return pw; 
    }
	//Product Search
	@AuraEnabled 
  public static PricebookEntry[] searchProduct(string searchKey, string cat, string family, string priceBookId){
      string searchterm = '%' + searchKey + '%'; 
      string category = cat; 
      string pf = family; 
      string pbId = priceBookId;  
      string pClass = 'Simple';
      system.debug(searchterm);
      String query = 'Select Id,'
                + '  Product2.ProductCode, Product2.Name, Product2.Product_Status__c, Product2.Product_Family__c, Product2.Subcategory__c, Product2.Ship_Weight__c, Product2.Pallet_Qty__c,'
                + '  Product2.Floor_Type__c, Product2.Floor_Price__c, Product2.Last_Purchase_Price__c, Agency_Product__c, product2.Total_Product_Items__c, Product2.Temp_Unavailable__c,'
          		+ ' Floor_Price__c, Level_1_UserView__c, Level_One_Margin__c, Level_2_UserView__c, Level_2_Margin__c, Product_Cost__c, Product2.Temp_Mess__c, Product2.SGN__C, RUP__c'
                + ' From PricebookEntry Where IsActive = True and Pricebook2Id =: pbId AND Product2.ProductClass =:pClass AND' ; 
                 
      if(!searchterm.contains('null') && category == 'All' && pf == 'All'){
          //system.debug('1');
          query += ' (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm)';
         /// system.debug('2');
      }else if (!searchterm.contains('null') && category != 'All' && pf == 'All'){
          //system.debug('3');
          query += ' (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm) and Product2.subcategory__c =:category';
      }else if(!searchterm.contains('null') && category == 'All' && pf != 'All'){
          //system.debug('4');
          query += ' (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm) and Product2.Product_Family__c =:pf';
      }else if(!searchterm.contains('null') && category != 'All' && pf != 'All'){
          //system.debug('5');
          query += ' (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm) and Product2.Product_Family__c =:pf and Product2.subcategory__c =:category';
      }else if (searchterm.contains('null') && category != 'All' && pf == 'All'){
          //system.debug('6');
          query += ' Product2.subcategory__c =:category';
      }else if(searchterm.contains('null')  && category == 'All' && pf != 'All'){
          //system.debug('7');
          query += ' Product2.Product_Family__c =:pf';
      }else if(searchterm.contains('null') && category != 'All' && pf != 'All'){
          //system.debug('8');
          query += ' Product2.Product_Family__c =:pf and Product2.subcategory__c =:category'; 
      }else{
 
      }	
	query += ' order by Product_Status__c  desc nulls last';     	 
       
       list<PricebookEntry> results = Database.query(query);
	    	
      return results; 
  } 
    @AuraEnabled 
  public static PricebookEntry[] mobileSearchProduct(string searchKey, string cat, string family, string priceBookId){
      string searchterm = '%' + searchKey + '%'; 
      string category = cat; 
      string pf = family; 
      string pbId = priceBookId;  
      string pClass = 'Simple';
      //system.debug('pf '+pf+ ' cat '+category+ ' searchterm ' +searchterm);
      String query = 'Select Id,'
                + '  Product2.ProductCode, Product2.Name, Product2.Product_Status__c,UnitPrice, Product2.Product_Family__c, Product2.Subcategory__c, Product2.Ship_Weight__c,Product2.Pallet_Qty__c,'
                + '  Level_1_Price__c, Level_2_Price__c, Product2.Floor_Type__c, Product2.Floor_Price__c, Product2.Last_Purchase_Price__c, Agency_Product__c, product2.Total_Product_Items__c,RUP__c,'
          		+ ' Floor_Price__c, Level_1_UserView__c, Level_One_Margin__c, Level_2_UserView__c, Level_2_Margin__c, Product_Cost__c, Product2.Temp_Unavailable__c, Product2.Temp_Mess__c, Product2.SGN__c'
                + ' From PricebookEntry Where IsActive = True and Pricebook2Id =: pbId AND Product2.ProductClass =:pClass ' ;
                 
      if(searchterm != '%%' && category == 'All' && pf == 'All'){
          //system.debug('1');
          query += ' AND (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm)';
          //system.debug('2');
      }else if (searchterm != '%%' && category != 'All' && pf == 'All'){
          //system.debug('3');
          query += ' AND (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm) and Product2.subcategory__c =:category';
      }else if(searchterm != '%%' && category == 'All' && pf != 'All'){
         // system.debug('4');
          query += ' AND (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm) and Product2.Product_Family__c =:pf';
      }else if(searchterm != '%%' && category != 'All' && pf != 'All'){
          //system.debug('5');
          query += ' AND (Product2.ProductCode like :searchTerm or Product2.Name like :searchTerm) and Product2.Product_Family__c =:pf and Product2.subcategory__c =:category';
      }else if (searchterm == '%%' && category != 'All' && pf == 'All'){
         // system.debug('6');
          query += ' AND Product2.subcategory__c =:category';
      }else if(searchterm == '%%'  && category == 'All' && pf != 'All'){
          //system.debug('7');
          query += ' AND Product2.Product_Family__c =:pf';
      }else if(searchterm == '%%' && category != 'All' && pf != 'All'){
          //system.debug('8');
          query += ' AND Product2.Product_Family__c =:pf and Product2.subcategory__c =:category'; 
      }else{
 			
      }	
      	 query += ' order by Product_Status__c  desc nulls last';    
       
       list<PricebookEntry> results = Database.query(query);
	    	
      return results; 
  } 
    //get contact point address for shipping info
    @AuraEnabled
    public static list<ContactPointAddress> getAddress(string accID){
        List<ContactPointAddress> address = new List<ContactPointAddress>();
        system.debug('accID '+accID);
        List<ContactPointAddress> searchAdd = [select id, name, AddressType, street, city,
                                               state, postalcode from ContactPointAddress where parentid =: accID];
        
        if(!searchAdd.isEmpty()){
            address = searchAdd; 
        }
        return address; 
    }
    //this allows the user to switch the inventory check on the product screen 
    @AuraEnabled(cacheable = true)
    public static list<productitem> inCounts(list<string> pc, string locId){
        list<productitem> counts = new list<productitem>();
         
        if(locId == 'All'){
            
            counts = [select Total_Product_Items__c, Product_Code__c,Quantity_Available__c from
                                    ProductItem where Product_Class__c = 'Simple' and Product_Code__c In :(pc)];
            
        }else{
            counts = [select QuantityOnHand, Product_Code__c, Quantity_Available__c from
                             ProductItem where Product_Class__c = 'Simple' and LocationId =: locId 
                             and Product_Code__c In :(pc)];
        
        }

        return counts; 
    }
    //this is where we try and get the inventory. For now we are gonna show the inventory across all locations
    //then will get at that location on select similar to last paid. 
    @AuraEnabled(cacheable = true)
        public static list<productitem> inventoryCount(list<id> ids){
            list<productitem> counts = [select id, quantityonhand,Product2Id, Quantity_Available__c from productitem
                                       where product2Id in : ids and Product_Class__c = 'Simple'];
            
            return counts; 
        }
//NOT used. Was going to be a part of allowing reps to change price books
    //@AuraEnabled(cacheable = true)
    //public static id getStandardId(string prodCode){
      //  id sID = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Name LIKE '%Standard%' AND Product2.ProductCode =: prodCode limit 1].Id;
        //system.debug('prodCode '+ prodCode);
        //system.debug('sId '+ sId);
        //return sId; 
   // }
    @AuraEnabled(cacheable=true)
    public static Sales_Doc_Detail__c getLastPaid(string accountID, string Code){
        sales_doc_detail__c order = null; 
        List<sales_doc_detail__c> orderList =  [select id,name,Unit_Price__c,Margin__c, Doc_Date__c from sales_doc_detail__c
                				  	 			where Product_Code__c =: code and Sales_Document__r.customer__c =: accountId
                				  	 			order by Sales_Document__r.doc_date__c desc
                				  	 			limit 1];
        if(!orderList.isEmpty()){
            order = orderList[0];
        }
        //system.debug(order);
        return order; 
    }
    @AuraEnabled(cacheable=true)
    public static ProductItem getInventory(string locId, string pId){
        ProductItem count = null;
        
        list<ProductItem> countList = [select id, QuantityOnHand, Quantity_Available__c from productitem 
                            	      where Product_Class__c= 'Simple' and LocationId =:locId 
                                      and Product2Id =:pId limit 1];
        
        if(!countList.isEmpty()){
            count = countList[0];
        }
        return count;
    }
    
      @AuraEnabled(cacheable=true)
    public static OpportunityLineItem getLastQuote(string accountID, string Code, string opportunityId){
        OpportunityLineItem quoteInfo;
      	//system.debug('opId '+opportunityId); 
        //system.debug('code '+ code);
        //system.debug('accId '+accountID); 
        list<OpportunityLineItem> quoteList = [select Product2Id, Last_Quote_Price__c ,Last_Quote_Margin__c,Quote_Date__c, ProductCode
                                               from OpportunityLineItem where ProductCode =: Code and Account__c =: accountID
                                               and OpportunityId !=:opportunityId
                				  	 			order by LastModifiedDate desc limit 1];
      
        if(!quoteList.isEmpty()){
            quoteInfo = quoteList[0];
        }
        return quoteInfo;
    }
    
        //save products
    @AuraEnabled
    public static list<OpportunityLineItem> createProducts(List<OpportunityLineItem> olList, string oppId, string accId){
        
        system.debug(olList);
        //system.debug(accId);
        list<OpportunityLineItem> toUpsert = new list<OpportunityLineItem>();
        list<opportunityLineItem> toReturn = new List<OpportunityLineItem>();
        list<id> newPricebookEntry = new list<id>();
      
            for(OpportunityLineItem x : olList){
            OpportunityLineItem ol = new OpportunityLineItem();
            if(String.isBlank(x.Id)){
                //ol.Id = x.Id;
                //system.debug(x.Ship_Weight__c); 
            ol.PricebookEntryId = x.PricebookEntryId;
            ol.Product2Id = x.Product2Id;
            ol.Quantity = x.Quantity;
            ol.CPQ_Unit_Price__c = x.UnitPrice;
            ol.UnitPrice = x.UnitPrice;
            ol.CPQ_Margin__c = x.CPQ_Margin__c;
            ol.Cost__c = x.Cost__c;
            ol.Description = x.Description;
            ol.Single_Product_Weight__c  = x.Ship_Weight__c;
            ol.Discount = x.Discount; 
            ol.OpportunityId = x.OpportunityId;
            ol.Line_Order__c = x.Line_Order__c; 
            ol.Account__c = accId; 
                newPricebookEntry.add(x.PricebookEntryId);
        }else if(!String.isBlank(x.Id)){
            system.debug(x.UnitPrice);
            system.debug(x.Quantity);
            ol.Id = x.Id; 
            //ol.PricebookEntryId = x.PricebookEntryId;
            //ol.Product2Id = x.Product2Id;
            ol.Quantity = x.Quantity;
            ol.CPQ_Unit_Price__c = x.UnitPrice;
            ol.UnitPrice = x.UnitPrice;
            ol.CPQ_Margin__c = x.CPQ_Margin__c;
            ol.Cost__c = x.Cost__c;
            ol.Single_Product_Weight__c  = x.Ship_Weight__c;
            ol.Description = x.Description;
            ol.Account__c = accId;
            ol.Discount = x.Discount;  
            ol.Line_Order__c = x.Line_Order__c;
            //ol.OpportunityId = x.OpportunityId;
        }
            
      
            toUpsert.add(ol);
        }
      		
            
        
        try{
           Database.UpsertResult[] res = Database.upsert(toUpsert);
            toReturn = [select id, pricebookentryid from opportunitylineitem where pricebookentryid in:newPricebookEntry and OpportunityId =: oppId];
            //mess = 'success';
        }catch(exception e){
            //mess = string.valueOf(e);
            system.debug(e); 
        }
        return toReturn; 
    }
    
    //ON LOAD SECTION
    //Get products and last paid when a opportunities are loaded!
        //get saved opportunity line items
    //!Important to get Product2 fields returned as [id, pricebookentryId, product2Id, Product2{Name, ProductCode}]
    //to access on JS side need to put Product2.Name => Returns product name
    @AuraEnabled
    public static list<OpportunityLineItem> getProducts(string oppId){
        list<OpportunityLineItem> opLi = [select id, pricebookEntryId, product2Id,product2.name,Product2.ProductCode,Product2.Floor_Type__c, TotalPrice,product2.Ship_Weight__c,
                                          product2.Agency_Pricing__c, Quantity, CPQ_Unit_Price__c,CPQ_Margin__c, Cost__c, OpportunityId,Description, Product2.Last_Purchase_Price__c,
                                          Product2.Pallet_Qty__c, Product2.SGN__c, Product2.RUP__c, Line_Order__c
                                          from OpportunityLineItem where opportunityId =: oppId];
        
        return opLi; 
    }
    //Get inventory on load
        @AuraEnabled(cacheable=true)
    public static list<ProductItem> onLoadGetInventory(string locId, list<id> pIds){
        list<ProductItem> cl; 
        //system.debug('pIds '+pIds + ' locId '+locId);
        list<ProductItem> countList = [select product2id, QuantityOnHand, Quantity_Available__c from productitem
                                      where LocationId =: locId and product2id in:(pIds)
                                      and Product_Class__c = 'Simple'];
        
        if(!countList.isEmpty()){
            cl = countList; 
        }
        //system.debug('cl ' +cl);
        return cl; 
    }
    @AuraEnabled(cacheable=true)
    public static list<Sales_Doc_Detail__c> onLoadGetLastPaid(id accountId,list<string> productCodes){
        list<Sales_Doc_Detail__c> lastPaidList = new list<Sales_Doc_Detail__c>(); 
	
        try {
            Sales_Doc_Detail__c[] temp;
			Map<String, Sales_Doc_Detail__c[]> sales = new map<String, Sales_Doc_Detail__c[]>();
                
			for(Sales_Doc_Detail__c record: [select id,name,Unit_Price__c,Margin__c, Doc_Date__c, Product_Code__c from sales_doc_detail__c
            	where Product_Code__c In: (productCodes) and Sales_Document__r.customer__c =: accountId
            	order by Sales_Document__r.doc_date__c desc]) {
    				if((temp = sales.get(record.Product_Code__c)) == null) {
        				sales.put(record.Product_Code__c, temp = new Sales_Doc_Detail__c[0]);
                   		lastPaidList.add(record); 
    				}
    			temp.add(record);
            }
            
            return lastPaidList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //get last quoted 
        @AuraEnabled(cacheable=true)
    public static list<OpportunityLineItem> onLoadGetLastQuoted(id accountId,list<string> productCodes, string opportunityId){
        list<OpportunityLineItem> lastPaidList = new list<OpportunityLineItem>(); 
		system.debug('pc');
        system.debug(productCodes);
        try {
            OpportunityLineItem[] temp;
			Map<String, OpportunityLineItem[]> sales = new map<String, OpportunityLineItem[]>();
                
			for(OpportunityLineItem record: [select Product2Id, Last_Quote_Price__c ,Last_Quote_Margin__c,Quote_Date__c, ProductCode from OpportunityLineItem
            	where ProductCode In: (productCodes) and Account__c =: accountId and OpportunityId !=:opportunityId
            	order by LastModifiedDate  desc]) {
    				if((temp = sales.get(record.ProductCode)) == null) {
        				sales.put(record.ProductCode, temp = new OpportunityLineItem[0]);
                   		lastPaidList.add(record); 
    				}
    			temp.add(record);
            }
            
            return lastPaidList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //get current level pricing
    //on mobile get the product weight on load
    @AuraEnabled(cacheable=true)
    public static list<PricebookEntry> getLevelPricing(id priceBookId,list<id> productIds){
        list<PricebookEntry> levels; 
        list<PricebookEntry> pricing = [select product2id, UnitPrice,Product2.Ship_Weight__c, 
                                        Level_1_UserView__c, Level_2_UserView__c, Floor_Price__c,Product_Cost__c 
                                        from pricebookentry where product2id in:(productIds) and Pricebook2Id =: priceBookId];
        if(pricing.size()>0){
            levels = pricing;
        }
        return levels; 
    }

    //will look for similar cat products if nothing above is returned. 
  //  @AuraEnabled
   // public static PricebookEntry[] similarProducts(){
   //     return null; 
    //}
}