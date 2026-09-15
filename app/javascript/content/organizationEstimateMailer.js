export default class OrganizationEstimateMailer {
  constructor(organization, estimate) {
    this.organization = organization;
    this.estimate = estimate;
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
    console.log("First name: ", this.estimateFirstName());
    let new_content = content
      .replace('[FIRST_NAME]', this.estimateFirstName())
      .replace('[SIGNATURE]', this.organization.email_signature)
      .replace('[TOTAL_COST]', this.estimate.total_cost)
      .replace('[TOTAL_COST_WITH_TAX]', this.estimate.total_cost_with_tax)
      // Retired in favour of the SCHEDULE_TEXT insertable; stripped in case an org template
      // still carries it.
      .replace('[ADDITIONAL_CONTENT_SLOT]', '');

    let job = this.estimate.job;
    
    if(job != null) {
      if(job.completion_notes != null) {
        let notes_content = "\nBelow is also a word from the tree workers who completed your project:\n";
        notes_content += job.completion_notes + "\n";
        new_content = new_content.replace('[ARBORIST_NOTES]', notes_content);
      }

      if(job.followup_year != null) {
        let followup_content = `\nOur team has recommend we complete a follow up site visit in ${job.followup_year}. Would you mind if we reach out to you down the road to schedule another no cost site visit?\n`;
        new_content = new_content.replace('[FOLLOWUP]', followup_content);
      }
    }

    new_content = new_content.replace('[ARBORIST_NOTES]', "").replace('[FOLLOWUP]', "");

    return new_content;
  }

  estimateFirstName() {
    if(this.estimate.customer_detail.name != null) {
      var name = this.estimate.customer_detail.name.trim().split(" ")[0];
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
