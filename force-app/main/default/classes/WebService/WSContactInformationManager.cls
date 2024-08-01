@RestResource(urlMapping = '/ContactInformation/*')
global with sharing class WSContactInformationManager{
    public class WSException extends Exception{
    }

    global class ContactInformation{
        public String firstName{ get; set; }

        public String lastName{ get; set; }

        public String product{ get; set; }

        public String homeCountry{ get; set; }

        public String atmFee{ get; set; }

        public String cardReplacementCost{ get; set; }

        public String costPerCalendarMonth{ get; set; }

        public ContactInformation(Contact contact, Cost_Per_Product__mdt costPerProduct){
            firstName = contact.FirstName;
            lastName = contact.LastName;
            product = costPerProduct.Product__c;
            homeCountry = costPerProduct.Home_Country__c;
            atmFee = String.valueOf(costPerProduct.ATM_Fee_in_other_currencies__c);
            cardReplacementCost = String.valueOf(costPerProduct.Card_Replacement_Cost__c);
            costPerCalendarMonth = String.valueOf(costPerProduct.Cost_Per_Calendar_Month__c);
        }

    }

    global class ContactWrapper{
        String firstName;
        String lastName;
        String product;
        String homeCountry;
        String externalReference;
    }

    @HttpGet
    global static void getContactByExtId(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        // Get the unique Id from the end of the URL
        String contactExtId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        try{
            // Get the contact
            Contact c;
            Contact[] contactList = [SELECT FirstName, LastName, Product__c, Home_Country__c
                           FROM Contact
                           WHERE External_Reference__c = :contactExtId];
            if (contactList.isEmpty()){
                WSException e = new WSException();
                e.setMessage(System.Label.WS_NORECORD);
                throw e;
            } else {
                c = contactList[0];
            }
            Cost_Per_Product__mdt cPP;

            // Check if the contact has a product and home country and get the cost per product
            if (c?.Product__c != null && c?.Home_Country__c != null){
                cPP = Cost_Per_Product__mdt.getInstance(c.Product__c + '_' + c.Home_Country__c);
                if (cPP == null){
                    WSException e = new WSException();
                    e.setMessage(System.Label.WS_NOPRODUCTINFO);
                    throw e;
                }
            } else{
                WSException e = new WSException();
                e.setMessage(System.Label.WS_CONTACTMISSINGINFO);
                throw e;
            }

            // Return the contact information
            res.responseBody = Blob.valueOf(JSON.serialize(new ContactInformation(c, cPP)));
            res.statusCode = 200;
        } catch (Exception e){
            System.debug('The following exception has occurred line : ' + e.getLineNumber());
            System.debug('The exception message is : ' + e.getMessage());
            System.debug('The stack trace is : ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(System.Label.WS_ERROR + ' : ' + e.getMessage());
            res.statusCode = 400;
        }
    }

    /**
     * @HttpPut - upsert
     * @param jsonString - JSON containing the list of contacts
     * @return void
     */
    @HttpPut
    global static void upsertContacts(){
        String requestBody = RestContext.request.requestBody.toString();
        RestResponse res = RestContext.response;
        try{
            List<Contact> contactsToUpsert = new List<Contact>();
            List<ContactWrapper> contactsWrappers = (List<ContactWrapper>)JSON.deserializeStrict(requestBody, List<ContactWrapper>.class);
            if (contactsWrappers.isEmpty()){
                WSException e = new WSException();
                e.setMessage(System.Label.WS_NOTHINGTOUPSERT);
                throw e;
            } else{
                // Find out if the contacts already exists
                Set<String> contactsExtIds = new Set<String>();
                for (ContactWrapper cw : contactsWrappers){
                    contactsExtIds.add(cw.externalReference);
                }
                Map<String, Contact> contactsMap = new Map<String, Contact>();
                for (Contact c : [SELECT Id, External_Reference__c
                                  FROM Contact
                                  WHERE External_Reference__c IN:contactsExtIds
                                  LIMIT 50000]){
                    contactsMap.put(c.External_Reference__c, c);
                }
                for (ContactWrapper cw : contactsWrappers){
                    Contact c = new Contact();
                    c.External_Reference__c = cw.externalReference;
                    c.FirstName = cw.firstName;
                    c.LastName = cw.lastName;
                    c.Product__c = cw.product;
                    c.Home_Country__c = cw.homeCountry;
                    c.Id = contactsMap.get(c.External_Reference__c)?.Id;
                    contactsToUpsert.add(c);
                }
            }
            if (!contactsToUpsert.isEmpty()){
                upsert contactsToUpsert;
                res.statusCode = 201;
                res.responseBody = Blob.valueOf(System.Label.WS_UPSERTSUCCESS + ' ' + contactsToUpsert.size() + ' ' + Schema.getGlobalDescribe().get('Contact').getDescribe().getLabelPlural());
            } else{
                WSException e = new WSException();
                e.setMessage(System.Label.WS_NOTHINGTOUPSERT);
                throw e;
            }
        } catch (Exception e){
            System.debug('The following exception has occurred line : ' + e.getLineNumber());
            System.debug('The exception message is : ' + e.getMessage());
            System.debug('The stack trace is : ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(System.Label.WS_ERROR + ' : ' + e.getMessage());
            res.statusCode = 400;
        }
    }

}