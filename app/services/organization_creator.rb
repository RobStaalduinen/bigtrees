# frozen_string_literal: true

class OrganizationCreator
  def set_contact_information(name, short_name, email, phone_number, website)
    organization.update(name: name, short_name: short_name, email: email, phone_number: phone_number, website: website)
  end

  def set_quote_info(email_author, email_signature, outgoing_quote_email)
    organization.update(email_author: email_author, email_signature: email_signature, outgoing_quote_email: outgoing_quote_email)
  end

  def set_corporate_info(insurance_provider, insurance_policy_number, insurance_description, hst_number)
    organization.update(insurance_provider: insurance_provider, insurance_policy_number: insurance_policy_number, insurance_description: insurance_description, hst_number: hst_number)
  end

  def set_design_info(logo_url, primary_colour)
    organization.update(logo_url: logo_url, primary_colour: primary_colour)
  end

  def set_address_info(street, city, postal_code)
    Address.create(addressable: organization, street: street, city: city, postal_code: postal_code)
  end

  def set_primary_arborist(email, phone_number, name, password)
    Arborist.create(email: email, phone_number: phone_number, name: name, role: 'admin', password: password, password_confirmation: password).tap do |arborist|
      OrganizationMembership.create(arborist: arborist, organization: organization)
    end
  end

  def seed_email_templates
    EmailTemplateCreator.new(organization).seed_email_templates
  end

  private

  def organization
    @organization ||= Organization.new
  end
end
