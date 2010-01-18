require File.dirname(__FILE__) + '/../test_helper'
require 'researches_controller'

# Re-raise errors caught by the controller.
class ResearchesController; def rescue_action(e) raise e end; end

class ResearchesControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = ResearchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = create_environment(:is_default => true)
    #Environment.expects(:default).returns(env)
  end

#index

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:researches)
  end

  def test_index_should_not_show_inactive_researches
    #Inactive researches
    r1 = create_research

    get :index
    assert_response :success
    assert_equal 0, assigns(:researches).count
  end

  def test_index_should_show_active_researches
    r1 = create_research
    i1 = create_item(:type => "Question", :html_type => Question.html_types.invert["pure_text"], :research_id => r1)
    r1.reload; r1.is_active = true; r1.save; r1.reload

    get :index
    assert_response :success
    assert_equal 1, assigns(:researches).count
  end

  def test_should_show_research
    r = create_research
    get :show, :id => r.id
    assert_response :success
  end

end
