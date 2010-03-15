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
    @environment = create_environment(:is_default => true)
#    Environment.expects(:default).returns(env)
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

  def test_should_show_items
    r = create_research
    text_question = create_item(:type => "question", :research_id => r.id, :html_type => Question.html_types.invert["pure_text"])
    selection_question = create_item(:type => "question", :research_id => r.id, :html_type => Question.html_types.invert["single_selection"], :page_id => 2)
    section = create_item(:type => "section", :research_id => r.id, :page_id => 3)

    get :index, :research_id => r.id
    assert_tag :tag => "a", :attributes => { :href => new_admin_research_item_path(r.id, :item_type => "question") }
    assert_tag :tag => "a", :attributes => { :href => new_admin_research_item_path(r.id, :item_type => "section") }

    assert_tag :tag => "a", :attributes => { :href => edit_admin_research_item_path(r, text_question, :item_type => text_question.class.to_s.downcase)} 
    assert_no_tag :tag => "a", :attributes => { :href => new_admin_question_item_value_path(text_question)}

    get :index, :research_id => r.id, :page => 2
    
    assert_tag :tag => "a", :attributes => { :href => edit_admin_research_item_path(r, selection_question, :item_type => selection_question.class.to_s.downcase)} 
    assert_tag :tag => "a", :attributes => { :href => new_admin_question_item_value_path(selection_question)}

    get :index, :research_id => r.id, :page => 3

    assert_tag :tag => "a", :attributes => { :href => edit_admin_research_item_path(r, section, :item_type => section.class.to_s.downcase)} 
    assert_no_tag :tag => "a", :attributes => { :href => new_admin_question_item_value_path(section)}
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

    post :create, :item => {"position"=>"1", "info"=>"", "html_type"=> 0}, :research_id => r.id
    assert_response :redirect
    assert_redirected_to new_admin_research_item_path(r.id)
  end

#show

  def test_should_get_show
    r = create_research
    i = create_item_of_a_research(r)
    get :show, :research_id => i.research_id, :id => i.id
    assert_response :success
    assert_template 'show'
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
    
    post :update, :id => i.id, :research_id => i.research_id, :item => {:position => i.position + 1, :info => '',                                                                                    :html_type => nil}
    assert_response :redirect
    assert_redirected_to edit_admin_research_item_url(i.research_id, i.id, :item_type => "question") 
  end

#reorder items
  def test_should_reorder_items
    r = create_research
    i1 = create_item(:research_id => r.id, :position => 0)
    i2 = create_item(:research_id => r.id, :position => 1)
    i3 = create_item(:research_id => r.id, :position => 2)
    get :index, :research_id => r.id
    post :reorder_items, :list_items => ["3", "1", "2"], :page => nil, :research_id => r.id
    r.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.position, 1
    assert_equal i2.position, 2
    assert_equal i3.position, 0
    
    post :reorder_items, :list_items => ["1", "2", "3"], :page => nil, :research_id => r.id
    r.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.position, 0
    assert_equal i2.position, 1
    assert_equal i3.position, 2
  end

#reorder_pages

  def test_should_reorder_pages
    r = create_research
    i1 = create_item(:research_id => r.id, :page_id => 1)
    i2 = create_item(:research_id => r.id, :page_id => 2)
    i3 = create_item(:research_id => r.id, :page_id => 3)
    get :index, :research_id => r.id
    post :reorder_pages, :page_links => ["3", "1", "2"], :page => nil, :research_id => r.id
    r.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.page_id, 2
    assert_equal i2.page_id, 3
    assert_equal i3.page_id, 1
  end

 protected
  
  def create_item_of_a_research(research)
     item = create_item(:research_id => research.id)
     item 
  end

end
