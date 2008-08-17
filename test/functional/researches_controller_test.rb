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
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:researches)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_research
    old_count = Research.count
    post :create, :research => { }
    assert_equal old_count+1, Research.count
    
    assert_redirected_to research_path(assigns(:research))
  end

  def test_should_show_research
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_research
    put :update, :id => 1, :research => { }
    assert_redirected_to research_path(assigns(:research))
  end
  
  def test_should_destroy_research
    old_count = Research.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Research.count
    
    assert_redirected_to researches_path
  end
end
