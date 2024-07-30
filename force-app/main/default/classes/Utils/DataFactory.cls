/** 
 * Used to create test data
 */
public with sharing class DataFactory {

    public static Id getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
    }

    public static User createTestUser (String profileName) {

        User uTest = new User();
        uTest.Username = 'test' + String.valueOf(Crypto.getRandomLong()) + '@test.com';
        uTest.FirstName = 'Test';
        uTest.LastName = 'User';
        uTest.Email = 'test' + String.valueOf(Crypto.getRandomLong()) + '@test.com';
        uTest.Alias = 'test' + String.valueOf(Crypto.getRandomLong()).substring(0, 4);
        uTest.TimeZoneSidKey = 'Europe/Paris';
        uTest.LocaleSidKey = 'fr_FR_EURO';
        uTest.EmailEncodingKey = 'UTF-8';
        uTest.LanguageLocaleKey = 'fr';
        uTest.UserRoleId = [SELECT Id FROM UserRole LIMIT 1].Id;
        if(profileName == null) {
            if(UserInfo.getLanguage() == 'fr') {
                profileName = 'Administrateur Système';
            } else if (UserInfo.getLanguage() == 'en_US') {
                profileName = 'System Administrator';
            }
        }
        uTest.ProfileId = getProfileId(profileName);
        return uTest;
    }

    /**
     * Creates a test contact
     * @param product Product of the contact, Standard, Black or Metal
     * @param homeCountry Home Country of the contact, DE, FR, ES, IT or UK
      */
    public static Contact createTestContact(String product, String homeCountry) {
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.Product__c = product;
        c.Home_Country__c = homeCountry;
        return c;
    }

    public static Case createTestCase(Contact c) {
        Case cs = new Case();
        cs.ContactId = c.Id;
        return cs;
    }

}