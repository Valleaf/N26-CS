@IsTest
public with sharing class DisplayProductInfoControllerTest{
    @TestSetup
    static void makeData(){
        //Insert a user and use it to create a case with a contact
        User uu = DataFactory.createTestUser(null);
        insert uu;


        System.runAs(uu){
            Contact c1 = DataFactory.createTestContact('Standard', 'DE');
            insert c1;

            Case case1 = DataFactory.createTestCase(c1);
            insert case1;
        }
    }

    @IsTest
    static void testDisplayProductInfoController(){
        // Get the same user
        User u = [SELECT Id
                  FROM User
                  LIMIT 1];

        System.runAs(u){
            // Get the case and get the cost per product related
            Case cTest = [SELECT Id
                          FROM Case
                          LIMIT 1];

            Test.startTest();
            Cost_Per_Product__mdt cppTest = DisplayProductInfoController.getCostPerProduct(cTest.Id);
            Test.stopTest();

            // Assert the values. For Standard DE, ATM_Fee_in_other_currencies__c = 1.70, Card_Replacement_Cost__c = 6, Cost_Per_Calendar_Month__c = 0, Currency__c = '€', Home_Country__c = 'DE', Product__c = 'Standard'

            Assert.isNotNull(cppTest, 'Cost Per Product should not be null');
            Assert.areEqual(cppTest.Home_Country__c, 'DE', 'Country should be DE');
            Assert.areEqual(cppTest.Product__c, 'Standard', 'Product should be Standard');
            Assert.areEqual(cppTest.Currency__c, '€', 'Currency should be €');
            Assert.areEqual(cppTest.ATM_Fee_in_other_currencies__c, 1.70, 'ATM Fee should be 1.70');
            Assert.areEqual(cppTest.Cost_Per_Calendar_Month__c, 0, 'Cost Per Calendar Month should be 0');
            Assert.areEqual(cppTest.Card_Replacement_Cost__c, 6, 'Card Replacement Cost should be 6');
        }
    }

}