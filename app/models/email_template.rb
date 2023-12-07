class EmailTemplate < ActiveRecord::Base
  belongs_to :organization

  KEYS = {
    quote_mailout: 'quote_mailout'
  }

  def parsed_subject
    self.subject.gsub("[ORGANIZATION_NAME]", self.organization.name)
  end
end
