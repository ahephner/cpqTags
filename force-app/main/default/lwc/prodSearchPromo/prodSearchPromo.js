import { LightningElement, api } from 'lwc';
import searchPromos from '@salesforce/apex/cpqTagsSearch.searchPromos';
import onLoadPromos from '@salesforce/apex/cpqTagsSearch.onLoadPromos';
import onLoadTagPromos from '@salesforce/apex/cpqTagsSearch.onLoadTagPromos';
import LightningAlert from 'lightning/alert';
import { uniqPromo, uniqVals, promoProductNames,promoLoad} from 'c/tagHelper';
export default class ProdSearchPromo extends LightningElement{
    @api term; 
    loaded = true; 
    data; 
    dateNow = new Date();
    today = this.dateNow.getFullYear()+'-'+(this.dateNow.getMonth()+1)+'-'+this.dateNow.getDate();
    loadedBefore = false
    testing; 
    connectedCallback(){
      //this.initLoad();
      this.initLoad2(); 
    }

    getFormattedDate(stringDateIn, stringDate2) {
        let date = new Date(stringDateIn)
        let date2 = new Date(stringDate2)
        let year = date.getFullYear();
        let month = (1 + date.getMonth()).toString().padStart(2, '0');
        let day = date.getDate().toString().padStart(2, '0');
        let prettyDate = month + '/' + day + '/' + year;
        let diff = Math.ceil(((date.getTime() - date2.getTime())/ (1000 * 3600 * 24))) //-1;
        return {
                prettyDate,
                diff
        }
            }
    async initLoad2(){
        this.testing = true; 
        if(!this.loadedBefore && this.data === undefined){
            
            this.loaded = false
            try {
                let pros = await onLoadTagPromos();
                //combine all the products into a single field with search_label__c as key
                let prodNameObj = await promoProductNames(pros); 
                //only need one promo card. This will take the multiple values returned form apex and single it to one object per promo
                let singlePromo = pros.length> 1 ? await uniqPromo(pros) : pros;
                //combine the previous 2 vars to display
                this.data = await promoLoad(singlePromo, prodNameObj)

                this.loadedBefore =true; 
                this.loaded = true; 
                //console.log(JSON.stringify(this.data))
            } catch (error) {
                await LightningAlert.open({
                    message: error,
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            }
        }
    }
    async initLoad(){
        this.testing = false;
        if(!this.loadedBefore && this.data === undefined){
            
            this.loaded = false
            try {
                let pros = await onLoadPromos()
                //let once = pros.length> 1 ? await uniqPromo(pros) : pros;

                    this.data = await pros.map((item, index)=>({
                        ...item,
                        experDate: this.getFormattedDate(item.Expiration_Date__c, this.today).prettyDate,
                        experDays: this.getFormattedDate(item.Expiration_Date__c, this.today).diff,
                        btnName: "utility:add",
                        btnVariant: "brand",
                        dayClass: this.getFormattedDate(item.Expiration_Date__c, this.today).diff<= 7 ? 'redClass': '',
                        prodNames: [{id: 1, name:'JOHN DEERE BED KNIFE SCREWS- 100 / PKG'},{id:2, name:'JD DURANIUM SUPER TOURNAMENT BED KNIFE'}]
                    }))
                this.loadedBefore =true; 
                this.loaded = true; 
                //console.log(JSON.stringify(this.data))
            } catch (error) {
                await LightningAlert.open({
                    message: error,
                    theme: 'error', // a red theme intended for error states
                    label: 'Error!', // this is the header text
                });
            }
        }
    }
    @api
    async promoSearch(searchString){
        this.loaded = false
        try {
            let pros = await searchPromos({query:searchString})
            //let once = pros.length> 1 ? await uniqPromo(pros) : pros;

                this.data = await pros.map((item, index)=>({
                    ...item,
                    experDate: this.getFormattedDate(item.Expiration_Date__c, this.today).prettyDate,
                    experDays: this.getFormattedDate(item.Expiration_Date__c, this.today).diff,
                    btnName: "utility:add",
                    btnVariant: "brand",
                    dayClass: this.getFormattedDate(item.Expiration_Date__c, this.today).diff<= 7 ? 'redClass': '' 
                }))
            
            this.loaded = true; 
            //console.log(JSON.stringify(this.data))
        } catch (error) {
            await LightningAlert.open({
                message: error,
                theme: 'error', // a red theme intended for error states
                label: 'Error!', // this is the header text
            });
        }
    }
//export get products add to order
    addPromo(e){
        const rowId = e.target.name;
        let index = this.data.find((tar)=> tar.Id === rowId); 
       

        const dp =  Number(e.currentTarget.dataset.label); 
        const discountPercent = isNaN(dp) || dp===null ? 1 : dp/100;  
        
        const promoDetail = {
            promoId: index.Search_Label__c,
            discount: discountPercent
        }
        this.dispatchEvent(new CustomEvent('promoid', {
            detail: promoDetail
        }))
        
        index.btnName = 'action:check';
        index.btnVariant = 'success'; 
        this.data = [...this.data]; 
    }
}