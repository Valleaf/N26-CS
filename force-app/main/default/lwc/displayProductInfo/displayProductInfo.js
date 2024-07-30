// SF
import { LightningElement, wire, api, track } from 'lwc';

// Functions
import getCostPerProduct from '@salesforce/apex/DisplayProductInfoController.getCostPerProduct';

// Labels
import atm from "@salesforce/label/c.ATM_Fee_In_Other_Currencies";
import cardReplacement from "@salesforce/label/c.Card_Replacement_Cost";
import costPerCalendarMonth from "@salesforce/label/c.Cost_Per_Calendar_Month";
import country from "@salesforce/label/c.Country";
import customerProductInformation from "@salesforce/label/c.Customer_Product_Information";
import productName from "@salesforce/label/c.Product_Name";
import free from "@salesforce/label/c.Free";

export default class DisplayProductInfo extends LightningElement {

    @api recordId;
    @wire(getCostPerProduct, { recordId: '$currentRecordId' }) currentCostPerProduct;

    currentRecordId;
    isAtmPaid = false;
    IscostPerMonthNotNull = false;
    currency = '€';

    // Expose labels to the template
    label = {
        atm,
        cardReplacement,
        costPerCalendarMonth,
        country,
        customerProductInformation,
        productName,
        free
    }

    /**
     * Initializes the component and sets the currentRecordId to the value of recordId.
     */
    connectedCallback() {
        this.currentRecordId = this.recordId;
    }

    /**
     * Renders the component and sets the currentRecordId to the value of recordId.
     * If the currentCostPerProduct.data is not null, it sets the isAtmPaid to true if the ATM fee is not zero.
     * It also sets the currency to the value of currentCostPerProduct.data.Currency__c if it is not null.
     * It sets the iscostPerMonthNotNull to true if the cost per calendar month is not null.
     *
     */
    renderedCallback() {
        if (this.currentCostPerProduct.data != null) {
            if (this.currentCostPerProduct.data.ATM_Fee_in_other_currencies__c != 0) {
                this.isAtmPaid = true;
            }
            if (this.currentCostPerProduct.data.Currency__c != null) {
                this.currency = this.currentCostPerProduct.data.Currency__c;
            }
            if (this.currentCostPerProduct.data.Cost_Per_Calendar_Month__c != null) {
                this.IscostPerMonthNotNull = true;
            }
        }
    }

}