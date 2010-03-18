require File.dirname(__FILE__) + '/../../test_helper'
require 'survey/researches_controller'

# Re-raise errors caught by the controller.
class Survey::ResearchesController; def rescue_action(e) raise e end; end

class Survey::ResearchesControllerTest < ActionController::TestCase

  fixtures :users

  def setup
    @environment = create_environment(:is_default => true)
    login_as :quentin
  end

  def test_should_get_index
    env = create_environment(:is_default => true)
    get :index
    assert_response :success
    assert assigns(:researches)
  end

  def test_should_show_research
    r = create_research
    get :show, :id => r.id
    assert_response :success
  end

  def test_should_edit_research
    r = create_research
    get :edit, :id => r.id
    assert_response :success
  end

  def test_should_change_fields
    research = create_research
    post :update, :id => research.id, :research => {:title => 'new title', :introduction => 'new introduction', :subtitle => 'new subtitle'}
    research.reload
    assert_equal 'new subtitle', research.subtitle
    assert_equal 'new title', research.title
    assert_equal 'new introduction', research.introduction
  end

#FIXME Action moderators must be better understood 

  def test_should_show_new
    get :new
    assert_response :success
  end

  def test_new_should_have_form
    get :new
    assert_tag :tag => 'form', :attributes => { :method => 'post' } 
  end

  def test_should_create_research
    count = Research.count
    post :create, :research => {:title => 'new title', :introduction => 'new introduction', :subtitle => 'new subtitle'}
    assert_equal count + 1, Research.count
  end

#role management
  def test_should_get_role_management
    r = create_research
    get :role_management, :id => r.id
    assert_response :success
    assert assigns(:members)
    assert assigns(:non_members)
  end

  def test_should_define_new_member
    r = create_research
    user = create_user(:login => 'michael')
    role = create_role(:name => "Moderator", :permissions => ['research_editing'])
    count = r.role_assignments.count
    put :new_member, :role => {:id => role.id}, :id => r.id, :user => {:id => user.id}
    r.reload
    assert_nil flash[:error]
    assert_equal r.role_assignments.count, count + 1
    assert_response :redirect
    assert_redirected_to role_management_survey_research_path(r)

    put :new_member, :role => {:id => nil}, :id => r.id, :user => {:id => user.id}
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to role_management_survey_research_path(r)
  end

  def test_should_edit_member
    r = create_research
    user = create_user(:login => 'michael')
    role = create_role(:name => "Moderator", :permissions => ['research_editing'])
    role2 = create_role(:name => "Collaborator", :permissions => ['research_viewing'])
    user.add_role(role, r); user.reload; r.reload

    put :edit_member, :role => {:id => role2.id}, :id => r.id, :user_id => user.id 
    user.reload
    
    assert_equal user.role_assignments.count, 1
    assert_equal user.role_assignments[0].role_id, role2.id
    assert_response :redirect
    assert_redirected_to role_management_survey_research_path(r)

    put :edit_member, :role => {:id => nil}, :id => r.id, :user_id => user.id 
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to role_management_survey_research_path(r)
  end

  def test_should_remove_member
    r = create_research
    user = create_user(:login => 'michael')
    role = create_role(:name => "Moderator", :permissions => ['research_editing'])
    user.add_role(role, r); user.reload; r.reload
    
    count = r.role_assignments.count
    count_user = user.role_assignments.count
    assert_equal count_user, count

    put :remove_member, :id => r.id, :user_id => user.id

    assert_equal count - 1, r.role_assignments.count
    assert_equal count_user - 1, user.role_assignments.count
    assert_response :redirect
    assert_redirected_to role_management_survey_research_path(r)

    put :remove_member, :id => r.id, :user_id => nil
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to role_management_survey_research_path(r)
  end
end
