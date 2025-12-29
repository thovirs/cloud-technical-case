import { LightningElement } from 'lwc';
import submitApplication from '@salesforce/apex/ApplicationFormController.submitApplication';

export default class ApplicationForm extends LightningElement {
    firstName = '';
    lastName = '';
    companyName = '';
    email = '';
    phone = '';
    federalTaxId = '';
    annualRevenue = '';

    isLoading = false;
    isSuccess = false;
    message = '';



    validate() {
        const inputs = [...this.template.querySelectorAll('lightning-input')];
        return inputs.reduce((allValid, input) => {
            input.reportValidity();
            return allValid && input.checkValidity();
        }, true);
    }

    get messageClass() {
        return this.isSuccess
            ? 'slds-notify slds-notify_alert slds-alert_success'
            : 'slds-notify slds-notify_alert slds-alert_error';
    }

    async handleSubmit() {
        if (!this.validate()) {
            // eslint-disable-next-line no-console
            console.log('Form is invalid');
            return;
        }

        this.isLoading = true;
        this.isSuccess = false;
        this.message = '';
        
        const payload = {
            firstName: this.firstName,
            lastName: this.lastName,
            companyName: this.companyName,
            email: this.email,
            phone: this.phone,
            federalTaxId: this.federalTaxId,
            annualRevenue: this.annualRevenue ? Number(this.annualRevenue) : null,
            applicationSource : 'Community'
        };

        try{
            console.log('Calling Apex with', JSON.stringify(payload));
            const result = await submitApplication({ input: payload });
            console.log('Apex result', result);
            if(result.success){
                this.isSuccess = true;
                this.message = `Success! Created ${result.recordType || 'record'} ${result.recordId || ''}`.trim();
            } else {
                this.isSuccess = false;
                this.message = result?.message || 'Submission failed.';
            }
        } catch(error){
            this.isSuccess = false;
            this.message = error?.body?.message || 'An unexpected error occurred.';
        } finally {
            this.isLoading = false;
        }

    }
    

    handleFirstName(event) {
        this.firstName = event.target.value;
    }

    handleLastName(event) {
        this.lastName = event.target.value;
    }

    handleCompanyName(event) {
        this.companyName = event.target.value;
    }

    handleEmail(event) {
        this.email = event.target.value;
    }

    handlePhone(event) {
        this.phone = event.target.value;
    }

    handleFederalTaxId(event) {
        this.federalTaxId = event.target.value;
    }

    handleAnnualRevenue(event) {
        this.annualRevenue = event.target.value;
    }
}
