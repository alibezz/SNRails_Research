require File.dirname(__FILE__) + '/../../test_helper'
require 'survey/surveys_controller'

# Re-raise errors caught by the controller.
class Survey::SurveysController; def rescue_action(e) raise e end; end

class Survey::SurveysControllerTest < ActionController::TestCase

#  fixtures :users

  def setup
    @environment = create_environment(:is_default => true)
    @role = create_role(:name => 'Moderator', :permissions => ActiveRecord::Base::PERMISSIONS['survey'].keys)
    @user = create_user(:login => "Susan")
    login_as(@user.login)
  end

  def test_should_get_index
    env = create_environment(:is_default => true)
    get :index
    assert_response :success
    assert assigns(:surveys)
  end

  def test_should_edit_survey
    r = create_survey
    @user.add_role(@role, r)
    get :edit, :id => r.id
    assert_response :success
    assert_tag :tag => "ul", :attributes => {:id => "survey_menu" }
  end

  def test_should_change_fields
    survey = create_survey
    @user.add_role(@role, survey)
    post :update, :id => survey.id, :survey => {:title => 'new title', :introduction => 'new introduction', :subtitle => 'new subtitle'}
    survey.reload
    assert_equal 'new subtitle', survey.subtitle
    assert_equal 'new title', survey.title
    assert_equal 'new introduction', survey.introduction
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(survey)
  end

  def test_should_show_new
    get :new
    assert_response :success
  end

  def test_new_should_have_form
    get :new
    assert_tag :tag => 'form', :attributes => { :method => 'post' } 
  end

  def test_should_create_survey
    Survey.destroy_all
    post :create, :survey => {:title => 'new title', :introduction => 'new introduction', :subtitle => 'new subtitle'}
    assert_equal 1, Survey.count

    assert_equal Survey.first.role_assignments.first.accessor_id, @user.id
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(Survey.last)

    post :create, :survey => {:title => nil, :introduction => 'new introduction', :subtitle => 'new subtitle'}
    assert_equal 1, Survey.count
  end

#role management
  def test_should_get_role_management
    r = create_survey
    @user.add_role(@role, r)
    get :role_management, :id => r.id
    assert_response :success
    assert assigns(:members)
    assert assigns(:non_members)
    assert_tag :tag => "ul", :attributes => {:id => "survey_menu" }
  end

  def test_should_define_new_member
    r = create_survey
    @user.add_role(@role, r)
    user2 = create_user

    count = @role.role_assignments.count
    put :new_member, :role => {:id => @role.id}, :id => r.id, :user => {:id => user2.id}
    r.reload
    assert_nil flash[:error]
    assert_equal r.role_assignments.count, count + 1
    assert_response :redirect
    assert_redirected_to role_management_survey_survey_path(r)

    put :new_member, :role => {:id => nil}, :id => r.id, :user => {:id => user2.id}
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to role_management_survey_survey_path(r)
  end

  def test_should_edit_member
    r = create_survey
    role2 = create_role(:name => "Collaborator", :permissions => ['survey_viewing'])
    @user.add_role(@role, r); @user.reload; r.reload

    put :edit_member, :role => {:id => role2.id}, :id => r.id, :user_id => @user.id 
    @user.reload
    
    assert_equal @user.role_assignments.count, 1
    assert_equal @user.role_assignments[0].role_id, role2.id
    assert_response :redirect
    assert_redirected_to role_management_survey_survey_path(r)

    put :edit_member, :role => {:id => nil}, :id => r.id, :user_id => @user.id 
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to role_management_survey_survey_path(r)
  end

  def test_should_remove_member
    r = create_survey
    @user.add_role(@role, r)
    @user.reload; r.reload
    count = r.role_assignments.count
    count_user = @user.role_assignments.count
    assert_equal count_user + 1, count

    put :remove_member, :id => r.id, :user_id => @user.id

    assert_equal count - 1, r.role_assignments.count
    assert_equal count_user - 1, @user.role_assignments.count
    assert_response :redirect
    assert_redirected_to role_management_survey_survey_path(r)

    put :remove_member, :id => r.id, :user_id => nil
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to role_management_survey_survey_path(r)
  end

  def test_should_activate_survey
    s = create_survey
    i = create_item(:survey_id => s.id, :type => "question")
    s.save; s.reload

    get :activate, :id => s.id; s.reload
    assert_equal s.is_active, true
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(s)

    get :activate, :id => s.id; s.reload
    assert_equal s.is_active, false
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(s)
  
    s2 = create_survey(:title => 'title2')
    get :activate, :id => s2.id; s2.reload
    assert !flash[:notice].blank?
  end


  #charts
  def test_charts_default_from
    s = create_survey
    get :charts, :id => s.id
    assert_kind_of String, assigns(:from)
  end

  def test_charts_default_to
    s = create_survey
    get :charts, :id => s.id
    assert_kind_of String, assigns(:to)
  end

  def test_charts_return_js
    s = create_survey
    get :charts, :format => "js", :id => s.id
    assert_response :success
  end

  def test_charts_return_json
    s = create_survey
    get :charts, :format => "json", :id => s.id
    assert_response :success
    assert_equal 'application/json; charset=utf-8', @response.headers['type']
  end
  
  def test_charts_return_html
    s = create_survey
    get :charts, :format => "html", :id => s.id
    assert_response :success
  end
  
end
