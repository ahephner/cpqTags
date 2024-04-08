//used to merge inventory and selected products on load
const mergeInv = (a1, a2) =>{
    
  let merge
  if(a2){
      merge = a1.map(itm => ({
        ...a2.find((item) => (item.Product2Id === itm.Product2Id)),
        ...itm
    })
    )
    return merge;
  }else{
    return a1; 
  }
 }
//merge the products on their last paid amount
 const mergeLastPaid = (a1, a3) =>{
  let merge  
    if(a3){
      merge = a1.map(res =>({
        ...a3.find((lp)=>(lp.Product_Code__c === res.Product2.ProductCode)),
          ...res
            })
              )
              return merge; 
          }else{
            return a1;
          }   
 }
//sum an array of objects based on key and values; 
 const sumByKey = (arr, key, value) => {
  const map = new Map();
  //iterate the array and set key with value
  for(const obj of arr) {
    const currSum = map.get(obj[key]) || 0;
    map.set(obj[key], currSum + obj[value]);
  }
  //create array with values
  const res = Array.from(map, ([k, v]) => ({[key]: k, [value]: v}));
  return res;
}

const reNameKey = (obj, oldValue, newValue)=> {
  let ov = oldValue;
  let nv = newValue;
  for(let key of obj){
    key[nv] = key[ov];
    delete key[ov]; 
  }
  let back = [...obj]
  return back; 
}
 //merge last quote amount
 const mergeLastQuote = (a1, a3) =>{
  // console.log(JSON.stringify(a1))
  // console.log(JSON.stringify(a3))
  let merge  
    if(a3){
      merge = a1.map(res =>({
        ...a3.find((lp)=>(lp.Product2Id === res.Product2Id)),
          ...res
            })
              )
              //console.log(JSON.st(merge))
              return merge; 
          }else{
            return a1;
          }   
 }
 
//used to calculate the line total on when the price or units are changed
const lineTotal = (units, charge)=> (units * charge).toFixed(2);

//loading for the desktop version. accepts product list and assigns values
//if you want to add another field to the screen start it here
const onLoadProducts = (products, recordId) =>{
  let count = 0;
  let prod = products.map(x =>{
    count++   
      //console.log(JSON.stringify(products));
      return   {
          sObjectType: 'OpportunityLineItem',
          Id: x.Id,
          PricebookEntryId: x.PricebookEntryId,
          Product2Id: x.Product2Id,
          name: x.Product2.Name,
          ProductCode: x.Product2.ProductCode,
          Quantity: x.Quantity,
          lOne: x.Level_1_UserView__c,
          floorPrice: x.Floor_Price__c,
          UnitPrice:x.Product2.Agency_Pricing__c ? x.Floor_Price__c: x.CPQ_Unit_Price__c,
          //MinPrice: x.UnitPrice, 
          CPQ_Margin__c: x.Product2.Agency_Pricing__c? '' : x.CPQ_Margin__c,
          Cost__c: x.Product_Cost__c,
          displayCost: x.Product2.Agency_Pricing__c ? 'Agency' : x.Product_Cost__c, 
          agency: x.Product2.Agency_Pricing__c ,
          wInv: x.Quantity_Available__c ? x.Quantity_Available__c : 0,
          lastPaid: x.Unit_Price__c ? '$'+x.Unit_Price__c : 0,
          lastMarg: x.Product2.Agency_Pricing__c ? '' : (x.Margin__c/100),
          companyLastPaid: x.Product2.Last_Purchase_Price__c,
          palletConfig: x.Product2.Pallet_Qty__c,
          docDate: x.Doc_Date__c, 
          TotalPrice: x.TotalPrice,
          Description: x.Description,
          Ship_Weight__c: x.Product2.Ship_Weight__c,
          lastPaidDate: x.Unit_Price__c ? '$'+x.Unit_Price__c +' '+x.Doc_Date__c : '', 
          showLastPaid: true,
          lastQuoteAmount: x.Last_Quote_Price__c,
          lastQuoteMargin: x.Last_Quote_Margin__c,
          lastQuoteDate: x.Quote_Date__c,
          flrText: 'flr price $'+ x.Floor_Price__c,
          lOneText: 'lev 1 $'+x.Level_1_UserView__c,
          sgn: x.Product2.SGN__c,
          goodPrice:x.Product2.Agency_Pricing__c ?true: (x.Floor_Price__c <= x.CPQ_Unit_Price__c ? true: false),
          resUse: x.Product2.RUP__c,
          manLine: x.Product2.ProductCode.includes('MANUAL CHARGE')  ? true : false,
          Line_Order__c: isNaN(Number(x.Line_Order__c))? count : Number(x.Line_Order__c) ,
          url: `https://advancedturf.lightning.force.com/lightning/r/${x.Product2Id}/related/ProductItems/view`, 
          //prodURL: `https://advancedturf--full.sandbox.lightning.force.com/lightning/r/Product2/${x.Product2Id}/view`,
          prodURL: `https://advancedturf.lightning.force.com/lightning/r/Product2/${x.Product2Id}/view`,
          OpportunityId: recordId
      } 
    })
//sort the array based on user input
//see below
  let sortedProd = sortArray(prod)
  //  console.log(JSON.stringify(prod));
  //console.log(typeof sortedProd[0].Line_Order__c, ' 2 ', sortedProd[0].Line_Order__c); 
  //  console.log('sorted below')
  //  console.log(JSON.stringify(sortedProd));
  return sortedProd; 
}
//sort the products on load to order by when they were added or rep has updated where they have been added
//used for quoting tool when they want to group products together; 
const sortArray = (el) =>{
  
  el.sort((a,b)=>{
    return a.Line_Order__c - b.Line_Order__c; 
  })
  return el; 
}

//this runs on init load. It's to make sure that the products actually loaded with cost. On cloning an opp
//often times it does not fully load the product info. This will check if cost has been loaded and if not 
//will tell the component to run the load job again.   
const loadCheck = (items)=>{
  let missingCost = false; 

  for(const x of items){
    //console.log(x.name +' '+x.Cost__c);
    
    if(x.Cost__c === undefined){
      missingCost = true;
      break; 
    }
  }
  return missingCost; 
}
//This is called when an item is removed from an order. It will update the remaining items 
//order so that when a quote is created it will still put the products in order
const removeLineItem = ((index, arr)=>{
  let prod = [...arr]
  for(let i = index; i< prod.length; i++){
    
    prod[i].Line_Order__c --;
  }
  return prod; 
})


//this sets the number of manual lines on the order so we don't add more than 10
const getManLines = (list) =>{ 
   let numbofLines = 0; 
   for(let i=0; i<list.length;i++){ 
     if(list[i].manLine){
       numbofLines ++; 
     }
   }
   return numbofLines; 
}
const updateNewProducts = (noIdProduct, returnedProducts)=>{
  const newProducts=[];
 // console.log(JSON.stringify(noIdProduct))
  //console.log(JSON.stringify(returnedProducts))
  if(noIdProduct){
    for(let i=0; i<noIdProduct.length;i++){
      let find = returnedProducts.find(item=>item.PricebookEntryId === noIdProduct[i].PricebookEntryId);
      //console.log(find);
      
      noIdProduct[i].Id = find.Id;
      newProducts.push(noIdProduct[i]);
    }
    return newProducts;
  
}else{
  return noIdProduct; 
}
}

//on load get product totals for ship weight, total price and quantity. 
const getTotals = (products)=>{
  const totals = products.reduce((basket, items) => {
                          //console.log(basket) //is the const first loop blank
                          //console.log(items) //is the object of data you want to reduce
        for (const [keyName, valueCount] of Object.entries(items)) {
          //only get the fields we want to add ship weight add this below ||keyName ==='Ship_Weight__c'
        if(keyName  ==='TotalPrice' || keyName==='Quantity'){
          //if the basket does not contain the key add the key and set the value to 0
          if (!basket[keyName]) {
              basket[keyName] = 0;
          }

          basket[keyName] += Number(valueCount);
      }
      }
      return basket;
  }, {});
  return totals; 
}
const getCost = (list)=>{ 
  let totalCost = 0;
  for(let i=0; i<list.length;i++){
     let x = Number(list[i].Cost__c * list[i].Quantity);
     //console.log('x '+x);
     
     totalCost += x; 
  }
  return totalCost; 
}
//allows the user to check inventory at other locations
const newInventory = (selectedProd, counts) =>{
  //merge selected products on inventory where common product codes
  let merge = selectedProd.map(prod => ({
    ...counts.find((inv) => (inv.Product_Code__c === prod.ProductCode)),
                        ...prod
                    })
                    )
    //loop over the joined arrays. Set inventory if there is some otherwise return 0;
    //have to delete the key value otherwise it is cached.  
    for(let i=0; i<merge.length; i++){
          merge[i].wInv = merge[i].Quantity_Available__c ? merge[i].Quantity_Available__c:0
          delete merge[i].Quantity_Available__c; 
    }
  return merge;
}
const allInventory = (selectedProd, counts) =>{
  //sum qty avaliable
  let sumQty = sumByKey(counts,"Product_Code__c", "Quantity_Available__c" ); 
  let newKey = reNameKey(sumQty, 'Quantity_Available__c', 'wInv')
  
  let merge = selectedProd.map(prod => ({
    ...newKey.find((inv) => (inv.Product_Code__c === prod.ProductCode)),
                        ...prod
                    })
                    )

  return merge;
}
//Update totals 
const totalChange = (q)=>{
  let priceChanged = q.reduce((acc, items)=>{
    return acc + Number(items.TotalPrice);
  },0)
  return priceChanged; 
}

//Math Functions
    //returns a round number for later math functions
const roundNum = (value, dec)=>{
      //console.log('v '+value+' dec '+dec);
      let x = Number(Math.round(parseFloat(value+'e'+dec))+'e-'+dec); 
      return x;
  }
//check if all the products on the order price is above floor
  const checkPricing = (prods) =>{
    
    let check = true; 
    for(let i=0; i<prods.length; i++){
      //console.log(prods[i].name, prods[i].goodPrice, 'index ', i)
        if(!prods[i].goodPrice){
          check = false;
          return check;
        }
    }
    return check;
  }

  const getShipping = (prod)=>{
    let total = prod.reduce((w, item)=>{
      return w + (item.UnitPrice * item.Quantity);
    }, 0)
   
    return total; 
  }

  const setMargin = (cost, revenue)=>{
    //console.log(1, cost,2,revenue)
    let margin = ((revenue - cost)/revenue) * 100;
    return margin; 
  }
  // Validation function
  //bill and hold need to add this => to function , bhRules, isBH
  const validate = (obj, rules, rupRules, isRUP) => {
    //if RUP product is selected add rup rules to validate against
    if(isRUP){
      rules = [...rules, ...rupRules]
    }
    //check if bill and hold was selected
    //if(isBH === 'Yes'){
      //rules = [...rules, ...bhRules]
    //}
    const errors = rules.reduce((errs, rule) => {
      
      const result = rule.test(obj);
      if (result === false) {
        errs.push({message:rule.message, type: rule.type});
      }
      return errs;
    }, []);

    return {
      errors,
      isValid: errors.length === 0,
    };
  };

const roundRate = (numb, places) =>{
return +(Math.round(numb + `e+${places}`) + `e-${places}`)
}

const checkRUP = (items)=>{
let isRup = false; 

for(const x of items){
  if(x.resUse){
    isRup = true;
    break; 
  }
}
return isRup; 
}

//set the opportunity product id to the metrics object for reporting purposes. 
const setOPMetric = (metrics, salesLines)=>{
  for(let i=0; i<metrics.length; i++){
    console.log(metrics[i])
    let lineitem = salesLines.find(x => x.Product2Id === metrics[i].Product);
        metrics[i].Opportunity_Product__c = lineitem.Id; 
        
  }
  return metrics
}

// make it so functions can be used other pages
export{ validate, 
      mergeInv, 
      lineTotal, 
      onLoadProducts, 
      mergeLastPaid, 
      newInventory,
      updateNewProducts, 
      getTotals, 
      getCost, 
      totalChange, 
      roundNum, 
      allInventory, 
      checkPricing, 
      getShipping, 
      getManLines, 
      setMargin, 
      mergeLastQuote, 
      roundRate, 
      checkRUP,
      sortArray,
      removeLineItem,
      loadCheck,
      sumByKey,
      reNameKey,
      setOPMetric
    }
