require File.dirname(__FILE__) + '/../../test_helper'
require 'survey/surveys_helper'

class Survey::SurveysHelperTest < Test::Unit::TestCase
  
  include Survey::SurveysHelper

  def setup
#    @controller = Survey::SurveysHelperController.new
#    @request    = ActionController::TestRequest.new
#    @response   = ActionController::TestResponse.new
    @user = create_user(:login => 'user')
    @survey = create_survey
  end

  def test_role_id
    role = create_role
    #FIXME Change @user.id and role.id to @user and role
    @survey.add_member(@user.id, role.id)
    @survey.reload; @user.reload
    assert_equal @survey.role_assignments.last.role_id, role_id(@user, @survey)

    user2 = create_user; survey2 = create_survey(:title => 'title2')
    survey2.add_member(user2.id, role.id)
    survey2.reload; user2.reload
    assert !role_id(user2, @survey)
  end
end
