import LightningDatatable from 'lightning/datatable';
import custName from './custName.html'; 
export default class DataCell extends LightningDatatable {
    static customTypes = {
        customName:{
            template: custName,
            standardCellLayout: true,
            typeAttributes: ['prodName', 'atsScore', 'classValue', 'profitability', 'progScore', 'invScore', 'focusProd' ]
        }
    }
}