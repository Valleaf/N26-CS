// SF
import { LightningElement, wire, api, track } from 'lwc';

// Functions
import getCostPerProduct from '@salesforce/apex/DisplayProductInfoController.getCostPerProduct';

// Labels
import atm from "@salesforce/label/c.LWC_ATM_FEE_IN_OTHER_CURRENCIES";
import cardReplacement from "@salesforce/label/c.LWC_CARD_REPLACEMENT_COST";
import costPerCalendarMonth from "@salesforce/label/c.LWC_COST_PER_CALENDAR_MONTH";
import country from "@salesforce/label/c.LWC_COUNTRY";
import customerProductInformation from "@salesforce/label/c.LWC_CUSTOMER_PRODUCT_INFORMATION";
import productName from "@salesforce/label/c.LWC_PRODUCT_NAME";
import free from "@salesforce/label/c.LWC_FREE";

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