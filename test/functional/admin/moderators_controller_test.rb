require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/moderators_controller'

# Re-raise errors caught by the controller.
class Admin::ModeratorsController; def rescue_action(e) raise e end; end

class ModeratorsControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = Admin::ModeratorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    env = Environment.new
    Environment.expects(:default).returns(env)
    login_as :quentin
  end

  def test_should_get_index
    r = create_research
    get :index, :research_id => r.id
    assert_response :success
    assert_template 'index'
    assert assigns(:users)
  end

  def test_should_not_get_all_users_on_index
    user1 = create_user(:login => 'user1')
    r = create_research

    # The user added is not a moderator
    r.users<< user1
   
    get :index, :research_id => r.id
    assert_response :success
    assert assigns(:users)
    assert_equal 1, r.users.count
    assert_equal 0, assigns(:users).length, "The user added is not a moderator"
  end
    
  def test_should_get_only_moderators_on_index
    r = create_research

    user1 = create_user(:login => 'user1')
    # This user is not a moderator
    r.users<< user1

    # adding moderators users
    user2 = create_user(:login => 'user2')
    user3 = create_user(:login => 'user3')
    r.moderator_permissions.create(:user => user2)
    r.moderator_permissions.create(:user => user3)

    get :index, :research_id => r.id
    assert_response :success
    assert assigns(:users)
    assert_equal 3, assigns(:research).users.count
    assert_equal 2, assigns(:users).length, "There are 2 moderatores on this research"
  end

  def test_should_get_new
    r = create_research

    get :new, :research_id => r.id
    assert_response :success
    assert_template 'new'
  end

  def test_should_post_create_successfully
    r = create_research

    post :create, :user => user_params, :research_id => r.id
    assert_response :redirect
    assert_redirected_to admin_research_moderators_url(r)
  end


end
