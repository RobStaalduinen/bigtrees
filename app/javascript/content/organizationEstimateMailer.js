import { expandBody, expandSubject } from './emailMacros.js';

// Binds the macro table to one organization and estimate, so a send form can expand a template's
// subject and body against the email it is about to send. The macros themselves live in
// content/emailMacros.js.
export default class OrganizationEstimateMailer {
  constructor(organization, estimate) {
    this.organization = organization;
    this.estimate = estimate;
  }

  defaultContent(baseContent = "") {
    return expandBody(baseContent, this.context());
  }

  parsedSubject(baseSubject = "") {
    return expandSubject(baseSubject, this.context());
  }

  context() {
    return { organization: this.organization, estimate: this.estimate };
  }
}
