public with sharing class ApplicationFormController {
    
    @AuraEnabled
    public static ApplicationResult submitApplication(ApplicationDTO input) {
        try {
            ApplicationResult res = new ApplicationResult();
            System.debug('Input received: ' + JSON.serialize(input));
            // Validate input
            if (input == null){
                res.success = false;
                res.message = 'Input cannot be null.';
                return res;
            } else if (!validateApplicationInput(input, res)) {
                res.success = false;
                return res;
                
            } else {
                return ApplicationProcessingService.processApplication(input);
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean validateApplicationInput(ApplicationDTO input, ApplicationResult res) {
        List<String> invalidFields = new List<String>();
        Boolean isValid = true;
        if (String.isBlank(input.firstName)) {
            invalidFields.add('Contact First Name');
            isValid = false;
        }
        if (String.isBlank(input.lastName)) {
            invalidFields.add('Contact Last Name');
            isValid = false;
        }
        if (String.isBlank(input.companyName)) {
            invalidFields.add('Company Name');
            isValid = false;
        }
        if (String.isBlank(input.email)) {
            invalidFields.add('Email');
            isValid = false;
        } else if (!isValidEmail(input.email)) {
            invalidFields.add('Email Format');
            isValid = false;
        }
        if (String.isBlank(input.phone)) {
            invalidFields.add('Phone');
            isValid = false;
        } else if (!isValidPhone(input.phone)) {
            invalidFields.add('Phone Format');
            isValid = false;
        }
        if (String.isBlank(input.federalTaxId)) {
            invalidFields.add('Federal Tax ID');
            isValid = false;
        }
        res.message = 'Invalid fields: ' + String.join(invalidFields, ', ');

        return isValid;
    }

    
    private static Boolean isValidEmail(String email) {
        // minimal validation for the case study
        return email != null && email.contains('@') && email.contains('.');
    }

    private static Boolean isValidPhone(String phone) {
        // minimal validation for the case study
        String digits = phone == null ? '' : phone.replaceAll('\\D', '');
        return digits.length() >= 8;
    }


    public class ApplicationDTO {
        @AuraEnabled public String companyName { get; set; }
        @AuraEnabled public String federalTaxId { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public Double annualRevenue { get; set; }
        @AuraEnabled public String applicationSource { get; set; } // 'Community' | 'Webhook'
    }

    public class ApplicationResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String message { get; set; }
    }

}