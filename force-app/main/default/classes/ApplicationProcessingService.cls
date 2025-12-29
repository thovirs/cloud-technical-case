public with sharing class ApplicationProcessingService {

    public static ApplicationFormController.ApplicationResult processApplication(ApplicationFormController.ApplicationDTO app) {

        ApplicationFormController.ApplicationResult result = new ApplicationFormController.ApplicationResult();
        
        Account matchedAccount;
        List<Account> accs = [SELECT Id, Name, Federal_Tax_Id__c FROM Account WHERE Federal_Tax_Id__c = :app.federalTaxId OR Name = :app.companyName];
        for (Account acc : accs) {
            System.debug('Matched Account: ' + acc);
            // prefer Tax Id match over Name match
            if(acc.Federal_Tax_Id__c == app.federalTaxId) {
                matchedAccount = acc;
                break;
            } 
            if(matchedAccount == null && acc.Name == app.companyName) {
                matchedAccount = acc;
            }
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