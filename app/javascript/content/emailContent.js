var invoiceContent = 'Hi, \n\n\
The tree work is complete. Thank you very much for your business. \n\n\
Attached is your final invoice. We accept all forms of payment but prefer e-transfers or cheques. Credit card payments over the phone work as well but we do lose a percentage of the sale.\n\n\
E-transfers can be sent to tbrewer@bigislandgroup.ca\n\n\
Cheques can be made out to Big Tree Inc. and arrangements can be made for pickup.\n\n\
Call me anytime on my cell at 705 943 7374 for card payments or if you have any questions.\n\n\
Thanks, \n\
Tyler\n\
Certified Utility Arborist\n\
43 Farmington Dr.\n\
Brampton, Ontario\n\
L6W 2V4';

function quoteContent(extraContent = {}) {

let content = "\
Hi, \n\n\
Your quote is attached with a firm price and all of our company information including our insurance and certificate numbers. If you'd like to go ahead with the job, don't worry about signing the document, simply confirm you'd like to go ahead with the work by replying to this email.\n\n\
From Start to Finish the steps are as follows:\n\
a) Approve the work by replying to this email and/or signing the quote and returning it to us.\n\
b) Schedule a day for the work to be done\n\
c) Complete all the work listed on the quote\n\
d) Clean your property of any wood, branches and debris (Included in the price)\n\
e) Payment and invoice are exchanged once the job is complete\n\n\
"

if(extraContent.afterList != null) {
  content += `${extraContent.afterList}\n\n`
}

content += "We accept all forms of payment including: cheque, cash, e-transfer and debit/credit (debit/credit add 3% for machine costs).\n\n\
We do our best to maintain a reliable schedule for our customers and employees. As such, we ask that if you would like us to do any work above and beyond what we've quoted, please notify us before we schedule your work.\n\n\
If you have any questions, you can call us toll free at 1 877 542 5551. You can also reach me directly on my cell by either calling or texting 705 943 7374. If I don't answer, I am probably up a tree but I will return your message as soon as I have a moment.\n\n\
Thanks,\n\n\
Tyler Brewer\n\
Certified Utility Arborist\
"

return content
}

var nextFewDays = "We could take care of your job as early as the next few days.";
var nextWeek = "We could take care of your job within the following week.";
var nextTwoWeeks = "We could take care of your job within the following two weeks.";
var moreThanTwoWeeks = "Due to a large number of active jobs, we could only schedule your job after a wait of two weeks.";

var receiptContent='Hi, \n\n\
Your payment has been received. Here is your receipt.\n\n\
Thank you so much for the business. Give us a call anytime!\n\n\
Tyler Brewer\n\
Certified Utility Arborist'

var noResponseFollowup="Hi, \n\n\
I didn't hear back from you regarding the tree work so I figured I would follow up just in case. Please feel free to email me or call me anytime if you have any questions. My cell is 705 943 7374 or you can reach me toll free at 1 877 542 5551. \n\n\
If you are interested, there are a couple ways to save some money. First is a another discount ($25) for leaving a 5 star review online. Third is a 5% discount if you schedule the work to be completed in the winter. \n\n\
Once again, thanks for your time and consideration. \n\n\
Have a great day. \n\n\
Tyler Brewer \n\
Certified Utility Arborist"

var imageRequest="Hi,\n\n\
I can definitely take care of that for you.\n\n\
We have two options... \n\n\
1.You can text or email me a picture of the tree(s) or stump(s) that need the work and I will respond asap with a quote. \n\n\
 OR \n\
2. We can schedule a meeting to go over the work together. It's our busy season, so evenings are usually best.\n\n\
Feel free to call/text me on my cell at 705 943 7374 or call me toll free at 1 877 542 5551. We have arborists across the GTA that can make sure we expedite this quote for you.\n\n\
Thanks, \n\
Tyler \n\
Certified Arborist and Utility Arborist"

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
  nextFewDays,
  nextWeek,
  nextTwoWeeks,
  moreThanTwoWeeks
}
