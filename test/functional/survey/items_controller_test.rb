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
    role = create_role(:name => 'Moderator', :permissions => ActiveRecord::Base::PERMISSIONS['survey'].keys)
    user = create_user(:login => "Susan")
    @survey = create_survey
    user.add_role(role, @survey)
    login_as(user.login)
  end

#index

  def test_should_get_index
    get :index, :survey_id => @survey.id
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
    assert_tag :tag => "ul", :attributes => { :id => "survey_menu" } 
    assert_tag :tag => "h1", :attributes => { :class => "title" }     
    assert_tag :tag => "h2", :attributes => { :class => "subtitle" }     
  end

  def test_index_should_load_current_page
    q1 = create_item(:survey_id => @survey.id, :page_id => 2)
    get :index, :survey_id => @survey.id
    assert assigns(:page)
    assert_equal assigns(:page), 2
  end

   
#new

  def test_should_get_new
    get :new, :survey_id => @survey.id
    assert_response :success
    assert_template 'new'
    assert_tag :tag => "ul", :attributes => {:id => "survey_menu" }
  end

  def test_new_should_have_form
    get :new, :survey_id => @survey.id
    assert_tag :tag => 'form', :attributes => { :method => 'post' }    
  end

#create

  def test_should_post_create_successfully
    assert_equal 0, @survey.items.length

    post :create, :item => { "info"=>"test1", "html_type"=> 0}, :survey_id => @survey.id
    @survey.reload 
    assert_equal 1, @survey.items.length
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(@survey.id, :page => @survey.items.last.page_id)
    
    post :create, :item_type => "section", :item => {"info"=>"test1"}, :survey_id => @survey.id
    @survey.reload
    assert_equal @survey.items.last.html, "section"
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(@survey.id, :page => @survey.items.last.page_id)
    
    post :create, :item => {"info"=>"", "html_type"=> 0}, :survey_id => @survey.id
    assert_response :redirect
    assert_redirected_to new_survey_survey_item_path(@survey.id)
  end

#edit

  def test_should_get_edit
    i = create_item_of_a_survey(@survey)
    get :edit, :survey_id => i.survey_id, :id => i.id
    assert_response :success
    assert_template 'edit'
  end

  def test_edit_should_have_form
    i = create_item_of_a_survey(@survey)
    get :edit, :survey_id => i.survey_id, :id => i.id
    assert_tag :tag => 'form', :attributes => {:action => survey_survey_item_url(i.survey_id, i.id),  :method => 'post' }    
  end

#update

  def test_should_change_fields
    i = create_item_of_a_survey(@survey); i.html_type = 0; i.save!

    position = i.position
    page = i.page_id

    post :update, :id => i.id, :survey_id => i.survey_id, :item => {:position => i.position + 1, :info => 'new info',                                                                            :page_id => page + 1, :html_type => 1}
    i.reload
    assert_equal position + 1, i.position
    assert_equal page + 1, i.page_id
    assert_equal 'new info', i.info
    assert_equal 1, i.html_type
    assert_response :redirect
    assert_redirected_to survey_survey_items_path(@survey.id, :page => i.page_id)
    
    post :update, :id => i.id, :survey_id => i.survey_id, :item => {:position => i.position + 1, :info => '',                                                                                    :html_type => nil}
    assert_response :redirect
    assert_redirected_to edit_survey_survey_item_url(i.survey_id, i.id, :item_type => "question") 
  end

#reorder items
  def test_should_reorder_items
    i1 = create_item(:survey_id => @survey.id, :position => 0)
    i2 = create_item(:survey_id => @survey.id, :position => 1)
    i3 = create_item(:survey_id => @survey.id, :position => 2)
    get :index, :survey_id => @survey.id
    post :reorder_items, :list_items => ["3", "1", "2"], :page => nil, :survey_id => @survey.id
    @survey.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.position, 1
    assert_equal i2.position, 2
    assert_equal i3.position, 0
    
    post :reorder_items, :list_items => ["1", "2", "3"], :page => nil, :survey_id => @survey.id
    @survey.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.position, 0
    assert_equal i2.position, 1
    assert_equal i3.position, 2
  end

#reorder_pages

  def test_should_reorder_pages
    i1 = create_item(:survey_id => @survey.id, :page_id => 1)
    i2 = create_item(:survey_id => @survey.id, :page_id => 2)
    i3 = create_item(:survey_id => @survey.id, :page_id => 3)
    get :index, :survey_id => @survey.id
    post :reorder_pages, :page_links => ["3", "1", "2"], :page => nil, :survey_id => @survey.id
    @survey.reload; i1.reload; i2.reload; i3.reload
    assert_equal i1.page_id, 2
    assert_equal i2.page_id, 3
    assert_equal i3.page_id, 1
  end

#destroy
  
  def test_should_destroy_item
    i1 = create_item(:survey_id => @survey.id, :page_id => 1)
    count = Item.find(:all).count

    post :destroy, :survey_id => @survey.id, :id => i1.id
    assert_equal count - 1, Item.find(:all).count
  end

#dependencies

  def test_should_get_dependencies
    i1 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 1)
    i2 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 2)
    get :dependencies, :survey_id => @survey.id, :id => i2.id
    assert_tag :tag => "ul", :attributes => {:id => "survey_menu" }

    assert_response :success
    assert_equal assigns(:questions), i2.previous

    get :dependencies, :survey_id => @survey.id, :id => i1.id
    assert_tag :tag => "ul", :attributes => {:id => "survey_menu" }
    assert_response :success
    assert flash[:notice]
  end

#create_dependency

  def test_should_create_dependencies
    i1 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 1)
    i2 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 2)
    alt1 = create_item_value(:item_id => i1.id)
    alt2 = create_item_value(:item_id => i1.id)
 
    post :create_dependency, :id => i2.id, :survey_id => @survey.id, :dependencies => alt1.id,                                        :conditional => {:relation => Conditional.hash_ops.keys.first.to_s}
    i2.reload; alt1.reload
    assert_equal alt1.conds, [i2]
    assert_equal i2.dependencies, [alt1]

    post :create_dependency, :id => i2.id, :survey_id => @survey.id, :dependencies => nil,                                        :conditional => {:relation => Conditional.hash_ops.keys.first.to_s}
    assert_response :redirect
    i2.reload
    assert_equal i2.dependencies, [alt1] 
 
    post :create_dependency, :id => i2.id, :survey_id => @survey.id, :dependencies => alt2.id,                                        :conditional => {:relation => nil}
    assert_response :redirect
    i2.reload
    assert_equal i2.dependencies, [alt1]

    post :create_dependency, :id => nil, :survey_id => @survey.id, :dependencies => alt1.id,                                        :conditional => {:relation => Conditional.hash_ops.keys.first.to_s}
    assert_response :redirect
    alt1.reload
    assert_equal alt1.conds, [i2]

  end

#remove_dependency

  def test_remove_dependency
    i1 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 1)
    i2 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 2)
    alt1 = create_item_value(:item_id => i1.id)
    create_conditional(i2.id, alt1.id)
    i2.reload
    post :remove_dependency, :id => i2.id, :survey_id => @survey.id, :deps => [alt1.id]
    i2.reload
    assert_equal i2.dependencies, []
  end

#filter

  def test_should_filter_alternatives
    i1 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 1)
    i2 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 2)
    alt1 = create_item_value(:item_id => i1.id)
    alt2 = create_item_value(:item_id => i2.id)

    xhr :post, :filter, :survey_id => @survey.id, :id => i2.id, :value => i1.id
    assert @response.body.index("\"conditional_relation\\") #operators

    assert @response.body.index("select id=\\\"dependencies\\\" name=\\\"dependencies\\\"\\u003E\\u003Coption value=\\\"\\\"\\u003E-Select\\u003C/option\\u003E\\u003Coption value=\\\"#{alt1.id}\\") #alternatives
    assert_nil @response.body.index("select id=\\\"dependencies\\\" name=\\\"dependencies\\\"\\u003E\\u003Coption value=\\\"\\\"\\u003E-Select\\u003C/option\\u003E\\u003Coption value=\\\"#{alt2.id}\\") 
    
    xhr :post, :filter, :survey_id => @survey.id, :id => i2.id, :value => nil # i1.id
    assert @response.body.index("You are being") #redirection
    xhr :post, :filter, :survey_id => @survey.id, :id => nil, :value => i1.id
    assert @response.body.index("You are being") #redirection
  end

#remove_items

  def test_should_get_remove_items
    i1 = create_item(:type => 'section', :survey_id => @survey.id, :page_id => 1)
    i2 = create_item(:type => 'question', :survey_id => @survey.id, :page_id => 1)
    page = i1.page_id
    @survey.reload

    get :remove_items, :id => i1.id, :survey_id => @survey.id, :page => page
    assert_response :success
    assert assigns(:section_items)
    assert_equal assigns(:section_items), [i1, i2]
    assert assigns(:page)
    assert_equal assigns(:page), page.to_s
  end

#destroy_items

  def test_should_destroy_section_items
    i1 = create_item(:type => 'section', :survey_id => @survey.id)
    i2 = create_item(:type => 'question', :survey_id => @survey.id) 
    post :destroy_items, :id => i1.id, :page => i1.page_id
    assert @survey.items.blank?
  end

protected
  
  def create_item_of_a_survey(survey)
     item = create_item(:survey_id => survey.id)
     item 
  end

end
