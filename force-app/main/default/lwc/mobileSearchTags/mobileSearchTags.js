import { LightningElement, api, track } from 'lwc';
import LightningAlert from 'lightning/alert';
import searchTag from '@salesforce/apex/cpqTagsSearch.cpqSearchTag';
import searchPromos from '@salesforce/apex/cpqTagsSearch.searchPromos';

const REGEX_SOSL_RESERVED = /(\?|&|\||!|\{|\}|\[|\]|\(|\)|\^|~|\*|:|"|\+|\\)/g;
const REGEX_STOCK_RES = /(stock|sock|limited|limted|lmited|limit|close-out|close out|closeout|close  out|exempt|exmpet|exemept|southern stock|southernstock|southner stock)/g; 
const REGEX_COMMA = /(,)/g;
const REGEX_24D = /2,4-D|2 4-d|2, 4-D/gi;
const REGEX_WAREHOUSE = /wh\s*\d\d\d/gi
const REGEX_WHITESPACE = /\s/g; 

import {spellCheck, cpqSearchString, uniqVals} from 'c/tagHelper';

export default class MobileSearchTags extends LightningElement{
    searchTerm;
    cat = 'All';  
    pf = 'All';
    @api priceBookId; 
    @track prod =[]; 
    @track items =[]; 
    loaded = false;
    showFam = false; 
    showFilters = false; 
    openFilters = false;
    stock; 
    searchQuery;
    searchSize; 

    connectedCallback(){
        this.loaded = true; 
    }

    addFilters(){
        if(this.items){
            this.items = []
        }
       // this.template.querySelector('c-mobile-search-filters').openFilter();
       this.openFilters = true; 
    }
    closeFilter(){
        this.openFilters = false;
    }

    updateFilters(event){
        this.cat = event.detail.cat;
        let catLab = event.detail.catLab
        this.pf = event.detail.pf;  
        this.handlePills(catLab, this.pf);
    }
    handlePills(cat, pf){
        const catPill = cat !='All' ? {label:cat, name:'catPill'} : 'All';
        const pfPill = pf!= 'All' ? {label:pf, name:'familyPill'} : 'All';
       // console.log('handle pill');
        
    //console.log('pfPill '+JSON.stringify(pfPill)+' catPill '+JSON.stringify(catPill));
        
        if(catPill != 'All' && pfPill !='All'){
            this.items.push(catPill, pfPill);
        }else if(catPill !='All' && pfPill ==='All'){
            this.items.push(catPill);
        }else if(catPill ==='All' && pfPill !='All'){
            this.items.push(pfPill);
        }else{
            this.items = [];
        }
        this.showFilters = true; 
    }
    removePill(pill){
        let type = pill.detail.item.name
        let index = pill.detail.index;
        this.items.splice(index, 1);
        if(type === 'catPill'){
            this.cat = 'All'
        }else{
            this.pf = 'All';
        }        
    }
 
        //handle the search button click
        //create search strings
    handleSearch(){
         if(this.searchType === 'Search Products'){
            this.search();  
         }else if(this.searchType === 'Search Promo'){
            this.searchPromo(); 
         }else{
            return; 
         }
        }

    async  search(){
           
            //console.log('pf '+this.pf+' cat '+this.cat +' searchTerm '+this.queryTerm);
            this.cat = !this.cat ? 'All':this.cat; 
            //console.log(test);
            this.whSearch = this.template.querySelector('[data-value="searchInput"]').value.trim().toLowerCase().replace(REGEX_WHITESPACE, "").match(REGEX_WAREHOUSE);
            this.stock = this.template.querySelector('lightning-input').value.trim().toLowerCase().match(REGEX_STOCK_RES);  
            this.searchTerm = this.template.querySelector('[data-value="searchInput"]').value.toLowerCase().replace(REGEX_24D, '2 4-D')
            .replace(REGEX_COMMA,' and ').replace(REGEX_SOSL_RESERVED,'?').replace(REGEX_STOCK_RES,'').replace(REGEX_WAREHOUSE, '').trim();
            
            if(this.searchTerm.length<3){
                //need alert here
                return
            }

            this.loaded = false;

                //this var tells the search if we need to look at just the warehouse or more. Built as a back up as we update products
                //at this time it is winter and not a lot of products are being updated. So this will see if we should look for the wh200
                //however, if it fails we should then go ahead and do the normal search then warn the user that it is possible the WH200 was not found and we are showing
                //the normal tag search
                let searchRacks;
                let backUpQuery;
                if(this.stock){
                    this.stock = spellCheck(this.stock[0])
                }

                let buildSearchInfo = cpqSearchString(this.searchTerm, this.stock, this.whSearch)
                this.searchQuery = buildSearchInfo.builtTerm;  
                searchRacks = buildSearchInfo.wareHouseSearch; 
                backUpQuery = buildSearchInfo.backUpQuery
            try {
                let data = await searchTag({searchKey: this.searchQuery, searchWareHouse:searchRacks, backUpSearch: backUpQuery}) 
                //here we split up the returned wrapper. 
                //access the tags object using data.tags and the warehouse search using data.wareHouseFound
                let tags = data.tags != undefined ? data.tags : []
                let backUpSearchUsed = data.backUpSearchUsed; 
                let once = tags.length> 1 ? await uniqVals(tags) : tags;
                this.searchSize = once.length;
                //this group results by stock status then score
                once.sort((a,b)=>b.Stock_Status__c.localeCompare(a.Stock_Status__c) || b.ATS_Score__c - a.ATS_Score__c,);
                this.prod = await once.map((item, index)=>({
                    ...item, 
                    Name: item.Product__r.Temp_Unavailable__c ? item.Product_Name__c + ' - ' +item.Product__r.Temp_Mess__c : item.Product_Name__c,
                    ProductCode: item.Product_Code__c + ' - '+item.ATS_Score__c,
                    Floor_Price__c: item?.Floor_Price__c ?? 0, 
                    agency: item.Product__r.Agency_Product__c,
                    onhand: item.Product__r.Total_Product_Items__c,
                    icon: item.Product__r.Temp_Unavailable__c ? 'action:freeze_user':'action:new',
                    title: '',
                    weight: item.Product__r.Ship_Weight__c,
                    status: item.Stock_Status__c,
                    palletConfig: item.Product__r.Pallet_Qty__c,
                    msg: item.Product__r.Temp_Mess__c,
                    sgn: item.Product__r.SGN__c,
                    rup: item.Product__r.RUP__c,
                    Score: item.ATS_Score__c,
                    progScore: item?.W_Program_Score__c ?? 'not set',
                    profit: item?.W_Product_Profitability__c,
                    invScore: item?.W_Inventory_Score__c ?? 'not set',
                    fp: item?.W_Focus_Product__c ?? 0,
                    searchIndex: index + 1
                })) 

                if(backUpSearchUsed){
                    let  DIDNT_FIND_AT_WAREHOUSE = [{Id:'1343', Name:`Not yet tagged for ${this.whSearch}, confirm Inventory after Selection`}]
                    this.prod =  [...DIDNT_FIND_AT_WAREHOUSE, ...this.prod] 
                }
                this.loaded = true; 
            } catch (error) {
                this.error = error;
                console.error(this.error); 
                this.loaded = true; 
            }

      
        }
    //helper function finds selected product and changes button. 
    findProduct(sel){
        let index = this.prod.findIndex(item => item.Id === sel.target.name)
        
        if(this.prod[index].icon === 'action:freeze_user'){
            alert('Temp unavaliable reason: ' + this.prod[index].msg)
        }else if(this.prod[index].icon==='action:new'){
            this.prod[index].icon = 'action:approval'
            this.prod[index].title = 'added!'
            this.addProduct(this.prod[index]);
        }else{
            this.prod[index].icon = 'action:new'
            this.prod[index].title = ''
            this.removeProduct(this.prod[index])
        }
        return ;
        
    }
    addProduct(product){
        const rowProduct = product.Product__c;
        const rowCode = product.Product_Code__c;
        const rowId = product.Id; 
        const rowIndex = product.searchIndex;
        const rowScore = product.Score; 
        this.dispatchEvent(new CustomEvent('newprod',{
            detail: {
                prodId: rowProduct,
                prodCode: rowCode,
                searchedTerm: this.searchTerm,
                searchSize: this.searchSize,
                searchIndex: rowIndex,
                tagId: rowId,
                tagScore: rowScore
            }
        }))
    }

    removeProduct(sProd){
        const removeCode = sProd.ProductCode;

        this.dispatchEvent(new CustomEvent('remove',{
            detail: removeCode
        }))
    }
    @api
    showResult(mess){
        console.log('mess ' +mess); 
    }


    handleCancel(){
        console.log('cancel');
        
    }
}