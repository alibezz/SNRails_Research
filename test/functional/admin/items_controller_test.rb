require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/items_controller'

# Re-raise errors caught by the controller.
class Admin::ItemsController; def rescue_action(e) raise e end; end

class ItemsControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = Admin::ItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    env = Environment.new
    Environment.expects(:default).returns(env)
    login_as :quentin
  end

#index

  def test_should_get_index
    r = create_research
    get :index, :research_id => r.id
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
     
  end

  def test_should_show_questions
    r = create_research
    i = create_item_of_a_research(r)
    get :index, :research_id => r.id
    assert_tag :tag => "a", :attributes => { :href => edit_admin_research_item_url(i.research_id, i.id) }
    assert_tag :tag => "a", :attributes => { :href => admin_research_item_item_values_url(i.research_id, i.id)}
  end

#new

  def test_should_get_new
    r = create_research
    get :new, :research_id => r.id
    assert_response :success
    assert_template 'new'
  end

  def test_new_should_have_form
    r = create_research
    get :new, :research_id => r.id
    assert_tag :tag => 'form', :attributes => { :method => 'post' }    
  end

  def test_new_should_have_back_link
    r = create_research
    get :new, :research_id => r.id
    assert_tag :tag => 'a', :attributes => { :href => admin_research_items_url(r.id) }    
  end

#create

  def test_should_post_create_successfully
    r = create_research
    assert_equal 0, r.items.length

    post :create, :item => {"position"=>"1", "info"=>"test1", "html_type"=> 0}, :research_id => r.id
    r.reload 
    assert_equal 1, r.items.length
  end

#show

  def test_should_get_show
    r = create_research
    i = create_item_of_a_research(r)
    get :show, :research_id => i.research_id, :id => i.id
    assert_response :success
    assert_template 'show'
  end


  def test_should_show_links
    r = create_research
    i = create_item_of_a_research(r)
    get :show, :research_id => i.research_id, :id => i.id
    assert_tag :tag => 'a', :attributes => { :href => edit_admin_research_item_url(i.research_id, i.id) } 
    assert_tag :tag => 'a', :attributes => { :href => admin_research_items_url(i.research_id) } 
  end

#edit

  def test_should_get_edit
    r = create_research
    i = create_item_of_a_research(r)
    get :edit, :research_id => i.research_id, :id => i.id
    assert_response :success
    assert_template 'edit'

  end

  def test_edit_should_have_form
    r = create_research
    i = create_item_of_a_research(r)
    get :edit, :research_id => i.research_id, :id => i.id
    assert_tag :tag => 'form', :attributes => {:action => admin_research_item_url(i.research_id, i.id),  :method => 'post' }    
  end

  def test_edit_should_show_links
    r = create_research
    i = create_item_of_a_research(r)
    get :edit, :research_id => i.research_id, :id => i.id
    assert_tag :tag => 'form', :attributes => {:action => admin_research_item_url(i.research_id, i.id),  :method => 'post' }    
    assert_tag :tag => 'a', :attributes => { :href => admin_research_items_url(i.research_id) }    
  end

#update

  def test_should_change_fields
    r = create_research
    i = create_item_of_a_research(r); i.html_type = 0; i.save!

    position = i.position

    post :update, :id => i.id, :research_id => i.research_id, :item => {:position => i.position + 1, :info => 'new info', 
									:html_type => 1}
    i.reload
    assert_equal position + 1, i.position
    assert_equal 'new info', i.info
    assert_equal 1, i.html_type
  end

 protected
  
  def create_item_of_a_research(research)
     item = create_item(:research_id => research.id)
     item 
  end

end
