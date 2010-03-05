require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/item_values_controller'

# Re-raise errors caught by the controller.
class Admin::ItemValuesController; def rescue_action(e) raise e end; end

class ItemValuesControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = Admin::ItemValuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = Environment.create(:is_default => true)
#    Environment.expects(:default).returns(@environment)
    login_as :quentin
    @research = create_research
    @item = create_item(:research_id => @research.id, :type => "question", :html_type => Question.html_types.invert["single_selection"])
    @ivalue = create_item_value(:info => "info", :item_id => @item.id)
  end

#index

  def test_should_get_index
    get :index, :research_id => @item.research_id, :question_id => @item.id 
    assert_response :success
    assert_template 'index'
  end

  def test_index_should_show_items
    get :index, :research_id => @item.research_id, :question_id => @item.id 
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
  end

  def test_index_should_allow_new
    get :index, :research_id => @item.research_id, :question_id => @item.id 
    assert_tag :tag => "a", :attributes => { :href => new_admin_question_item_value_url(@item.id)}
  end

#new

  def test_should_get_new
    get :new, :question_id => @item.id 
    assert_response :success
    assert_template 'new'
  end

  def test_new_should_have_form
    get :new, :question_id => @item.id 
    assert_tag :tag => 'form', :attributes => { :method => 'post' }
  end

  def test_new_should_have_back_link
    get :new, :question_id => @item.id 
    assert_tag :tag => 'a', :attributes => { :href => admin_research_question_item_values_url(@item.research_id, @item.id) }
  end

#create
  def test_should_reorder_item_values
    i1 = create_item_value(:item_id => @item.id, :position => 1)
    i2 = create_item_value(:item_id => @item.id, :position => 2)
    i3 = create_item_value(:item_id => @item.id, :position => 3)
    post :create, :item_value => {"position"=>"1", "info"=>"test1"}, :item_id => @item.id

    @item.reload; i1.reload; i2.reload; i3.reload
    assert_equal @item.item_values.count, 4
    assert_equal i1.position, 2 
    assert_equal i2.position, 3 
    assert_equal i3.position, 4 
  end

#show

 def test_should_get_show
    get :show, :question_id => @item.id, :id => @ivalue.id
    assert_response :success
    assert_template 'show'
  end

  def test_should_show_links
    get :show, :question_id => @item.id, :id => @ivalue.id
    assert_tag :tag => 'a', :attributes => { :href => edit_admin_question_item_value_url(@ivalue.item_id, @ivalue.id) }
    assert_tag :tag => 'a', :attributes => { :href => 
						admin_research_question_item_values_url(@item.research_id, @item.id) }
  end

#edit

  def test_should_get_edit
    get :edit, :question_id => @item.id, :id => @ivalue.id
    assert_response :success
    assert_template 'edit'
  end

  def test_edit_should_have_form
    get :edit, :question_id => @item.id, :id => @ivalue.id
    assert_tag :tag => 'form', :attributes => { :action =>                                                                                                                             admin_question_item_value_url(@ivalue.item_id, @ivalue.id), :method => 'post' }  
  end

  def test_edit_should_show_links
    get :edit, :question_id => @item.id, :id => @ivalue.id
    assert_tag :tag => 'form', :attributes => {:action => admin_question_item_value_url(@ivalue.item_id, @ivalue.id),  :method => 'post' }  
    assert_tag :tag => 'a', :attributes => { :href => 
						admin_research_question_item_values_url(@item.research_id, @item.id) }
  end

#update

  def test_should_update_positions
    @item.item_values.delete_all; @item.reload

    i1 = create_item_value(:item_id => @item.id, :position => 1)
    i2 = create_item_value(:item_id => @item.id, :position => 2)
    i3 = create_item_value(:item_id => @item.id, :position => 3)
    post :update, :id => i2.id, :question_id => @item.id, :item_value => {:position => 1, :info => i2.info}
    @item.reload; i1.reload; i2.reload; i3.reload
    
    assert_equal i1.position, 2 
    assert_equal i2.position, 1 
    assert_equal i3.position, 3
  end

#destroy

  def test_should_destroy_item_value
    @item.item_values.delete_all; @item.reload
    i1 = create_item_value(:item_id => @item.id, :position => 1)
    @item.reload
    assert_equal @item.item_values.count, 1

    post :destroy, :question_id => @item.id, :id => i1.id
    assert flash[:notice]
   
    @item.reload
    assert_equal @item.item_values.count, 0
    
  end
end
