import { LightningElement } from 'lwc';

export default class MobileSearchContainer extends LightningElement {
    searchType = 'Search Promo'
    searchBarLabel = 'Search Products'

    handleSwitchSearch(evt){
        this.searchType = evt.detail.value === 'Search Promo' ? 'Search Products' : 'Search Promo';
        this.searchBarLabel = evt.detail.value; 
    }

    handleDone(){
        this.loaded = false;
        this.dispatchEvent(new CustomEvent('close'));
        
    }

    handleNewProduct(pkg){
        
    }

}