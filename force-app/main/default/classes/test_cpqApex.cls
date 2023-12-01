@isTest
public class test_cpqApex {
	
    @isTest
    static void Test_priceBookWrapper(){
        	string label = 'label';
        	string value = 'value';
        pricebookwrapper t = new pricebookwrapper(label, value); 
        	System.assertNotEquals(null, t);
    }
    @isTest
    static void Test_searchProduct(){
        //date for opp
        Date myDate = Date.newInstance(2040, 1, 4);
        //create test customer
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        //product creation
        Id pricebookId = Test.getStandardPricebookId();

        product2 prod = new product2(name ='product', IsActive= True, ProductCode='123', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Herbicide', Product_Family__c='FMC', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod; 
        
        product2 prod2= new product2(name ='widget', IsActive= True, ProductCode='321', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Fungicide', Product_Family__c='FoliarPak', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod2;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod2.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);

        insert pbe;
        insert pbe2;
        
        Test.startTest();
        	List<PricebookEntry> nameOnly = cpqApex.searchProduct('widget', 'All', 'All', pricebookId);
        	List<PricebookEntry> nullName = cpqApex.searchProduct('null', 'Chemicals-Herbicide', 'FMC', priceBookId);
        	List<PricebookEntry> nameandfamily = cpqApex.searchProduct('widget', 'All', 'FoliarPak', priceBookId);
        	List<PricebookEntry> nameandcat = cpqApex.searchProduct('product', 'Chemicals-Herbicide', 'All', priceBookId);
        	List<PricebookEntry> catOnly = cpqApex.searchProduct('null', 'Chemicals-Herbicide', 'All', priceBookId);
        	List<PricebookEntry> famOnly = cpqApex.searchProduct('null', 'All', 'FMC', priceBookId);
        	List<PricebookEntry> allThree = cpqApex.searchProduct('widget', 'Chemicals-Herbicide', 'All', priceBookId);
        	list<priceBookWrapper> pbw = cpqApex.getPriceBooks();
        Test.stopTest();
    }
     @isTest
    static void Test_mobileSearchProduct(){
        //date for opp
        Date myDate = Date.newInstance(2040, 1, 4);
        //create test customer
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        //product creation
        Id pricebookId = Test.getStandardPricebookId();

        product2 prod = new product2(name ='product', IsActive= True, ProductCode='123', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Herbicide', Product_Family__c='FMC', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod; 
        
        product2 prod2= new product2(name ='widget', IsActive= True, ProductCode='321', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Fungicide', Product_Family__c='FoliarPak', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod2;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod2.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);

        insert pbe;
        insert pbe2;
        
        Test.startTest();
        	List<PricebookEntry> nameOnly = cpqApex.mobileSearchProduct('widget', 'All', 'All', pricebookId);
        	List<PricebookEntry> nullName = cpqApex.mobileSearchProduct('%%', 'Chemicals-Herbicide', 'FMC', priceBookId);
        	List<PricebookEntry> nameandfamily = cpqApex.mobileSearchProduct('widget', 'All', 'FoliarPak', priceBookId);
        	List<PricebookEntry> nameandcat = cpqApex.mobileSearchProduct('product', 'Chemicals-Herbicide', 'All', priceBookId);
        	List<PricebookEntry> catOnly = cpqApex.mobileSearchProduct('%%', 'Chemicals-Herbicide', 'All', priceBookId);
        	List<PricebookEntry> famOnly = cpqApex.mobileSearchProduct('%%', 'All', 'FMC', priceBookId);
        	List<PricebookEntry> allThree = cpqApex.mobileSearchProduct('widget', 'Chemicals-Herbicide', 'All', priceBookId);
        	list<priceBookWrapper> pbw = cpqApex.getPriceBooks();
        Test.stopTest();
    }
    @isTest
    static void Test_getLastPaid(){
                //get record type
        ID recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account(); 
        acct.name = '509-Test Comp';
        acct.Customer_Name__c = 'New Company';
        acct.Customer__c = '1010';
        acct.RecordTypeId = recordType;
        insert acct;

        //create product
        Product__c prod = new Product__c(Product_Name__c='Something', Name='123'); 
        insert prod; 

        
        //Create Sales Doc
        Sales_Document__c sd = new Sales_Document__c();
        sd.name = 'test from sf';
        sd.sales_Doc_num__c = '454';
        //get new account recordid
        sd.Customer__c = acct.id;
        sd.Doc_Type__c = 'Invoice';
        
        insert sd; 
        
        Sales_Doc_Detail__c testSale = new Sales_Doc_Detail__c();
        testSale.name = 'Test';
        testSale.sales_document__c = sd.ID;
        testSale.Product__c = prod.ID;
        testSale.Product_Code__c = prod.Name;
        insert testSale;
        
        Test.startTest();
        	Sales_Doc_Detail__c detail = cpqApex.getLastPaid(acct.id, prod.name);
        Test.stopTest();
        system.debug('detail '+detail);
    }
    @isTest
    static void Test_getProducts(){
        //date for opp
        Date myDate = Date.newInstance(2040, 1, 4);
        //create test customer
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        //product creation
        Id pricebookId = Test.getStandardPricebookId();
        
        //create product2 that is active
        product2 prod = new product2(name ='product', IsActive= True); 
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod.id,
                                                 unitprice=4, IsActive = True, UseStandardPrice=False);
        insert pbe; 
        
        //create product2 that will be deactivated
        product2 widget = new product2(name ='widget', IsActive= True); 
        insert widget; 
        
        PricebookEntry widgetpbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=widget.id,
                                                 unitprice=4, IsActive = True, UseStandardPrice=False);
        insert widgetpbe; 
        //create test opportunity
        opportunity opp = new opportunity(name = 'test name', accountID= cust.id, pricebook2id = pricebookId,
                                         stagename='Estimate(10%)', job_type__c = 'Construction', closedate = myDate);
       
        //insert w/o synced quote
        insert opp; 
       
//opportunitylineitem
        opportunitylineitem li = new opportunitylineitem(opportunityid = opp.id, product2id = prod.Id, PricebookEntryId=pbe.id,
                                                         unitprice= 4, quantity= 3); 
        insert li; 
        opportunitylineitem widgetli = new opportunitylineitem(opportunityid = opp.id, product2id = widget.Id, PricebookEntryId=widgetpbe.id,
                                                         unitprice= 4, quantity= 3); 
        insert widgetli;
        
        Test.startTest();
        	list<OpportunityLineItem> oppLine = cpqApex.getProducts(opp.Id);
        Test.stopTest();
    }
       @isTest
    static void Test_getLastQuote(){
        //date for opp
        Date myDate = Date.newInstance(2040, 1, 4);
        //create test customer
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        //product creation
        Id pricebookId = Test.getStandardPricebookId();
        
        //create product2 that is active
        product2 prod = new product2(name ='product', IsActive= True, ProductCode='alex'); 
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod.id,
                                                 unitprice=4, IsActive = True, UseStandardPrice=False);
        insert pbe; 
        
        //create product2 that will be deactivated
        product2 widget = new product2(name ='widget', IsActive= True, ProductCode='abby'); 
        insert widget; 
        
        PricebookEntry widgetpbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=widget.id,
                                                 unitprice=4, IsActive = True, UseStandardPrice=False);
        insert widgetpbe; 
        //create test opportunity
        opportunity opp = new opportunity(name = 'test name', accountID= cust.id, pricebook2id = pricebookId,
                                         stagename='Estimate(10%)', job_type__c = 'Construction', closedate = myDate);
       
        //insert w/o synced quote
        insert opp; 
       
//opportunitylineitem
        opportunitylineitem li = new opportunitylineitem(opportunityid = opp.id, product2id = prod.Id, PricebookEntryId=pbe.id,
                                                         unitprice= 4, quantity= 3, CPQ_Unit_Price__c=4, CPQ_Margin__c=32); 
        insert li; 
        opportunitylineitem widgetli = new opportunitylineitem(opportunityid = opp.id, product2id = widget.Id, PricebookEntryId=widgetpbe.id,
                                                         unitprice= 4, quantity= 3, CPQ_Unit_Price__c=75, CPQ_Margin__c=35); 
        insert widgetli;
//Insert Second Opp
        opportunity opp2 = new opportunity(name = 'opp2', accountID= cust.id, pricebook2id = pricebookId,
                                         stagename='Estimate(10%)', job_type__c = 'Construction', closedate = myDate);
        insert opp2; 
        
//Insert Opp Prod 2
//opportunitylineitem
        opportunitylineitem li2 = new opportunitylineitem(opportunityid = opp2.id, product2id = prod.Id, PricebookEntryId=pbe.id,
                                                         unitprice= 4, quantity= 3, CPQ_Unit_Price__c=5, CPQ_Margin__c=32); 
        insert li2; 
        opportunitylineitem widgetli2 = new opportunitylineitem(opportunityid = opp2.id, product2id = widget.Id, PricebookEntryId=widgetpbe.id,
                                                         unitprice= 4, quantity= 3, CPQ_Unit_Price__c=100, CPQ_Margin__c=35); 
        insert widgetli2;
  ///list for product codes
       List<String> pc = new List<String>();
	Test.startTest();
        pc.Add(prod.ProductCode);
        pc.Add(widget.ProductCode);
        OpportunityLineItem oneLine = cpqApex.getLastQuote(cust.ID, prod.ProductCode, opp2.id);
        list<OpportunityLineItem> multiple = cpqApex.onLoadGetLastQuoted(cust.Id, pc, opp2.id);
    Test.stopTest();
        system.debug('pc => '+widgetli2.ProductCode);
    }
    @isTest
    static void Test_createProducts(){
                //date for opp
        Date myDate = Date.newInstance(2040, 1, 4);
        //create test customer
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        //product creation
        Id pricebookId = Test.getStandardPricebookId();
        string oppId; 
        //create product2 that is active
        product2 prod = new product2(name ='product', IsActive= True); 
        insert prod; 
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=prod.id,
                                                 unitprice=4, IsActive = True, UseStandardPrice=False);
        insert pbe; 
        
        //create product2 that will be deactivated
        product2 widget = new product2(name ='widget', IsActive= True); 
        insert widget; 
        
        PricebookEntry widgetpbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=widget.id,
                                                 unitprice=4, IsActive = True, UseStandardPrice=False);
        insert widgetpbe; 
        //create test opportunity
        opportunity opp = new opportunity(name = 'test name', accountID= cust.id, pricebook2id = pricebookId,
                                         stagename='Estimate(10%)', job_type__c = 'Construction', closedate = myDate);
       
        //insert w/o synced quote
        insert opp; 
        oppId = oppId;   
        opportunitylineitem li = new opportunitylineitem(opportunityid = opp.id, product2id = prod.Id, PricebookEntryId=pbe.id,
                                                         unitprice= 4, quantity= 3, CPQ_Margin__c = 1); 
        insert li; 
               
        list<OpportunityLineItem> toInsert = new list<OpportunityLineItem>();
        
        OpportunityLineItem existing = new OpportunityLineItem(id = li.id, CPQ_Margin__c = 2, Cost__c =1.05, quantity = 3, unitprice = 4);
        opportunitylineitem newLi = new opportunitylineitem(opportunityid = opp.id, product2id = widget.Id, PricebookEntryId=widgetpbe.id,
                                                         	unitprice= 4, quantity= 3, CPQ_Margin__c = 3, Cost__c = 1.23); 
        toInsert.add(existing);
        toInsert.add(newLi);
        
        Test.startTest();
        	list<OpportunityLineItem> messBack = cpqApex.createProducts(toInsert, oppId, cust.id);
        Test.stopTest(); 
    }  
     @isTest
    static void Test_inventory(){
        product2 widget = new product2(name ='widget', productcode='123', IsActive= True); 
        insert widget; 
        product2 widget2 = new product2(name ='widget2', productcode='456', IsActive= True); 
        insert widget2; 
        //Location only wont work on this object need to do as below. 
        //https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_system_Location.htm
        Schema.Location warehouse = new Schema.Location(Name='Warehouse', LocationType='Warehouse', IsInventoryLocation=True);
        insert warehouse;
        
        ProductItem inven1 = new ProductItem(Product2Id= widget.id,LocationId =warehouse.id, QuantityOnHand=1);
        insert inven1;
        
        ProductItem inven2 = new ProductItem(Product2Id= widget2.id,LocationId =warehouse.id, QuantityOnHand=2);
        insert inven2;
        string pc1 = '123';
        string pc2 = '456';
        list<string> pcList = new list<string>();
        pcList.add(pc1);
        pcList.add(pc2); 
        
        Test.startTest();
        	list<id> idList = new list<id>();
        	idList.add(widget.Id);
        	idList.add(widget2.Id);
        	list<productitem> count = cpqApex.inventoryCount(idList); 
        	productitem count2 = cpqApex.getInventory(warehouse.id, widget.id);
        	list<productitem> onLoadCount = cpqApex.onLoadGetInventory(warehouse.id, idList); 
        	list<productitem> changeInventory = cpqApex.inCounts(pcList, warehouse.id); 
        	list<productitem> changeInventoryAll = cpqApex.inCounts(pcList, 'All'); 
        Test.stopTest();
    }
    
    @isTest
    static void test_onLoadLastPaid(){
        //list of products
        list<string> prodList = new list<string>();
        
         //get record type
        ID recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account(); 
        acct.name = '509-Test Comp';
        acct.Customer_Name__c = 'New Company';
        acct.Customer__c = '1010';
        acct.RecordTypeId = recordType;
        insert acct;

        //create product
        Product__c prod = new Product__c(Product_Name__c='Something', Name='123'); 
        insert prod; 
        
        Product__c prod2 = new Product__c(Product_Name__c='two', Name='321'); 
        insert prod2; 
        
        //add products to the list
        prodlist.add(prod.Name);
        prodlist.add(prod2.Name);
        
        //dates
        Date d1 = Date.newInstance(2016, 12, 9);
        Date d2 = Date.newInstance(2017, 12, 9);
        //Create Sales Doc product 1 doc 1
        Sales_Document__c sd = new Sales_Document__c();
        sd.name = 'test from sf';
        sd.sales_Doc_num__c = '454';
        //get new account recordid
        sd.Customer__c = acct.id;
        sd.Doc_Type__c = 'Invoice';
        sd.Doc_Date__c = d1; 
        insert sd; 
        
        Sales_Doc_Detail__c testSale = new Sales_Doc_Detail__c();
        testSale.name = 'Test';
        testSale.sales_document__c = sd.ID;
        testSale.Product__c = prod.ID;
        testSale.Product_Code__c = prod.Name;
        insert testSale;
        
        //Create Sales Doc product 1 doc 2
        Sales_Document__c sd2 = new Sales_Document__c();
        sd2.name = 'test doc 2';
        sd2.sales_Doc_num__c = '455';
        //get new account recordid
        sd2.Customer__c = acct.id;
        sd2.Doc_Type__c = 'Invoice';
        sd2.Doc_Date__c = d2; 
        insert sd2; 
        
        Sales_Doc_Detail__c testSale2 = new Sales_Doc_Detail__c();
        testSale2.name = 'Test detail 2';
        testSale2.sales_document__c = sd2.ID;
        testSale2.Product__c = prod.ID;
        testSale2.Product_Code__c = prod.Name;
        insert testSale2;
        
        //Create Sales Doc product 2 doc 1
        Sales_Document__c sd3 = new Sales_Document__c();
        sd3.name = 'test doc 3';
        sd3.sales_Doc_num__c = '456';
        //get new account recordid
        sd3.Customer__c = acct.id;
        sd3.Doc_Type__c = 'Invoice';
        sd3.Doc_Date__c = d1; 
        insert sd3; 
        
        Sales_Doc_Detail__c testSale3 = new Sales_Doc_Detail__c();
        testSale3.name = 'Test detail 3';
        testSale3.sales_document__c = sd3.ID;
        testSale3.Product__c = prod2.ID;
        testSale3.Product_Code__c = prod.Name;
        insert testSale3;
        
        //Create Sales Doc product 2 doc 2
        Sales_Document__c sd4 = new Sales_Document__c();
        sd4.name = 'test doc 4';
        sd4.sales_Doc_num__c = '457';
        //get new account recordid
        sd4.Customer__c = acct.id;
        sd4.Doc_Type__c = 'Invoice';
        sd4.Doc_Date__c = d2; 
        insert sd4; 
        
        Sales_Doc_Detail__c testSale4 = new Sales_Doc_Detail__c();
        testSale4.name = 'Test detail 4';
        testSale4.sales_document__c = sd4.ID;
        testSale4.Product__c = prod2.ID;
        testSale4.Product_Code__c = prod.Name;
        insert testSale4;
        
       
        Test.startTest();
        	list<Sales_Doc_Detail__c> results = cpqApex.onLoadGetLastPaid(acct.id, prodlist);
        Test.stopTest();
    
    }
        @isTest
    static void Test_pricingLevels(){
        Id pbId = Test.getStandardPricebookId();

        product2 prod = new product2(name ='product', IsActive= True, ProductCode='123', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Herbicide', Product_Family__c='FMC', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod; 
        
        product2 prod2= new product2(name ='widget', IsActive= True, ProductCode='321', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Fungicide', Product_Family__c='FoliarPak', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod2;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pbId, Product2Id=prod.id,
                                                 unitprice=100, Level_1_Price__c=110, IsActive = True, UseStandardPrice=False);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pbId, Product2Id=prod2.id,
                                                 unitprice=100, Level_1_Price__c=110, IsActive = True, UseStandardPrice=False);

        insert pbe;
        insert pbe2;
        
        list<id> productIds = new list<id>();
        productIds.add(prod.Id);
        productIds.add(prod2.Id);
        Test.startTest();
        	list<PricebookEntry> levels = cpqApex.getLevelPricing(pbId, productIds);
        Test.stopTest();
    }
    @isTest
    static void Test_getAddress(){
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        
        ContactPointAddress cpa = new ContactPointAddress();
        cpa.Name = 'Test Address';
        cpa.ParentId = cust.Id;
        	insert cpa;
        ContactPointAddress cpa2 = new ContactPointAddress();
        cpa2.Name = 'Test Address2';
        cpa2.ParentId = cust.Id;
        	insert cpa2;
        
        Test.startTest();
        	list<ContactPointAddress> addresses = cpqApex.getAddress(cust.Id); 
        Test.stopTest();
        system.assertEquals(2, addresses.size());
    }
   @isTest
    static void Test_quickPriceSearch(){
        //date for opp
        Date myDate = Date.newInstance(2040, 1, 4);
        //create test customer
        Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
        //product creation
        Id pricebook = Test.getStandardPricebookId();

        product2 prod = new product2(name ='product', IsActive= True, ProductCode='123', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Herbicide', Product_Family__c='FMC', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod; 
        
        product2 prod2= new product2(name ='widget', IsActive= True, ProductCode='321', Product_Status__c ='Stock', 
                                    Subcategory__c='Chemicals-Fungicide', Product_Family__c='FoliarPak', Floor_Type__c ='Floor', Floor_Price__c = 100); 
        insert prod2;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebook, Product2Id=prod.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pricebook, Product2Id=prod2.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);

        insert pbe;
        insert pbe2;
        
        Test.startTest();
        	List<PricebookEntry> nameOnly = quickPriceSearch.getPricing(priceBook, 'Widget');
        	List<PricebookEntry> code = quickPriceSearch.getPricing(priceBook, '321');
        	
        Test.stopTest();
    } 
}