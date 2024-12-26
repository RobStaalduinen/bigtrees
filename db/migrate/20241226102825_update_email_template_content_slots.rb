class UpdateEmailTemplateContentSlots < ActiveRecord::Migration[6.0]
  def self.up
    EmailTemplate.all.each do |template|
      new_content = template.content

      new_content = new_content.gsub("Hi,", "Hi [FIRST_NAME],")
      new_content = new_content.gsub("Thanks,\n", "Thanks,\n[SIGNATURE]")

      template.update(content: new_content)
    end
  end

  def self.down
    EmailTemplate.all.each do |template|
      new_content = template.content

      new_content = new_content.gsub("Hi [FIRST_NAME],", "Hi,")
      new_content = new_content.gsub("Thanks,\n[SIGNATURE]", "Thanks,\n")

      template.update(content: new_content)
    end
  end
end
