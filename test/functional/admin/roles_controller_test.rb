require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/roles_controller'

# Re-raise errors caught by the controller.
class Admin::RolesController; def rescue_action(e) raise e end; end

class Admin::RolesControllerTest < ActionController::TestCase

  def setup
    @user = create_user(:login => 'admin', :administrator => true)
    login_as('admin')
    @current_environment = create_environment(:is_default => true)
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should get new" do
    get :new
    assert_response :success
    assert_equal assigns(:perms).keys.count, 1 
    assert_equal assigns(:perms).keys.first, "survey"
  end
  
  test "should create new role" do
    assert_difference 'Role.count' do
      post :create, :role => { :name => "New role", :permissions => ['bar', 'foo'] }
    end
    assert_redirected_to admin_role_path(assigns(:role))
  end
  
  test "should show role" do
    r = create_role
    get :show, :id => r.id
    assert_response :success
  end
  
  test "should get edit" do
    r = create_role
    get :edit, :id => r.id
    assert_response :success
  end
  
  test "should update role" do
    r = create_role
    put :update, :id => r.id, :role => { :name => "New role", :permissions => ['bar', 'foo'] }
    assert_redirected_to admin_role_path(r)
  end
  
  test "should delete role" do
    r = create_role
    assert_difference 'Role.count', -1 do
      delete :destroy, :id => r.id
    end
    assert_redirected_to admin_roles_path
  end

  test "should load permissions" do
    get :new
    assert assigns(:perms)
    assert_equal assigns(:perms), ActiveRecord::Base::PERMISSIONS
  end
end
