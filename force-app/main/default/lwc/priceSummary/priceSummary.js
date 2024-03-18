import { LightningElement } from 'lwc';

export default class PriceSummary extends LightningElement {
    hideFilter = true;
    limitValue;
    orderByValue = 'none'; 
    handleSearch(){
        console.log('clicked');
        
    }

    showFilter(){
       this.hideFilter = !this.hideFilter ? true : false; 
    }
    //order by
    get orderByOptions(){
        return[
            {label:'None', value:'none'},
            {label:'Highest Price', value:'high'},
            {label:'Lowest Price', value:'low'}
        ]
    }

    handleOrderBy(evt){
        this.orderByValue = evt.detail.value
    }
    //limit results
    get limitOptions() {
        let options = [];
        for(let i = 0; i<11; i++){
            let option = {label: `'${i}'`, value:i}
            options.push(option);
        }
        let noChoice = {label:'No', value:'no'}
        options.unshift(noChoice)
        return options; 
    }

    handleLimits(event){
        this.limitValue = event.detail.value; 
    }
}