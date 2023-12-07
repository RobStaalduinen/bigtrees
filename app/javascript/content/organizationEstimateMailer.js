export default class OrganizationEstimateMailer {
  constructor(organization, estimate) {
    this.organization = organization;
    this.estimate = estimate;
  }

  quoteContent(baseContent = "", extraContent = {}) {
//     let content = "\
// Hi, \n\n\
// Your quote is attached with our firm price and all of our company information, including our insurance and certificate numbers. If you'd like to go ahead with the job, don't worry about signing the document, simply confirm you'd like to go ahead with the work by replying to this email.\n\n\
// "

//     content = this.replaceGreeting(content);

//     if(extraContent.afterList != null) {
//       content += `${extraContent.afterList}\n\n`
//     }

//     content += "We do our best to maintain a reliable schedule for our customers and employees. As such, we ask that if you would like us to do any work above and beyond what we've quoted, please notify us before we schedule your work.\n\n\
// If you have any questions, you can call us toll free at 1 877 542 5551 or directly on my cell by calling or texting 705 943 7374. If I don't answer, I am probably up a tree but I will return your message as soon as I have a moment.\n\n\
// Thanks,\n\n\
// "

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
