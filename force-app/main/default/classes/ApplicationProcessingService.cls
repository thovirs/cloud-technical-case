public with sharing class ApplicationProcessingService {

    public static ApplicationFormController.ApplicationResult processApplication(ApplicationFormController.ApplicationDTO app) {

        // business logic: 
        // 1. Check if an Account with the Tax Id exists
        // 2. If exists, create an Opportunity under that Account
        // o	Name: app.companyName + ' - New Application'
        // o	StageName: Prospecting
        // o	CloseDate: Today + 30 days
        // o	AccountId: the matched account
        // o	Application_Source__c: Community or Webhook
        // If not exists, create a Lead
        // o	FirstName, LastName, Email, Phone
        // o	Company = app.companyName
        // o	Federal_Tax_Id__c = app.federalTaxId
        // o	Application_Source__c: Community or Webhook
        // Return the created record type and Id.

        // Placeholder for processing logic
        ApplicationFormController.ApplicationResult result = new ApplicationFormController.ApplicationResult();
        
        // should use stripInaccessible here?
        Account matchedAccount;
        if (!String.isBlank(app.federalTaxId)) {
            List<Account> accs = [SELECT Id FROM Account WHERE Federal_Tax_Id__c = :app.federalTaxId LIMIT 1];
            matchedAccount = accs.isEmpty() ? null : accs[0];
        } else if (!String.isBlank(app.companyName)) {
            List<Account> accs = [SELECT Id FROM Account WHERE Name = :app.companyName LIMIT 1];
            matchedAccount = accs.isEmpty() ? null : accs[0];
        }

        if (matchedAccount != null) {
            Opportunity newOpportunity = new Opportunity(
                Name = app.companyName + ' - New Application',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = matchedAccount.Id
            );

            if (!String.isBlank(app.applicationSource)) {
                newOpportunity.Application_Source__c = app.applicationSource;
            }
            insert newOpportunity;

            result.success = true;
            result.recordType = 'Opportunity';
            result.recordId = newOpportunity.Id;
            result.message = 'Opportunity created successfully: ' + newOpportunity.Id;

        } else {
            Lead newLead = new Lead(
                FirstName = app.firstName,
                LastName = app.lastName,
                Email = app.email,
                Phone = app.phone,
                Company = app.companyName,
                Federal_Tax_Id__c = app.federalTaxId,
                AnnualRevenue = app.annualRevenue
            );

            if (!String.isBlank(app.applicationSource)) {
                newLead.Application_Source__c = app.applicationSource;
            }
            insert newLead;

            result.message = 'Lead created successfully: ' + newLead.Id;
            result.recordType = 'Lead';
            result.recordId = newLead.Id;
            result.success = true;
        } 
        return result;

    }

    
}