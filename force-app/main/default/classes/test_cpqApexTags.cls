@isTest
public class test_cpqApexTags {

        static{
 //odds and ends
		Date myDate = Date.newInstance(2040, 1, 4);
//account
		Account cust = new Account();
        cust.Name = 'Test123456';
        cust.Type = 'Customer';
        cust.RecordTypeId = '01241000001Dy64AAC'; 
        cust.Customer_Name__c = 'Test Customer 123456';
        insert cust;
//product
 		Product2 r1 = new Product2();
  		Product2 r2 = new Product2();         
         r1.Name='Product 1';
         r1.Primary_Category__c = 'Chemicals';
         r1.Subcategory__c ='Chemicals-Herbicide';
         r1.Include_in_Programs__c = True;
         r1.IsActive= True; 
         r1.ProductCode='123';
         r1.Product_Status__c ='Stock';
         r1.Size__c = 1;
         r1.Floor_Type__c ='Floor'; 
         r1.Floor_Price__c = 100;
         r1.IsActive = true; 
         
        
         r2.Name='Product 2';
         r2.Primary_Category__c = 'Chemicals';
         r2.Subcategory__c = 'Chemicals-Herbicide';
         r2.Include_in_Programs__c = True;
         r2.IsActive= True; 
         r2.ProductCode='123';
         r2.Product_Status__c ='Stock';
         r2.Size__c = 1;
         r2.Floor_Type__c ='Floor'; 
         r2.Floor_Price__c = 100;
     	insert r1; 
     	insert r2; 
//price book 
		Id pricebookId = Test.getStandardPricebookId();
//price book items
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=r1.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id=r2.id,
                                                 unitprice=100, IsActive = True, UseStandardPrice=False);

        insert pbe;
        insert pbe2;
//location
        Schema.Location warehouse = new Schema.Location();
        warehouse.Name= 'ATS Warehouse';
        warehouse.Location_Number__c ='2';
        warehouse.IsInventoryLocation = true; 
        warehouse.LocationType = 'ATS'; 
        
        insert warehouse; 
//opportunity
        opportunity opp = new opportunity(name = 'test name', accountID= cust.id, pricebook2id = pricebookId,
                                         stagename='Working', Warehouse__c = warehouse.Id, closedate = myDate);
       
        //insert w/o synced quote
        insert opp; 
//opportunity line item
        opportunitylineitem li2 = new opportunitylineitem(opportunityid = opp.id, product2id = r1.Id, PricebookEntryId=pbe.id,
                                                         unitprice= 4, quantity= 3, CPQ_Unit_Price__c=5, CPQ_Margin__c=32); 
        insert li2; 
        opportunitylineitem widgetli2 = new opportunitylineitem(opportunityid = opp.id, product2id = r2.Id, PricebookEntryId=pbe2.id,
                                                         unitprice= 4, quantity= 3, CPQ_Unit_Price__c=100, CPQ_Margin__c=35); 
        insert widgetli2;
//product items
		ProductItem inv1 = new ProductItem(Product2Id = r1.id, LocationId= warehouse.id, QuantityOnHand= 3);
        ProductItem inv2 = new ProductItem(Product2Id = r2.id, LocationId= warehouse.id, QuantityOnHand= 4);
        insert inv1; 
        insert inv2; 
//Because ATS Products is used in reporting need an ats product
		Product__c ats1 = new Product__c(Name= r1.ProductCode, Product_Name__c = r1.Name, active__c = True, Product_Code__c = r1.ProductCode); 
        Product__c ats2 = new Product__c(Name= r2.ProductCode, Product_Name__c = r2.Name, active__c = True, Product_Code__c = r2.ProductCode); 
        insert ats1;
        insert ats2; 
//sales doc and details
		Sales_Document__c header = new Sales_Document__c();
        	header.Sales_Doc_Num__c = 'SO132';
        	header.Customer__c = cust.Id; 
        	header.Doc_Type__c = 'Invoice';
        	header.Doc_Date__c = MyDate.addDays(-10);
        	header.Number_of_Payments__c = 1;
        insert header; 
        
        Sales_Doc_Detail__c detail1 = new Sales_Doc_Detail__c();
        Sales_Doc_Detail__c detail2 = new Sales_Doc_Detail__c();
        	detail1.Sales_Document__c = header.Id; 
        	detail1.Name = 'detail 1'; 
        	detail1.Quantity__c  = 1;
        	detail1.Product__c = ats1.Id; 
        
            detail2.Sales_Document__c = header.Id; 
        	detail2.Name = 'detail 1'; 
        	detail2.Quantity__c  = 1;
        	detail2.Product__c = ats2.Id;
        insert detail1;
        insert detail2;
            
//Label
		Search_Label__c sl2 = new Search_Label__c(); 
        sl2.Name = 'EOP';
        sl2.Label_Category__c = 'Promotional';
        sl2.Expiration_Date__c = myDate.addDays(20); 
        insert sl2; 
//Tags
		Tag__c t1 = new Tag__c();
        Tag__c t2 = new Tag__c(); 
            
        t1.Product__c = r1.Id;
        t1.Search_Label__c = sl2.Id;
        t1.Search_Slug_2__c = r1.ProductCode + ' '+ r1.Name + ' '+ sl2.Name;
        t1.Tag_Status__c = 'Active';
        
        t2.Product__c = r2.Id;
        t2.Search_Label__c = sl2.Id;
        t2.Search_Slug_2__c = r2.ProductCode + ' '+ r2.Name + ' '+ sl2.Name;
        t2.Tag_Status__c = 'Active';
        
       insert t1;
       insert t2; 
    }
        @isTest
        static void testGetDetails(){
 			Product2 prod = [select id, ProductCode from product2 where name = 'Product 1' ];
            string prodId = prod.Id;
            string prodCode = prod.ProductCode;
            string warehouse = [select id from location where Name = 'ATS Warehouse' and Location_Number__c = '2'].Id;
            string cust = [select id from account where Customer_Name__c = 'Test Customer 123456' ].Id; 
            string opp = [select id from opportunity where name = 'test name'].Id;
            Id pricebookId = Test.getStandardPricebookId();
   //Test
		test.startTest(); 
        	list<cpqApexTags.prodWrapper> detail = cpqApexTags.getDetails(prodId, warehouse, cust, prodCode, opp,  pricebookId);
        test.stopTest(); 
//Verify
	system.assertNotEquals(detail, null);   
        }
    
    @isTest
    static void testPromoDetails(){
        Id pricebookId = Test.getStandardPricebookId();
        string opp = [select id from opportunity where name = 'test name'].Id;
        Product2 prod = [select id, ProductCode from product2 where name = 'Product 1' ];
        string prodId = prod.Id;
        string prodCode = prod.ProductCode;
        string cust = [select id from account where Customer_Name__c = 'Test Customer 123456' ].Id;
        string warehouse = [select id from location where Name = 'ATS Warehouse' and Location_Number__c = '2'].Id;
        string searchLabel = [select id from Search_Label__c where Name = 'EOP'].Id; 
        test.StartTest();
        	cpqApexTags.promoWrapper wrap = cpqApexTags.promoDetails(searchLabel, warehouse, cust, prodCode, opp, pricebookId); 
        test.StopTest();
    }
    
    //Process of saving search queries for backend metrics in opportunity process.
    @isTest
    static void testSearchQueries(){
        //sit up tag info 
        string prodCode = [select id from product2 where name = 'Product 1'].Id; 
        Tag__c singleTag = [select id, ATS_Score__c, Product__c from Tag__c where Product__r.Id =: prodCode];
        string oppId = [select id from opportunity where name = 'test name'].Id;
        string oppProd = [select id from opportunitylineitem where product2Id = :prodCode].Id;
        
        //build query list
        List<Query__c> tagList = new List<Query__c>();
        Query__c oneTag = new Query__c();
        oneTag.ATS_Score__c = singleTag.ATS_Score__c;
        oneTag.Opportunity_Product__c = oppProd; 
        oneTag.Opportunity__c = oppId;
        oneTag.Query_Size__c = 23;
        oneTag.Search_Index__c = 2;
        oneTag.Tag__c = singleTag.Id; 
        oneTag.Term__c = 'stuff';
       	
        tagList.add(oneTag);
        test.startTest();
        	string back = searchQueries.createQueries(tagList); 
        test.stopTest(); 
        
    }

    
}