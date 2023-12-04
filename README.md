# Search Labels and Tags Quick Overview

This project allows for custom search of our internal products. This allows for admins to create phrases or promos and group products together. 

## Quick Example Use 
Lets assume you have 3 different vehicles for sale.  A black motorcycle, a grey minivan and a red car. You want your users to search your inventory to find which vehicles you sell even if they don't know the exact vin #. Admins could create search lables that group vehicles together that seat 3 or more people or are red in color. You would create the following Search Labels: "Red Exterior Color" and "Seat 3 Plus".  Then you would create Tags as shown below

New Tag Search Label Look up: "Red Exterior Color" Product Lookup: 'red car'
New Tag Search Label Look up: "Seat 3 Plus" Product Lookup: 'red car'
New Tag Search Label Look up: "Seat 3 Plus" Product Lookup: 'minivan'

User Search => ‘Red’ return the red car
User Search => ‘Seats 3” return minivan and red car

## Search Labels
The [Search Label](https://advancedturf.lightning.force.com/lightning/setup/ObjectManager/01I6T000002uYCd/Details/view) should be treated as the catergoization. They need to be alphabetized and not repeated. Treat labels as essentially topics you want to be searchable. They are only limited by 125 character limit. Once the label is created you can associate it desired products using the tag object look ups. Mass importing or assigning tags can be done relatively quickly using python matching scripts. 


### Categorization and Promotion
You can futher categorize labels by selecting the Label Categorization when creating the label. This will allow you to group the label in the 'Target', 'Fertilizer', 'Seed' etc. 

The only category that really has consequences outside of admin reporting is the “Promotional” category. If you select this category and also give the label and Expiration Date the label will show up in the Promotional Search. 

### Creating better label tips. 
**I will eventually add a python script in the scripts section of this repository. 

Labels shouldn’t be replicated. Before creating a label go to the [Search list view](https://advancedturf.lightning.force.com/lightning/o/Search_Label__c/list?filterName=00B6T000007TReVUAW) and input the desired Label Name and see if anything comes back. 

1* Label strings should be in alphabetical order. You can do this with python script. For example, assume you have this label: “Jackie AJ 317 Abby Alex” you would want the final label to be “317 Abby AJ Alex Jackie”.

Label Names should not contain commas ‘,’

Promotions need to have expiration dates to appear in search strings. 

To show in search a product does not need to have a label. 

## Tags
The [Tags](https://advancedturf.lightning.force.com/lightning/setup/ObjectManager/01I6T000002uYCs/Details/view). This is the junction object that binds labels to products. It is what the code is actually searching over. The Search Slug 2 is where we are targeting the search. We have a [flow](https://advancedturf.lightning.force.com/builder_platform_interaction/flowBuilder.app?flowId=301VH000001Gk9ZYAS) that automatically will arrange the Search Slug 2 on various instances. You need to review the start criteria to see what qualifies. 

Tags do not require a label to work just the product2 filled in. 

New products are assigned a Tag and Search Slug2 when brought over from integration jobs. 

For ATS purpose we simply need a Search Slug2 with the product code and name when new product comes in. 

Most of the Tag object fields are formulas looking at the actual Product2 page. Those fields are maintained by integration jobs. This allows the tags sorting and info to be maintained in one place yet the product is in multiple tags. 

Currently, there is no filter on if the tag is active in search. This will be updated at future date. 

Finally, tags are shown sorted by Stock Status as of today. That will be updated in the future. 

## Reserved Keywords

Regex is used to remove certain inputed strings prior to being sent to the server. Most are for business purposes, however, certain escape characters need to be handled as well. 

### Fertilizer strings: 
Fertilizer analysis is removed and triggers a search strict mode
### 2, 4-D or variations. 
changed to 2 4-D
### Stock Status
Stock, limited, close-out and Southern Stock and variations are removed from the search string and pinned to the end of a where clause

### FRAC
in progress
### WH followed by 3 digits
in progress

## Further Notes
1* The order is important. The search engine runs on SOSL the order of the words is dependent on matching the first word. Knowing this the search string is actually alphabetized before it is sent to the server. If a user inputs 'My Apparal' it is transformed to 'Apparal My' then sent. If there are specific phrases like 'Home Run' or 'Grilled Cheese' that are common in the industry they still need to be alphabetized or put in the reserved keyword section. Tip - A.I. is good at generating Regex! 
