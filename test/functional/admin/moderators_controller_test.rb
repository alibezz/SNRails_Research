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
    @environment = Environment.create(:is_default => true)
    Environment.expects(:default).returns(@environment)
    login_as :quentin
    @research = create_research
  end

#index

  def test_should_get_index
    get :index, :research_id => @research.id
    assert_response :success
    assert_template 'index'
    assert assigns(:users)
  end

  def test_index_should_show_link_to_update_moderators
    get :index, :research_id => @research.id
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
    assert_tag :tag => 'a', :attributes => { :href => new_admin_research_moderator_url(@research.id) }
  end
    
  def test_should_get_only_moderators_on_index

    # This user is not a moderator
    user1 = create_user(:login => 'user1')

    # adding moderators users
    user2 = create_user(:login => 'user2')
    user3 = create_user(:login => 'user3')
    @research.moderator_permissions.create(:user => user2)
    @research.moderator_permissions.create(:user => user3)

    get :index, :research_id => @research.id
    assert_response :success
    assert assigns(:users)
    assert_equal 2, assigns(:users).length, "There are 2 moderatores on this research"
  end

#new

  def test_should_get_new
    get :new, :research_id => @research.id
    assert_response :success
    assert_template 'new'
  end

  def test_new_should_have_form
    get :new, :research_id => @research.id
    assert_tag :tag => 'form', :attributes => { :method => 'post' }    
  end

  def test_new_should_show_all_users
    get :new, :research_id => @research.id
    assert_response :success
    assert assigns(:gusers)
    assert_equal User.count, assigns(:gusers).count
  end

#update

  def test_should_update_moderators_properly
    user1 = create_user(:login => 'user1')
    user2 = create_user(:login => 'user2')
    
    assert_equal 0, @research.moderator_permissions.count
    post :update, :moderator_ids => [user1.id.to_s, user2.id.to_s], :research_id => @research.id
    assert_response :redirect
    assert_redirected_to :action => "index" 
  
    @research.reload 
    assert_equal 2, @research.moderator_permissions.length
  end
end
