function invoiceContent(estimate) {
  var content = "Hi, \n\n\
Your tree work is complete. Thank you very much for your business. \n\n\
Attached is your final invoice. We accept all forms of payment, but prefer e-transfers or cheques. Credit card payments over the phone also work, but we do lose a percentage of the sale.\n\n\
E-transfers can be sent to tbrewer@bigislandgroup.ca\n\n\
Cheques can be made out to Big Tree Inc. Arrangements can be made for pickup.\n\n\
Call me anytime on my cell at 705 943 7374 for card payments or if you have any questions.\n\n\
Thanks, \n\
Tyler Brewer\n\
Certified Utility Arborist"

  content = replaceGreeting(content, estimate);

  return content;
}

function quoteContent(estimate, signature, extraContent = {}) {

let content = "\
Hi, \n\n\
Your quote is attached with our firm price and all of our company information, including our insurance and certificate numbers. If you'd like to go ahead with the job, don't worry about signing the document, simply confirm you'd like to go ahead with the work by replying to this email.\n\n\
"

content = replaceGreeting(content, estimate);

if(extraContent.afterList != null) {
  content += `${extraContent.afterList}\n\n`
}

content += "We do our best to maintain a reliable schedule for our customers and employees. As such, we ask that if you would like us to do any work above and beyond what we've quoted, please notify us before we schedule your work.\n\n\
If you have any questions, you can call us toll free at 1 877 542 5551 or directly on my cell by calling or texting 705 943 7374. If I don't answer, I am probably up a tree but I will return your message as soon as I have a moment.\n\n\
Thanks,\n\n\
"

content += `${signature}`

return content
}

function replaceGreeting(content, estimate) {
  var newContent = content;

  if(estimate.customer_detail.name != null) {
    var name = estimate.customer_detail.name.split(" ")[0];
    name = name.charAt(0).toUpperCase() + name.slice(1);
    newContent = newContent.replace('Hi,', `Hi ${name},`);
  }

  return newContent;
}

var reducedCosts = "We will reduce the cost by 7% if we receive approval within 24 hours. Further, we guarantee completion within 10 business days.";
var nextFewDays = "We could take care of your job as early as the next few days.";
var nextWeek = "We could take care of your job within the following week.";
var nextTwoWeeks = "We could take care of your job within the following two weeks.";
var moreThanTwoWeeks = "Due to a large number of active jobs, we could only schedule your job after a wait of two weeks.";

function receiptContent(estimate) {
  var content = 'Hi, \n\n\
Your payment has been received. Here is your receipt.\n\n\
Thank you so much for the business. Give us a call anytime!\n\n\
Tyler Brewer\n\
Certified Utility Arborist'

  content = replaceGreeting(content, estimate);

  return content;
}

function noResponseFollowup(estimate){
  var content = "Hi, \n\n\
I didn't hear back from you regarding the tree work so I figured I would follow up just in case. Please feel free to email me or call me anytime if you have any questions. My cell is 705 943 7374 or you can reach me toll free at 1 877 542 5551. \n\n\
If you have any concerns about the timing or price of your job, I would be more than happy to discuss them with you. \n\n\
Once again, thanks for your time and consideration. \n\n\
Have a great day. \n\n\
Tyler Brewer \n\
Certified Utility Arborist"

  content = replaceGreeting(content, estimate);

  return content
}

function imageRequest(estimate) {
  var content = "Hi,\n\n\
I have reviewed your job request, and it definitely sounds like something we can take care of. However, I need a bit more information before I can provide a firm quote.\n\n\
We have two options... \n\n\
1.You can text or email me a picture of the tree(s) or stump(s) that need the work and I will respond asap with a quote. \n\n\
OR \n\n\
2. We can schedule a meeting to go over the work together. It's our busy season, so evenings are usually best.\n\n\
Feel free to call/text me on my cell at 705 943 7374 or call me toll free at 1 877 542 5551. We have arborists across the GTA that can make sure we expedite this quote for you.\n\n\
Thanks, \n\
Tyler \n\
Certified Utility Arborist"

  content = replaceGreeting(content, estimate);

  return content;
}

var repairRequest="Hi,\n\n\
Have a look at this repair request.\n\n\n\
"

export {
  invoiceContent,
  quoteContent,
  receiptContent,
  noResponseFollowup,
  imageRequest,
  repairRequest,
  reducedCosts,
  nextFewDays,
  nextWeek,
  nextTwoWeeks,
  moreThanTwoWeeks
}
