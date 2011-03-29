require File.dirname(__FILE__) + '/../test_helper'
require 'application_helper'

# Re-raise errors caught by the controller. 
class ApplicationHelperTestController <  ApplicationController

  def title
    render :inline => '<%= title("some title") %>'
  end

  def subtitle
    render :inline => '<%= subtitle("some subtitle") %>'
  end

  def survey_buttons
    render :inline => "<%= survey_buttons(#{Survey.first.id}) %>"
  end

  def login_bar
    render :inline => "<%= login_bar %>"
  end

  def select_type
    render :inline => "<%= select_type %>"
  end

  def admin_bar
    render :inline => "<%= admin_bar %>"
  end
end 

class ApplicationHelperTestController; def rescue_action(e) raise e end; end

class ApplicationHelperTest < Test::Unit::TestCase

  def setup
    @controller = ApplicationHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @admin = create_user(:administrator => true)
    @user = create_user(:login => 'user')
  end

  def test_title
    get :title
    assert_tag :tag => 'h1', :content => 'some title', :attributes => {:class => 'title'}
  end

  def test_subtitle
    get :subtitle
    assert_tag :tag => 'h2', :content => 'some subtitle', :attributes => {:class => 'subtitle'}
  end

  def test_survey_buttons_to_admin
    survey = create_survey
    login_as @admin.login

    get :survey_buttons
    assert_tag :tag => 'a', :attributes => {:href => edit_survey_survey_url(survey.id)}
  end

  def test_survey_buttons_to_collaborator 
    Survey.destroy_all
    survey = create_survey
    role = create_role(:name => "Collaborator", :permissions => ['survey_viewing'])
    @user.add_role(role, survey); @user.reload; survey.reload
   
    login_as @user.login
    get :survey_buttons
    assert_no_tag :tag => 'a', :attributes => {:href => edit_survey_survey_url(survey.id)}
  end

  def test_login_bar
    get :login_bar
    assert_tag :tag => 'ul', :attributes => { :class => "login_bar", :id => "login_bar"}
   
    assert_tag :tag => 'ul', :descendant => {:tag => 'li', :child => {:tag => 'a', :attributes => {:href => "/login"}}}
    assert_no_tag :tag => 'ul', :descendant => {:tag => 'li', :child => {:tag => 'a', :attributes => {:href => "/logout"}}}
    assert_tag :tag => 'ul', :descendant => {:tag => 'li', :child => {:tag => 'a', :attributes => {:href => "/signup"}}}
 
    login_as @admin.login
    get :login_bar
    
    assert_no_tag :tag => 'ul', :descendant => {:tag => 'li', :child => {:tag => 'a', :attributes => {:href => "/login"}}}
    assert_tag :tag => 'ul', :descendant => {:tag => 'li', :child => {:tag => 'a', :attributes => {:href => "/logout"}}}
    assert_no_tag :tag => 'ul', :descendant => {:tag => 'li', :child => {:tag => 'a', :attributes => {:href => "/signup"}}}
  end

  def test_select_type
    get :select_type
    assert_tag :tag => 'select'
  end

  def test_admin_bar
    get :admin_bar
    assert :tag => 'ul', :attributes => {:class => "admin_bar", :id => "admin_bar"}
   
    assert_tag :tag => 'ul', :descendant => {:tag => 'li',                                                                                  :child => {:tag => 'a', :attributes => {:href => "/admin/roles"}}} 
  end
end
