require File.dirname(__FILE__) + '/../test_helper'
require 'answers_controller'

# Re-raise errors caught by the controller.
class AnswersController; def rescue_action(e) raise e end; end

class AnswersControllerTest < Test::Unit::TestCase
  fixtures :answers

  def setup
    @controller = AnswersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:answers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_answer
    old_count = Answer.count
    post :create, :answer => { }
    assert_equal old_count+1, Answer.count
    
    assert_redirected_to answer_path(assigns(:answer))
  end

  def test_should_show_answer
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_answer
    put :update, :id => 1, :answer => { }
    assert_redirected_to answer_path(assigns(:answer))
  end
  
  def test_should_destroy_answer
    old_count = Answer.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Answer.count
    
    assert_redirected_to answers_path
  end
end
