 @isTest
 private without sharing class ApplicationProcessingServiceTest {
    
    @isTest
    static void testProcessApplication_LeadCreation() {
        ApplicationFormController.ApplicationDTO dto = new ApplicationFormController.ApplicationDTO();
        dto.companyName = 'New Company';
        dto.federalTaxId = '00-0000000';
        dto.firstName = 'Maria';
        dto.lastName = 'Ramos';
        dto.email = 'maria@test.com';
        dto.phone = '+551888123456';
        dto.applicationSource = 'Webhook';

        Test.startTest();
        ApplicationFormController.ApplicationResult result = ApplicationProcessingService.processApplication(dto);
        Test.stopTest();
        System.assertEquals(true, result.success);
        System.assertEquals('Lead', result.recordType);
        System.assertNotEquals(null, result.recordId);

    }

    @isTest
    static void testProcessApplication_OpportunityCreation_TaxIdMatch() {
        Account acc = new Account(Name = 'Existing Corp', Federal_Tax_Id__c = '11-1111111');
        insert acc;

        ApplicationFormController.ApplicationDTO dto = new ApplicationFormController.ApplicationDTO();
        dto.companyName = 'Existing Corp';
        dto.federalTaxId = '11-1111111';
        dto.firstName = 'Maria';
        dto.lastName = 'Ramos';
        dto.email = 'maria@test.com';
        dto.phone = '+551888123456';
        dto.applicationSource = 'Webhook';

        
        Test.startTest();
        ApplicationFormController.ApplicationResult result = ApplicationProcessingService.processApplication(dto);
        Test.stopTest();
        System.assertEquals(true, result.success);

        // check if Opportunity was created
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :result.recordId];
        System.assertEquals(acc.Id, opp.AccountId);
        System.assertEquals('Opportunity', result.recordType);

    }

    @isTest
    static void testProcessApplication_OpportunityCreation_NameMatch() {
        Account acc = new Account(Name = 'Existing Corp', Federal_Tax_Id__c = '22-2222222');
        insert acc; 

        ApplicationFormController.ApplicationDTO dto = new ApplicationFormController.ApplicationDTO();
        dto.companyName = 'Existing Corp';  
        dto.federalTaxId = '';
        dto.firstName = 'Maria';
        dto.lastName = 'Ramos';
        dto.email = 'maria@test.com';
        dto.phone = '+551888123456';
        dto.applicationSource = 'Webhook';

        
        Test.startTest();
        ApplicationFormController.ApplicationResult result = ApplicationProcessingService.processApplication(dto);
        Test.stopTest();
        System.assertEquals(true, result.success);

        // check if Opportunity was created
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :result.recordId];
        System.assertEquals(acc.Id, opp.AccountId);
        System.assertEquals('Opportunity', result.recordType);

    }

    @IsTest
    static void testProcessApplication_ApplicationSource_WebhookVsCommunity() {
        Account acc = new Account(Name = 'Source Test Corp', Federal_Tax_Id__c = '33-3333333');
        insert acc;

        ApplicationFormController.ApplicationDTO dtoWebhook = new ApplicationFormController.ApplicationDTO();
        dtoWebhook.companyName = 'Source Test Corp';
        dtoWebhook.federalTaxId = '33-3333333';
        dtoWebhook.firstName = 'Maria';
        dtoWebhook.lastName = 'Ramos';
        dtoWebhook.email = 'maria@test.com';
        dtoWebhook.phone = '+551888123456';
        dtoWebhook.applicationSource = 'Webhook';

        ApplicationFormController.ApplicationDTO dtoCommunity = new ApplicationFormController.ApplicationDTO();
        dtoCommunity.companyName = 'Source Test Corp';
        dtoCommunity.federalTaxId = '33-3333333';
        dtoCommunity.firstName = 'Maria';
        dtoCommunity.lastName = 'Ramos';
        dtoCommunity.email = 'maria@test.com';
        dtoCommunity.phone = '+551888123456';
        dtoCommunity.applicationSource = 'Community';

        Test.startTest();
        ApplicationFormController.ApplicationResult resWebhook = ApplicationProcessingService.processApplication(dtoWebhook);
        ApplicationFormController.ApplicationResult resCommunity = ApplicationProcessingService.processApplication(dtoCommunity);
        Test.stopTest();

        Set<Id> oppIds = new Set<Id>{ resWebhook.recordId, resCommunity.recordId };

        Map<Id, Opportunity> oppById = new Map<Id, Opportunity>([
            SELECT Id, Application_Source__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);

        System.assertEquals('Webhook', oppById.get(resWebhook.recordId).Application_Source__c);
        System.assertEquals('Community', oppById.get(resCommunity.recordId).Application_Source__c);

    }


}