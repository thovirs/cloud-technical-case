# Salesforce Developer Case Study – Public Application Form & Webhook

This repository contains the solution for the Salesforce Developer Case Study, implementing a public application intake via Experience Cloud and a public REST webhook that share the same business logic.

---

## 🚀 Solution Overview

The solution is composed of four main layers:

1. Experience Cloud (Public Form – LWC)
2. Apex Controller (Form submission)
3. Shared Application Processing Service
4. Public Apex REST Webhook

Both the UI form and the webhook reuse the same processing service to ensure consistency and avoid duplicated business logic.

---

## 🧱 Architecture

LWC (Public Form)  
↓  
ApplicationFormController  
↓  
ApplicationProcessingService  
↑  
Apex REST Webhook (Public)

---

## ⚙️ Deployment & Setup Guide

### Prerequisites
- Salesforce CLI (sf)
- A Salesforce org (Developer Edition, Trailhead Playground or Sandbox)

### 1. Clone the repository
git clone https://github.com/<your-username>/<repository-name>.git  
cd <repository-name>

### 2. Authenticate to your Salesforce org
sf org login web -r https://login.salesforce.com -a cloudsquare-app

Use https://test.salesforce.com if deploying to a Sandbox.

### 3. Deploy metadata
sf project deploy start -o cloudsquare-app

### 4. Run tests (optional)
sf apex run test -o cloudsquare-app -r human

### 5. Post-deployment Configuration

#### Experience Cloud
- Create an Experience Cloud site
- Publish the site
- Add the applicationForm LWC to a public page

#### Salesforce Site (for REST Webhook)
- Create a Salesforce Site
- Enable guest user access

#### Site Guest User – Required Permissions

Apex Class Access:
- ApplicationFormController
- ApplicationProcessingService
- ApplicationWebhookController

Object Permissions:
- Account: Read
- Lead: Create
- Opportunity: Create

Field-Level Security:
- Federal_Tax_Id__c
- Application_Source__c
- AnnualRevenue


## 📄 Part A – Public Application Form (Experience Cloud)

### LWC
- Name: `applicationForm`
- Deployed on a public Experience Cloud page
- Collects:
  - Company Name
  - Federal Tax ID
  - Contact First Name
  - Contact Last Name
  - Email
  - Phone
  - Annual Revenue (optional)

### Features
- Client-side validation
- Loading state
- Success and error messages
- Displays:
  - Created record type (Lead or Opportunity)
  - Record Id

### Experience Cloud URL
https://thovirs-dev-ed.my.site.com/

---

## 📄 Part B – Public Webhook (Apex REST)

### Endpoint
POST https://thovirs-dev-ed.my.salesforce-sites.com/services/apexrest/external/applications

### Expected JSON Payload
{
  "companyName": "Acme Corp",
  "federalTaxId": "BG123456789",
  "contact": {
    "firstName": "Ivan",
    "lastName": "Ivanov",
    "email": "ivan@example.com",
    "phone": "+359888123456"
  },
  "annualRevenue": 500000
}

### Response (Success)
{
  "success": true,
  "recordType": "Opportunity",
  "recordId": "006XXXXXXXXXXXX",
  "message": "Application processed successfully"
}

### Response (Error)
{
  "success": false,
  "message": "<error message>"
}

---
## 🧠 Shared Business Logic – ApplicationProcessingService

The ApplicationProcessingService centralizes all business rules and is reused by both the Experience Cloud form and the REST webhook.

### Rules
- If an Account exists with a matching Federal_Tax_Id__c → create an Opportunity
- If no Tax ID match but Account Name matches → create an Opportunity
- If no Account match → create a Lead
- Application_Source__c is populated based on the input source:
  - Community (Experience Cloud)
  - Webhook (REST API)

---

## 🔐 Security & Setup Notes

### Salesforce Site
- Public REST access is exposed via a Force.com Site
- Guest User permissions are required

---

## 🧪 Testing

Test Class:
- ApplicationProcessingServiceTest

Covered Scenarios:
1. Lead creation when no Account matches
2. Opportunity creation via Tax ID match
3. Opportunity creation via Name match when Tax ID is blank
4. Correct handling of Application_Source__c (Webhook vs Community)

Coverage:
- 100% coverage for ApplicationProcessingService
- No tests required for LWC (as per requirements)

---

## 📦 Deliverables

Apex:
- ApplicationFormController
- ApplicationWebhookController
- ApplicationProcessingService
- DTO and wrapper classes
- Test class(es)

LWC:
- applicationForm.html
- applicationForm.js
- applicationForm.js-meta.xml

Documentation:
- README with setup instructions, usage and assumptions

---

## 📝 Assumptions

- UI form reset after submission was intentionally not implemented to simplify testing.
- Application_Source__c is always explicitly provided by the caller (no default values are enforced).
- Minimal server-side validation is performed, assuming client-side validation is already in place.

---

## ✅ Conclusion

This implementation demonstrates:
- Public Experience Cloud development
- Apex REST APIs
- DTO-based architecture
- Shared business services
- Secure guest access configuration
- Clean, testable Apex design
