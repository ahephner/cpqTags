@isTest
public class test_cpqTagsSearch {
  static Product2 r1 = new Product2();
  static Product2 r2 = new Product2(); 
  static Search_Label__c sl1 = new Search_Label__c();
  static Search_Label__c sl2 = new Search_Label__c();
  static Tag__c t1 = new Tag__c();
  static Tag__c t2 = new Tag__c();  
  static date expDate = date.today() +7;   
    static{
        //product 
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
        
        sl1.Name = 'Ants';
        sl1.Label_Category__c = 'Target';
        
        sl2.Name = 'EOP';
        sl2.Label_Category__c = 'Promotional';
        sl2.Expiration_Date__c = expDate; 
       insert sl1;
       insert sl2; 
        
        t1.Product__c = r1.Id;
        t1.Search_Label__c = sl1.Id;
        t1.Search_Slug_2__c = r1.ProductCode + ' '+ r1.Name + ' '+ sl1.Name;
        t1.Tag_Status__c = 'Active';
        
        t2.Product__c = r2.Id;
        t2.Search_Label__c = sl2.Id;
        t2.Search_Slug_2__c = r2.ProductCode + ' '+ r2.Name + ' '+ sl2.Name;
        t2.Tag_Status__c = 'Active';
        
       insert t1;
       insert t2; 
    }
    
    @isTest
    static void testSearchTag(){
        string searchKey = 'Product';
        
        test.startTest();
        	list<tag__c> container = cpqTagsSearch.searchTag(searchKey);
        test.stopTest();
    }
    
    @isTest
    static void testSearchTagSOSL(){
        string searchKey = 'FIND {Product} IN ALL FIELDS RETURNING Tag__c(id, Tag_Description__c, Search_Slug_2__c, '
    +'Product__c, Product_Name__c, Product__r.Temp_Unavailable__c,Product__r.Temp_Mess__c, ATS_Score__c, Stock_Status__c, '
    +'W_Focus_Product__c, W_Product_Profitability__c, W_Program_Score__c, W_Inventory_Score__c, Product__r.Agency_Pricing__c, '
    +'Product__r.Ship_Weight__c, Product__r.Pallet_Qty__c, Product__r.SGN__c, Product__r.RUP__c, '
    +'Floor_Price__c, Product__r.Total_Product_Items__c,Product__r.Floor_Type__c, Product_Code__c where product__r.IsActive = true)';
       system.debug(searchKey); 
       test.startTest();
        list<tag__c> container = cpqTagsSearch.searchTagSOSL(searchKey);
       test.stopTest();
        system.debug(container);
    }
    
    @isTest
    static void testcpqSearchTag(){
        
    string searchKey = 'FIND {Product}  IN ALL FIELDS RETURNING Tag__c(id, Tag_Description__c, Search_Slug_2__c, '
    +'Product__c, Product_Name__c, Product__r.Temp_Unavailable__c,Product__r.Temp_Mess__c, ATS_Score__c, Stock_Status__c, '
    +'W_Focus_Product__c, W_Product_Profitability__c, W_Program_Score__c, W_Inventory_Score__c, Product__r.Agency_Pricing__c, '
    +'Product__r.Ship_Weight__c, Product__r.Pallet_Qty__c, Product__r.SGN__c, Product__r.RUP__c, '
    +'Floor_Price__c, Product__r.Total_Product_Items__c,Product__r.Floor_Type__c, Product_Code__c where product__r.IsActive = true)';
        
        test.startTest();
        	list<tag__c> container = cpqTagsSearch.cpqSearchTag(searchKey);
        test.stopTest();
    }
    
        @isTest
    static void testsearchPromos(){
        string searchKey = 'EOP';
        
        test.startTest();
        	list<Search_Label__c> container = cpqTagsSearch.searchPromos(searchKey);
        test.stopTest();
    }
    
            @isTest
    static void testonLoadPromos(){
        string searchKey = 'placeholder';
        
        test.startTest();
        	list<Search_Label__c> container = cpqTagsSearch.onLoadPromos();
        test.stopTest();
    }
    
     @isTest
    static void testonLoadTagPromo(){
               
        test.startTest();
        	list<tag__c> container = cpqTagsSearch.onLoadTagPromos();
        test.stopTest(); 
    }
    
   //static void testselectedProducts(){
     //   string searchKey = 'placeholder';
       // string pbid = 'kj';
        //test.startTest();
        	//pricebookentry container = cpqTagsSearch.selectedProducts(searchKey, pbid);
        //test.stopTest();
    //}
}