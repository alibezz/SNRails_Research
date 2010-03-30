require File.dirname(__FILE__) + '/../test_helper'
require 'application'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < ActionController::TestCase

  def test_should_load_default_environment
    Environment.delete_all
    e1 = create_environment(:is_default => false)
    e2 = create_environment(:is_default => true)
    e3 = create_environment(:is_default => false)
    assert_equal e2, @controller.send(:load_environment)
  end

  def test_should_find_users
    assert_equal @controller.send(:find_users), User.find(:all)
  end

  def test_should_load_roles
    role = Role.create(:name => "test")
    assert_equal @controller.send(:load_roles), Role.find(:all)
  end

  def test_should_load_item
    survey = create_survey
    item = create_item(:type => "Question", :survey_id => survey.id)
    @controller = Survey::ItemValuesController.new
    get :index, :survey_id => item.survey_id, :question_id => item.id
    assert_equal @controller.send(:load_item), item
  end

  def test_should_load_item_values
    survey = create_survey
    item = create_item(:type => "Question", :survey_id => survey.id)
    i1 = create_item_value(:item_id => item.id, :position => 1)
    item.reload

    @controller = Survey::ItemValuesController.new
    get :index, :survey_id => item.survey_id, :question_id => item.id
    assert_equal @controller.send(:load_item_values), item.item_values
  end

  def test_should_require_publication
    survey = create_survey
    item = create_item(:type => "Question", :survey_id => survey.id)
    @controller = PublicController.new
    get :show, :public_id => survey.id
    assert_response :redirect
  end

  def test_admin_should_load_survey
    create_environment(:is_default => true)
    admin = create_user(:administrator => true)
    survey = create_survey
    item = create_item(:type => "Question", :survey_id => survey.id)
    login_as(admin.login)
    @controller = Survey::ItemsController.new
    get :edit, :id => item.id, :survey_id => survey.id
    assert_equal @controller.send(:load_survey), survey
  end
end
