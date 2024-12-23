class ApplicationPolicy
  attr_reader :user, :record

  def self.role_resource(resource)
    @resource = resource
  end

  def self.resource
    @resource
  end

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    permission_key?('list')
  end

  def show?
    permission_key?('show')
  end

  def new?
    create?
  end

  def create?
    permission_key?('create')
  end

  def edit?
    update?
  end

  def update?
    permission_key?('update')
  end

  def destroy?
    permission_key?('destroy') || permission_key?('delete')
  end

  def admin?
    permission_key?('admin')
  end

  def permission_key?(key)
    role.dig(self.class.resource.to_s, key)&.to_s&.downcase == 'true'
  end

  def role
    @role ||= Roles.for_name(user.role)
  end

  class Scope
    attr_reader :user, :scope, :role

    def self.role_resource(resource)
      @resource = resource
    end

    def self.resource
      @resource
    end

    def initialize(user, scope)
      @user = user
      @role = Roles.for_name(user.role)
      @scope = scope
    end

    def resolve
      if level == 'organization'
        scope.where(arborist: user.organization.arborists)
      else
        scope.where(arborist: user)
      end
    end

    def level
      @level ||= role.dig(self.class.resource.to_s, 'scope_level') || 'self'
    end
  end
end
