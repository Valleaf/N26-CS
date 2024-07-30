public with sharing class DisplayProductInfoController{

    // Write a method comment
    /** 
     * Get the cost per product for the current case. Used in the lightning component displayProductInfo.
     * @param recordId Id of the case
     * @return Cost_Per_Product__mdt
     */
    @AuraEnabled(cacheable=true)
    public static Cost_Per_Product__mdt getCostPerProduct(String recordId){
        System.debug(recordId);
        Case currentCase = [SELECT Contact.Product__c, Contact.Home_country__c FROM Case WHERE Id = :Id.valueOf(recordId)];
        String product = currentCase.Contact.Product__c;
        String homeCountry = currentCase.Contact.Home_country__c;
        return Cost_Per_Product__mdt.getInstance(product + '_' + homeCountry);
    } 
    


}