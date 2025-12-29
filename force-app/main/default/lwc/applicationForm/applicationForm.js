import { LightningElement } from 'lwc';

export default class PublicApplicationForm extends LightningElement {
  firstName = '';
  lastName = '';

  handleFirstName(event) {
    this.firstName = event.target.value;
  }

  handleLastName(event) {
    this.lastName = event.target.value;
  }

  handleSubmit() {
    console.log('Submit clicked', { firstName: this.firstName, lastName: this.lastName });
  }
}
