export default class OrganizationEstimateMailer {
  constructor(organization, estimate) {
    this.organization = organization;
    this.estimate = estimate;
  }

  quoteContent(baseContent = "", extraContent = {}) {
    let content = baseContent
    content = this.replaceGreeting(content);
    if(extraContent.afterList != null) {
      content = content.replace("[ADDITIONAL_CONTENT_SLOT]", `${extraContent.afterList}\n\n`);
    }
    else{
      content = content.replace("[ADDITIONAL_CONTENT_SLOT]", "");
    }

    content += `${this.organization.email_signature}`

    return content
  }

  invoiceContent(baseContent="") {
    let content = baseContent;
    content = this.replaceGreeting(content);
    content += `${this.organization.email_signature}`

    return content
  }

  defaultContent(baseContent="") {
    let content = baseContent;
    content = this.replaceGreeting(content);
    content += `${this.organization.email_signature}`

    return content
  }

  receiptContent(baseContent="") {
    let content = baseContent;
    content = this.replaceGreeting(content);
    content += `${this.organization.email_signature}`

    return content
  }

  replaceGreeting(content) {
    var newContent = content;

    if(this.estimate.customer_detail.name != null) {
      var name = this.estimate.customer_detail.name.split(" ")[0];
      name = name.charAt(0).toUpperCase() + name.slice(1);
      newContent = newContent.replace('Hi,', `Hi ${name},`);
    }

    return newContent;
  }
}
