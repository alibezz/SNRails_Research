require File.dirname(__FILE__) + '/../test_helper'
require 'items_controller'

# Re-raise errors caught by the controller.
class ItemsController; def rescue_action(e) raise e end; end

class ItemsControllerTest < Test::Unit::TestCase
  fixtures :items

  def setup
    @controller = ItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_item
    old_count = Item.count
    post :create, :item => { }
    assert_equal old_count+1, Item.count
    
    assert_redirected_to item_path(assigns(:item))
  end

  def test_should_show_item
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_item
    put :update, :id => 1, :item => { }
    assert_redirected_to item_path(assigns(:item))
  end
  
  def test_should_destroy_item
    old_count = Item.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Item.count
    
    assert_redirected_to items_path
  end
end
