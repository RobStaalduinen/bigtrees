class Arborist < ActiveRecord::Base
  DEFAULT_ID = 2

  has_secure_password

  devise :recoverable

  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships

  has_many :estimates
  has_many :receipts
  has_many :work_records
  has_many :documents
  has_many :equipment_requests

  before_create :set_session_token

  def after_database_authentication
    redirect_to('/login')
  end

  def serialized
    slice(:id, :name)
  end

  def has_memberships?
    organization_memberships.any?
  end

  def set_session_token
    self.session_token = SecureRandom.hex
  end

  def get_receipts
    self.admin ? Receipt.all : self.receipts
  end

  def current_membership
    organization_memberships.find_by(organization_id: OrganizationContext.current_organization.id)
  end

  def current_hourly_rate
    current_membership.hourly_rate
  end

  def recent_work
    {
      this_month: self.work_records.for_month(Date.today),
      last_month: self.work_records.for_month(Date.today - 1.month)
    }
  end

  def role_permissions
    Roles.for_name(self.role)
  end

  def generate_initial_password
    return nil unless password.blank?

    new_password = SecureRandom.hex(6)

    self.update(
      password: new_password,
      password_confirmation: new_password
    )

    new_password
  end

  scope :real, -> { where.not(hidden: true) }
  scope :active, -> { where(active: true) }

  validates :name, presence: true
end
