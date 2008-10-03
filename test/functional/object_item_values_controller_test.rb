require File.dirname(__FILE__) + '/../test_helper'
require 'object_item_values_controller'

# Re-raise errors caught by the controller.
class ObjectItemValuesController; def rescue_action(e) raise e end; end

class ObjectItemValuesControllerTest < Test::Unit::TestCase
  fixtures :object_item_values

  def setup
    @controller = ObjectItemValuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:object_item_values)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_object_item_value
    old_count = ObjectItemValue.count
    post :create, :object_item_value => { }
    assert_equal old_count+1, ObjectItemValue.count
    
    assert_redirected_to object_item_value_path(assigns(:object_item_value))
  end

  def test_should_show_object_item_value
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_object_item_value
    put :update, :id => 1, :object_item_value => { }
    assert_redirected_to object_item_value_path(assigns(:object_item_value))
  end
  
  def test_should_destroy_object_item_value
    old_count = ObjectItemValue.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ObjectItemValue.count
    
    assert_redirected_to object_item_values_path
  end
end
