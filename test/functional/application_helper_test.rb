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
end 

class ApplicationHelperTestController; def rescue_action(e) raise e end; end

class ApplicationHelperTest < Test::Unit::TestCase

  def setup
    @controller = ApplicationHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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
    admin = create_user(:administrator => true)
    login_as admin.login

    get :survey_buttons
    assert_tag :tag => 'a', :attributes => {:href => edit_survey_survey_url(survey.id)}
  end

  def test_survey_buttons_to_collaborator 
    Survey.destroy_all
    survey = create_survey
    collab = create_user(:login => 'user')
    role = create_role(:name => "Collaborator", :permissions => ['survey_viewing'])
    collab.add_role(role, survey); collab.reload; survey.reload
   
    login_as collab.login
    get :survey_buttons
    assert_no_tag :tag => 'a', :attributes => {:href => edit_survey_survey_url(survey.id)}
  end
end
