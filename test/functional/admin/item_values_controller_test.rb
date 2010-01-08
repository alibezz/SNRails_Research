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
#    Environment.expects(:default).returns(env)
    login_as :quentin
    @research = create_research
    @item = create_item(:research_id => @research.id, :type => "question", :html_type => Question.html_types.invert["single_selection"])
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

#show

 def test_should_get_show
    ivalue = create_item_value(:info => "info", :item_id => @item.id)
    get :show, :question_id => @item.id, :id => ivalue.id
    assert_response :success
    assert_template 'show'
  end

  def test_should_show_links
    ivalue = create_item_value(:info => "info", :item_id => @item.id)
    get :show, :question_id => @item.id, :id => ivalue.id
    assert_tag :tag => 'a', :attributes => { :href => edit_admin_item_item_value_url(ivalue.item_id, ivalue.id) }
    assert_tag :tag => 'a', :attributes => { :href => 
						admin_research_item_item_values_url(@item.research_id, @item.id) }
  end

#edit

  def test_should_get_edit
    ivalue = create_item_value(:info => "info", :item_id => @item.id)
    get :edit, :question_id => @item.id, :id => ivalue.id
    assert_response :success
    assert_template 'edit'
  end

  def test_edit_should_have_form
    ivalue = create_item_value(:info => "info", :item_id => @item.id)
    get :edit, :question_id => @item.id, :id => ivalue.id
    assert_tag :tag => 'form', :attributes => { :action =>                                                                                                                             admin_question_item_value_url(ivalue.item_id, ivalue.id), :method => 'post' }  
  end

  def test_edit_should_show_links
    ivalue = create_item_value(:info => "info", :item_id => @item.id)
    get :edit, :question_id => @item.id, :id => ivalue.id
    assert_tag :tag => 'form', :attributes => {:action => admin_question_item_value_url(ivalue.item_id, ivalue.id),  :method => 'post' }  
    assert_tag :tag => 'a', :attributes => { :href => 
						admin_research_question_item_values_url(@item.research_id, @item.id) }
  end
end
