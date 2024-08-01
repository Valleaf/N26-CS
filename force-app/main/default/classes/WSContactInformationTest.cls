@IsTest
private class WSContactInformationTest{
    @TestSetup
    static void makeData(){
        // Create a test contact
        Contact contact1 = DataFactory.createTestContact('Standard', 'DE');
        contact1.External_Reference__c = 'aaaa';
        insert contact1;
    }

    @isTest
    static void testGetCaseById(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = 
            'https://yourInstance.my.salesforce.com/services/apexrest/ContactInformation/' + 
            'aaaa';
        request.httpMethod = 'GET';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response = res;
        // Call the method to test
        Test.startTest();
        WSContactInformationManager.getContactByExtId();
        Test.stopTest();

        String actual = res.responseBody.toString(); //Convert Blob to String
        Assert.areEqual('{"product":"Standard","lastName":"Contact","homeCountry":"DE","firstName":"Test","costPerCalendarMonth":"0.0","cardReplacementCost":"6.0","atmFee":"1.7"}', actual, 'The response should be equal to: {"product":"Standard","lastName":"Contact","homeCountry":"DE","firstName":"Test","costPerCalendarMonth":"0.0","cardReplacementCost":"6.0","atmFee":"1.7"}');
    }

    @isTest
    static void testGetCaseByIdButProductDoesNotExist(){
        // Update the contact to put wrong product information
        Contact contact1 = [SELECT Id, Product__c FROM Contact WHERE External_Reference__c = 'aaaa'];
        contact1.Product__c = null;
        update contact1;

        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = 
            'https://yourInstance.my.salesforce.com/services/apexrest/ContactInformation/' + 
            'aaaa';
        request.httpMethod = 'GET';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response = res;
        // Call the method to test
        Test.startTest();
        WSContactInformationManager.getContactByExtId();
        Test.stopTest();

        String actual = res.responseBody.toString(); //Convert Blob to String
        Assert.areEqual('There has been an error : The contact does not have a Home Country or Product.', actual, 'The response should be equal to: There has been an error : The contact does not have a Home Country or Product.');
    }

    @isTest
    static void testGetCaseByIdDoesNotExist(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = 
            'https://yourInstance.my.salesforce.com/services/apexrest/ContactInformation/' + 
            'bbbb';
        request.httpMethod = 'GET';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response = res;
        // Call the method to test
        Test.startTest();
        WSContactInformationManager.getContactByExtId();
        Test.stopTest();

        String actual = res.responseBody.toString(); //Convert Blob to String
        Assert.areEqual('There has been an error : Unable to find the contact', actual, 'The response should be equal to: There has been an error : Unable to find the contact');
    }

    @isTest
    static void testUpsertContacts(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        // // The JSON sent as test is this one :
        // [
        // {"externalReference" : "aaaa",  "lastName" : "Mastroianni", "firstName" : "Marcello" , "product" : "Metal", "homeCountry" : "IT"},
        // {"externalReference" : "abc2",  "lastName" : "Reno", "firstName" : "Jean" , "product" : "Black", "homeCountry" : "FR"},
        // {"externalReference" : "abc3",  "lastName" : "Frisch", "firstName" : "Arno", "product" : "Standard",  "homeCountry" : "DE"},
        // {"externalReference" : "abc4",  "lastName" : "Noriega", "firstName" : "Eduardo", "product" : "Metal" ,"homeCountry" : "ES"},
        // {"externalReference" : "abc5",  "lastName" : "Craig", "firstName" : "Daniel" , "product" : "Metal" ,"homeCountry" : "UK"}
        // ]
        request.requestBody = Blob.valueOf('[{"externalReference" : "aaaa",  "lastName" : "Mastroianni", "firstName" : "Marcello" , "product" : "Metal", "homeCountry" : "IT"},{"externalReference" : "abc2",  "lastName" : "Reno", "firstName" : "Jean" , "product" : "Black", "homeCountry" : "FR"},{"externalReference" : "abc3",  "lastName" : "Frisch", "firstName" : "Arno", "product" : "Standard",  "homeCountry" : "DE"},{"externalReference" : "abc4",  "lastName" : "Noriega", "firstName" : "Eduardo", "product" : "Metal" ,"homeCountry" : "ES"},{"externalReference" : "abc5",  "lastName" : "Craig", "firstName" : "Daniel" , "product" : "Metal" ,"homeCountry" : "UK"}]');
        request.httpMethod = 'PUT';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response = res;
        // Call the method to test
        Test.startTest();
        WSContactInformationManager.upsertContacts();
        Test.stopTest();

        String actual = res.responseBody.toString(); //Convert Blob to String
        Assert.areEqual('Successfully upserted 5 Contacts', actual, 'The response should be equal to: Successfully upserted 5 Contacts');
        Contact[] contacts = [SELECT Id FROM Contact];
        Assert.areEqual(5, contacts.size(), 'There should be 5 Contacts in the database');
    }

    @isTest 
    static void testUpsertContactsNoContacts(){
        // Set up a test request
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestBody = Blob.valueOf('[]');
        request.httpMethod = 'PUT';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response = res;
        // Call the method to test
        Test.startTest();
        WSContactInformationManager.upsertContacts();
        Test.stopTest();

        String actual = res.responseBody.toString(); //Convert Blob to String
        Assert.areEqual('There has been an error : No contacts to upsert', actual, 'The response should be equal to: There has been an error : No contacts to upsert');
    }

}