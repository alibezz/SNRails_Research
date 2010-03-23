require File.dirname(__FILE__) + '/../../test_helper'
require 'survey/items_controller'

# Re-raise errors caught by the controller.
class Survey::ItemsController; def rescue_action(e) raise e end; end

class Survey::ItemsControllerTest < Test::Unit::TestCase
  #fixtures :users

  def setup
    @controller = Survey::ItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = Environment.create(:is_default => true)
    role = create_role(:name => 'Moderator', :permissions => ActiveRecord::Base::PERMISSIONS['research'].keys)
    user = create_user(:login => "Susan")
    @research = create_research
    user.add_role(role, @research)
    login_as(user.login)
  end

#index

  def test_should_get_index
    get :index, :research_id => @research.id
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
     
  end

#new

  def test_should_get_new
    get :new, :research_id => @research.id
    assert_response :success
    assert_template 'new'
  end

  def test_new_should_have_form
    get :new, :research_id => @research.id
    assert_tag :tag => 'form', :attributes => { :method => 'post' }    
  end

  def test_new_should_have_back_link
    get :new, :research_id => @research.id
    assert_tag :tag => 'a', :attributes => { :href => survey_research_items_url(@research.id) }    
  end

#create

  def test_should_post_create_successfully
    assert_equal 0, @research.items.length

    post :create, :item => {"position"=>"1", "info"=>"test1", "html_type"=> 0}, :research_id => @research.id
    @research.reload 
    assert_equal 1, @research.items.length

    post :create, :item => {"position"=>"1", "info"=>"", "html_type"=> 0}, :research_id => @research.id
    assert_response :redirect
    assert_redirected_to new_survey_research_item_path(@research.id)
  end

#show

  def test_should_get_show
    i = create_item_of_a_research(@research)
    get :show, :research_id => i.research_id, :id => i.id
    assert_response :success
    assert_template 'show'
  end

#edit

  def test_should_get_edit
    i = create_item_of_a_research(@research)
    get :edit, :research_id => i.research_id, :id => i.id
    assert_response :success
    assert_template 'edit'

  end

  def test_edit_should_have_form
    i = create_item_of_a_research(@research)
    get :edit, :research_id => i.research_id, :id => i.id
    assert_tag :tag => 'form', :attributes => {:action => survey_research_item_url(i.research_id, i.id),  :method => 'post' }    
  end

#update

  def test_should_change_fields
    i = create_item_of_a_research(@research); i.html_type = 0; i.save!

    position = i.position

    post :update, :id => i.id, :research_id => i.research_id, :item => {:position => i.position + 1, :info => 'new info', 
									:html_type => 1}
    i.reload
    assert_equal position + 1, i.position
    assert_equal 'new info', i.info
    assert_equal 1, i.html_type
    
    post :update, :id => i.id, :research_id => i.research_id, :item => {:position => i.position + 1, :info => '',                                                                                    :html_type => nil}
    assert_response :redirect
    assert_redirected_to edit_survey_research_item_url(i.research_id, i.id, :item_type => "question") 
  end

#reorder items
  def test_should_reorder_items
    i1 = create_item(:research_id => @research.id, :position => 0)
    i2 = create_item(:research_id => @research.id, :position => 1)
    i3 = create_item(:research_id => @research.id, :position => 2)
    get :index, :research_id => @research.id
    post :reorder_items, :list_items => ["3", "1", "2"], :page => nil, :research_id => @research.id
    @research.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.position, 1
    assert_equal i2.position, 2
    assert_equal i3.position, 0
    
    post :reorder_items, :list_items => ["1", "2", "3"], :page => nil, :research_id => @research.id
    @research.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.position, 0
    assert_equal i2.position, 1
    assert_equal i3.position, 2
  end

#reorder_pages

  def test_should_reorder_pages
    i1 = create_item(:research_id => @research.id, :page_id => 1)
    i2 = create_item(:research_id => @research.id, :page_id => 2)
    i3 = create_item(:research_id => @research.id, :page_id => 3)
    get :index, :research_id => @research.id
    post :reorder_pages, :page_links => ["3", "1", "2"], :page => nil, :research_id => @research.id
    @research.reload; i1.reload; i2.reload; i3.reload
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
