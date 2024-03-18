// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

IF((Today()- Product__r.Inventory_Weight_Date__c) <=60, 1, 
IF((Today()- Product__r.Inventory_Weight_Date__c)>=61 && (Today()- Product__r.Inventory_Weight_Date__c) <=120,2,
IF((Today()- Product__r.Inventory_Weight_Date__c)>=121 && (Today()- Product__r.Inventory_Weight_Date__c) <=180,3,
IF((Today()- Product__r.Inventory_Weight_Date__c)>=181 && (Today()- Product__r.Inventory_Weight_Date__c) <=240,4, 
IF((Today()- Product__r.Inventory_Weight_Date__c)>=241,5,1)))))

//W Inventory Score
//compiled char 2375
IF(ISNULL(  WD__c  ), 0,
IF((Today()- WD__c) <=60, 1.22, 
IF((Today()- WD__c)>=61 && (Today()- WD__c) <=120,2.4,
IF((Today()- WD__c)>=121 && (Today()- WD__c) <=180,3.6,
IF((Today()- WD__c)>=181 && (Today()- WD__c) <=240,4.8, 
IF((Today()- WD__c)>=241,6,1))))))

//brad's old ATS Score formula 8177 characters
IF(ISNULL(  W_Product_Profitability__c ), 0, W_Product_Profitability__c ) +
IF(ISNULL(  W_Inventory_Score__c ), 0, W_Inventory_Score__c ) +
IF(ISNULL(  W_Program_Score__c ), 0, W_Program_Score__c ) +
IF(ISNULL(  W_Focus_Product__c ), 0, W_Focus_Product__c )+
IF(ISPICKVAL( Product__r.Score_Boost__c , "Full Increase")&&  Product__r.Boost_End_Date__c >= Today() &&  ISPICKVAL(Tag_Status__c, "Active") ,1,0)+
IF(ISPICKVAL( Product__r.Score_Boost__c, "1/2 Increase") &&  Product__r.Boost_End_Date__c >= Today() &&  ISPICKVAL(Tag_Status__c, "Active"),0.5,0)-
IF(ISPICKVAL( Product__r.Score_Boost__c, "1/2 Decrease") &&   Product__r.Boost_End_Date__c >= Today() &&  ISPICKVAL(Tag_Status__c, "Active"),0.5,0)-
IF(ISPICKVAL( Product__r.Score_Boost__c, "Full Decrease") &&   Product__r.Boost_End_Date__c >= Today() &&  ISPICKVAL(Tag_Status__c, "Active"),1,0)+
IF(ISPICKVAL( Product__r.Score_Boost__c , "Full Increase") &&  ISNULL(Product__r.Boost_Start_Date__c) &&  ISPICKVAL(Tag_Status__c, "Active") ,1,0)+
IF(ISPICKVAL( Product__r.Score_Boost__c, "1/2 Increase") && ISNULL(Product__r.Boost_Start_Date__c) &&  ISPICKVAL(Tag_Status__c, "Active"),0.5,0)-
IF(ISPICKVAL( Product__r.Score_Boost__c, "1/2 Decrease") && ISNULL(Product__r.Boost_Start_Date__c)&&  ISPICKVAL(Tag_Status__c, "Active"),0.5,0)-
IF(ISPICKVAL( Product__r.Score_Boost__c, "Full Decrease") && ISNULL(Product__r.Boost_Start_Date__c)&&  ISPICKVAL(Tag_Status__c, "Active"),1,0)

//new 7199 about 1k more room 
IF(ISNULL(  W_Product_Profitability__c ), 0, W_Product_Profitability__c ) +
IF(ISNULL(  W_Inventory_Score__c ), 0, W_Inventory_Score__c ) +
IF(ISNULL(  W_Program_Score__c ), 0, W_Program_Score__c ) +
IF(ISNULL(  W_Focus_Product__c ), 0, W_Focus_Product__c )+
IF(AND(
    !ISPICKVAL(Product__r.Score_Boost__c,'' ),
    Product__r.Boost_End_Date__c >= Today(),
    ISPICKVAL(Tag_Status__c, "Active")
), CASE(TEXT(Product__r.Score_Boost__c),
        "Full Increase", 1,
        "1/2 Increase", 0.5,
        "Full Decrease", -1,
        "1/2 Decrease", -0.5,
    ),0
)