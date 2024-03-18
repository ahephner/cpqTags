import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getBooks from '@salesforce/apex/getPriceBooks.getPriceBookIds'
import CUSTID from '@salesforce/schema/Opportunity.AccountID__c';
import CUST_NAME from '@salesforce/schema/Opportunity.Account_Name_Text__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi'; 

const standard = [{id:'01s410000077vSKAAY', label:'Standard Price', name:'01s410000077vSKAAY'}]
export default class QuickPriceBookCheck extends NavigationMixin(LightningElement) {
    @api recordId;
    books;
    loaded = false;
    custName;
    custId;
    standard = standard;
    err; 
    @wire(getRecord,{recordId: '$recordId', fields:[CUSTID, CUST_NAME]})
        wiredCust({data,error}){
            if(data){
               
                this.custId = getFieldValue(data, CUSTID);
                this.custName = getFieldValue(data, CUST_NAME);
                 
            }else if(error){
                console.error(2, error)
                this.err = error
            }
        }
    @wire(getBooks,{accountId:'$custId'})
        wiredBooks({data, error}){
            if(data){
                
                let back = data.map(x=>{
                    return{
                        id: x.Id,
                        label:x.Pricebook2.Name,
                        name:x.Pricebook2Id
                    }
                })
                this.books = [...this.standard, ...back]
                this.loaded = true;
            }else if(error){
                this.books = [...this.standard]
                this.loaded = true; 
                console.error(error)
            }

        }
        recordPageUrl
        onClickHandler(evt){
            let targetId = evt.target.name; 
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: targetId,
                    actionName: 'view',
                },
            }).then((url)=>{
                this.recordPageUrl = url
                window.open(this.recordPageUrl);    
            })
        }
}