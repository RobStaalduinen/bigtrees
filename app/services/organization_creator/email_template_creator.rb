# frozen_string_literal: true

class OrganizationCreator
  class EmailTemplateCreator
    def initialize(organization)
      @organization = organization
    end

    def seed_email_templates
      create_quote_mailout
      create_invoice_mailout
      create_receipt_mailout
      create_no_response
      create_image_request
      create_approval_mailout
    end

    private

    def create_quote_mailout
      content = "Hi [FIRST_NAME],\n\nYour quote is attached with our firm price and all of our company information, including our insurance and certificate numbers. If you'd like to go ahead with the job, don't worry about signing the document, simply confirm you'd like to go ahead with the work by replying to this email.\n\n[ADDITIONAL_CONTENT_SLOT]We do our best to maintain a reliable schedule for our customers and employees. As such, we ask that if you would like us to do any work above and beyond what we've quoted, please notify us before we schedule your work.\n\nIf you have any questions, you can call us at #{@organization.phone_number}. If I don't answer, I will return your message as soon as I have a moment.\n\nThanks,\n[SIGNATURE]\n"
      create_email_template('quote_mailout', 'Your Quote from [ORGANIZATION_NAME]', content)
    end

    def create_invoice_mailout
      content = "Hi [FIRST_NAME],\n\nYour tree work is complete. Thank you very much for your business.\n\nAttached is your final invoice. We accept all forms of payment, but prefer e-transfers or cheques. Credit card payments over the phone also work, but we do lose a percentage of the sale.\n\nE-transfers can be sent to #{@organization.email}\n\nCheques can be made out to Shadow River Tree Services. Arrangements can be made for pickup.\n\nCall me anytime at #{@organization.phone_number} for card payments or if you have any questions.\n\nThanks,\n[SIGNATURE]\n"
      create_email_template('invoice_mailout', 'Your [ORGANIZATION_NAME] Invoice', content)
    end

    def create_receipt_mailout
      content = "Hi [FIRST_NAME],\n\nYour payment has been received. Here is your receipt.\n\nThank you so much for your business. Give us a call anytime!\n\n"
      create_email_template('receipt_mailout', 'Your [ORGANIZATION_NAME] Receipt', content)
    end

    def create_no_response
      content = "Hi [FIRST_NAME],\n\nI didn't hear back from you regarding the tree work so I figured I would follow up just in case. Please feel free to email me or call me anytime if you have any questions. You can reach me at #{@organization.phone_number}. \n\nIf you have any concerns about the timing or price of your job, I would be more than happy to discuss them with you. \n\nOnce again, thanks for your time and consideration. \n\nHave a great day.\n\n"
      create_email_template('no_response', 'Your [ORGANIZATION_NAME] Job', content)
    end

    def create_image_request
      content = "Hi [FIRST_NAME],\n\nI have reviewed your job request, and it definitely sounds like something we can take care of. However, I need a bit more information before I can provide a firm quote.\n\nWe have two options... \n\n1.You can text or email me a picture of the tree(s) or stump(s) that need the work and I will respond asap with a quote.\n\nOR \n\n2. We can schedule a meeting to go over the work together. It's our busy season, so evenings are usually best.\n\nFeel free to call me at #{@organization.phone_number}.\n\nThanks,\n[SIGNATURE]\n"
      create_email_template('image_request', 'Your [ORGANIZATION_NAME] Job', content)
    end

    def create_approval_mailout
      content = "Hi [FIRST_NAME],\n\n" \
                "We're pleased to let you know that your tree service is scheduled and our plan is to complete the work within 10 business days, weather permitting. If the job requires a permit, rest assured we are working on it and you will be made aware of the progress.\n\n" \
                "Our team will monitor weather conditions throughout the week. We'll be in touch with an update 1-2 days in advance as the schedule becomes more clear. Wind, rain, sickness and equipment delays factor in to every day - please be patient with us as we navigate our schedule as efficiently as possible.\n\n" \
                "No action is required on your part at this time.\n\n" \
                "Thank you, and we look forward to working with you!\n\n" \
                "Best regards,\n[SIGNATURE]\n"
      create_email_template('approval_mailout', 'Your [ORGANIZATION_NAME] Job', content)
    end

    def create_email_template(key, subject, content)
      @organization.email_templates.find_or_create_by(key: key) do |t|
        t.subject = subject
        t.content = content
      end
    end
  end
end
