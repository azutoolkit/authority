# Role-Based Access Control Service
# Provides authorization checks for admin functionality.
# Uses hybrid check: role='admin' OR scope contains 'authority:admin'
module Authority
  module RBACService
    ADMIN_ROLE  = "admin"
    ADMIN_SCOPE = "authority:admin"

    # Check if user has admin privileges
    # Returns true if user.role == 'admin' OR user.scope contains 'authority:admin'
    def self.admin?(user : User) : Bool
      return false if user.locked?

      user.role == ADMIN_ROLE || has_scope?(user, ADMIN_SCOPE)
    end

    # Check if user has a specific scope
    def self.has_scope?(user : User, scope : String) : Bool
      scopes = user.scope.split(/[\s,]+/).reject(&.empty?)
      scopes.includes?(scope)
    end

    # Check if admin can manage target user
    # Admins cannot manage themselves (prevents self-lock/delete)
    def self.can_manage_user?(admin : User, target : User) : Bool
      return false unless admin?(admin)
      return false if admin.id == target.id # Cannot manage self

      # Super admins (with authority:super_admin scope) can manage other admins
      # Regular admins can only manage non-admin users
      if admin?(target)
        has_scope?(admin, "authority:super_admin")
      else
        true
      end
    end

    # Check if user can access admin dashboard
    def self.can_access_admin?(user : User) : Bool
      admin?(user)
    end

    # Check if user can manage clients
    def self.can_manage_clients?(user : User) : Bool
      admin?(user)
    end

    # Check if user can manage scopes
    def self.can_manage_scopes?(user : User) : Bool
      admin?(user)
    end

    # Check if user can view audit logs
    def self.can_view_audit_logs?(user : User) : Bool
      admin?(user)
    end
  end
end
