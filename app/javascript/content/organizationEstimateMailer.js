export default class OrganizationEstimateMailer {
  constructor(organization, estimate) {
    this.organization = organization;
    this.estimate = estimate;
  }

  quoteContent(baseContent = "", extraContent = {}) {
    let content = baseContent
    if(extraContent.afterList != null) {
      content = content.replace("[ADDITIONAL_CONTENT_SLOT]", `${extraContent.afterList}\n\n`);
    }
    else{
      content = content.replace("[ADDITIONAL_CONTENT_SLOT]", "");
    }

    return this.replaceContentSlots(content)
  }

  invoiceContent(baseContent="") {
    return this.replaceContentSlots(baseContent)
  }

  defaultContent(baseContent="") {
    return this.replaceContentSlots(baseContent)
  }

  receiptContent(baseContent="") {
    let content = baseContent;
    content = this.replaceGreeting(content);
    content = this.replaceSignature(content);
  
    return content
  }

  replaceContentSlots(content) {
    return content
      .replace('[FIRST_NAME]', this.estimateFirstName())
      .replace('[SIGNATURE]', this.organization.email_signature);
  }

  estimateFirstName() {
    if(this.estimate.customer_detail.name != null) {
      var name = this.estimate.customer_detail.name.split(" ")[0];
      name = name.charAt(0).toUpperCase() + name.slice(1);
      return name;
    }
    return
  }

  replaceGreeting(content) {
    var newContent = content;

    if(this.estimate.customer_detail.name != null) {
      var name = this.estimate.customer_detail.name.split(" ")[0];
      name = name.charAt(0).toUpperCase() + name.slice(1);
      newContent = newContent.replace('[FIRST_NAME]', `${name}`);
    }

    return newContent;
  }

  replaceSignature(content) {
    return content.replace('[SIGNATURE]', this.organization.email_signature);
  }
}
