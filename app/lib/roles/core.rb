module Roles
  class Core
    def permission_set(list: false, show: false, create: false, update: false, delete: false, admin: false, scope_level: 'self', extras: {})
      {
        list: list,
        show: show,
        create: create,
        update: update,
        delete: delete,
        admin: admin,
        scope_level: scope_level
      }.merge(extras)
    end
  end
end
