class Admin::RolesController < ResourceController::Base

  #before_filter :load_roles
  before_filter :load_permissions, :only => [:new, :edit]
  before_filter :create_admin_tab
  protect 'administrator', :environment
  
  def load_permissions
    @perms = ActiveRecord::Base::PERMISSIONS
  end
end
