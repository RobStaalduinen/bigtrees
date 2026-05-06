# == Schema Information
#
# Table name: email_records
#
#  id                :bigint           not null, primary key
#  estimate_id       :bigint           not null
#  arborist_id       :bigint
#  organization_id   :bigint
#  template_key      :string           not null
#  recipient_email   :string
#  nylas_message_id  :string
#  sent_at           :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class EmailRecord < ActiveRecord::Base
  belongs_to :estimate
  belongs_to :arborist, optional: true
  belongs_to :organization, optional: true

  validates :template_key, presence: true
  validates :sent_at, presence: true
end
