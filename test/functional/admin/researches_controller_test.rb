require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/researches_controller'

# Re-raise errors caught by the controller.
class Admin::ResearchesController; def rescue_action(e) raise e end; end

class ResearchesControllerTest < Test::Unit::TestCase
  fixtures :researches, :users

  def setup
    @controller = Admin::ResearchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    env = Environment.new
    Environment.expects(:default).returns(env)
    login_as :quentin

  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:researches)
  end

  def test_should_show_research
    get :show, :id => 1
    assert_response :success
  end

end
