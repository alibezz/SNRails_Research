require File.dirname(__FILE__) + '/../test_helper'
require 'researches_controller'

# Re-raise errors caught by the controller.
class ResearchesController; def rescue_action(e) raise e end; end

class ResearchesControllerTest < Test::Unit::TestCase
  fixtures :researches

  def setup
    @controller = ResearchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    env = Environment.new
    Environment.expects(:default).returns(env)
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
