@RestResource(urlMapping='/external/applications')
global class ApplicationWebhookController {
  
    @HttpPost 
    global static WebhookResponse handlePost(){
        WebhookResponse out = new WebhookResponse();

        try {
            RestRequest req = RestContext.request;
            String body = req.requestBody == null ? null : req.requestBody.toString(); 
            System.debug('Received webhook body: ' + body);

            // early exit on empty body
            if (String.isBlank(body)) {
                out.success = false;
                out.message = 'Request body is empty.';
                return out;
            }

            WebhookRequest incoming = (WebhookRequest) JSON.deserialize(body, WebhookRequest.class);
            
            ApplicationFormController.ApplicationDTO dto = new ApplicationFormController.ApplicationDTO();
            dto.companyName = incoming.companyName;
            dto.federalTaxId = incoming.federalTaxId;
            dto.annualRevenue = incoming.annualRevenue;
            dto.firstName = incoming.contact != null ? incoming.contact.firstName : null;
            dto.lastName = incoming.contact != null ? incoming.contact.lastName : null;
            dto.email = incoming.contact != null ? incoming.contact.email : null;
            dto.phone = incoming.contact != null ? incoming.contact.phone : null;   
            dto.applicationSource = 'Webhook';


            // call ApplicationProcessingService
            ApplicationFormController.ApplicationResult res = ApplicationProcessingService.processApplication(dto);
            out.success = res.success;
            out.recordType = res.recordType;
            out.recordId = res.recordId == null ? null : String.valueOf(res.recordId);
            out.message = res.success ? 'Application processed successfully': res.message;
            return out;

        } catch (Exception e) {
            out.success = false;
            out.message = 'Error processing request: ' + e.getMessage();
            return out;
        }

    }

    public class WebhookRequest {
        public String companyName { get; set; }
        public String federalTaxId { get; set; }
        public Contact contact { get; set; }
        public Double annualRevenue { get; set; }

    }
    public class Contact {
        public String firstName { get; set; }
        public String lastName { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
    }
    
    global class WebhookResponse {
        public Boolean success { get; set; }
        public String recordType { get; set; }
        public String recordId { get; set; }
        public String message { get; set; }
    }
            
}

// Expected JSON payload:
// {
//   "companyName": "Acme Corp",
//   "federalTaxId": "BG123456789",
//   "contact": {
//     "firstName": "Ivan",
//     "lastName": "Ivanov",
//     "email": "ivan@example.com",
//     "phone": "+359888123456"
//   },
//   "annualRevenue": 500000
// }
