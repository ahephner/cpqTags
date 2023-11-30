import { LightningElement, api, track } from 'lwc';
import LightningAlert from 'lightning/alert';
import searchTag from '@salesforce/apex/cpqTagsSearch.cpqSearchTag';
import searchPromos from '@salesforce/apex/cpqTagsSearch.searchPromos';

const REGEX_SOSL_RESERVED = /(\?|&|\||!|\{|\}|\[|\]|\(|\)|\^|~|\*|:|"|\+|\\)/g;
const REGEX_STOCK_RES = /(stock|sock|limited|limted|lmited|limit|close-out|close out|closeout|close  out|exempt|exmpet|exemept|southern stock|southernstock|southner stock)/g; 
const REGEX_COMMA = /(,)/g;

import {spellCheck, cpqSearchStringMobile, uniqVals} from 'c/tagHelper';

export default class MobileSearchTags extends LightningElement{
    queryTerm;
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
        this.queryTerm = this.template.querySelector('lightning-input').value.toLowerCase().replace(REGEX_COMMA,' and ').replace(REGEX_SOSL_RESERVED,'?').replace(REGEX_STOCK_RES,'').trim();
        this.stock = this.template.querySelector('lightning-input').value.trim().toLowerCase().match(REGEX_STOCK_RES);  
        if(this.queryTerm.length<3){
            //need alert here
            return
        }
        this.loaded = false; 
        if(this.stock){
            this.stock = spellCheck(this.stock[0])
            this.searchQuery = cpqSearchStringMobile(this.queryTerm, this.stock);
        }else{
            this.searchQuery = cpqSearchStringMobile(this.queryTerm, this.stock);   
        }
        this.search();  
        }

    async  search(){
            let test; 
            //console.log('pf '+this.pf+' cat '+this.cat +' searchTerm '+this.queryTerm);
            this.cat = !this.cat ? 'All':this.cat; 
            //console.log(test);
            
            try {
                let data = await searchTag({searchKey: this.searchQuery})
                let once = data.length> 1 ? await uniqVals(data) : data; 
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
                    fp: item?.W_Focus_Product__c ?? 0
                })) 
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
        this.dispatchEvent(new CustomEvent('newprod',{
            detail: [rowProduct, rowCode]
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
    handleDone(){
        this.loaded = false;
        this.dispatchEvent(new CustomEvent('close'));
        
    }

    handleCancel(){
        console.log('cancel');
        
    }
}