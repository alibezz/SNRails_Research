require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/researches_controller'

# Re-raise errors caught by the controller.
class Admin::ResearchesController; def rescue_action(e) raise e end; end

class ResearchesControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = Admin::ResearchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    env = Environment.new
    Environment.expects(:default).returns(env)
    login_as :quentin

  end

#index

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:researches)
  end

  def test_index_should_show_links
    r = create_research

    get :index
    assert_tag :tag => 'a', :attributes => { :href => new_admin_research_url }
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
    assert_tag :tag => 'a', :attributes => { :href => admin_research_url(r.id) }
    assert_tag :tag => 'a', :attributes => { :href => edit_admin_research_url(r.id) }
  end

  def test_index_should_not_show_links
    r = create_research
    Research.destroy_all

    get :index
    assert_no_tag :tag => 'a', :attributes => { :href => admin_research_url(r.id) }
    assert_no_tag :tag => 'a', :attributes => { :href => edit_admin_research_url(r.id) }
  end

#show

  def test_should_show_research
    r = create_research
    get :show, :id => r.id
    assert_response :success
  end

  def test_should_show_links
    r = create_research

    get :show, :id => r.id
    assert_tag :tag => 'a', :attributes => { :href => admin_researches_url }
    assert_tag :tag => 'a', :attributes => { :href => edit_admin_research_url(r.id) }
    assert_tag :tag => 'a', :attributes => { :href => admin_research_moderators_url(r.id) }
    assert_tag :tag => 'a', :attributes => { :href => admin_research_items_url(r.id) }
  end

#edit

  def test_should_edit_research
    r = create_research
    get :edit, :id => r.id
    assert_response :success
  end

  def test_edit_should_have_form
    r = create_research
    get :edit, :id => r.id
    assert_tag :tag => 'form', :attributes => { :action => admin_research_url(r.id), :method => 'post' } 
  end

  def test_should_have_back_link
    r = create_research
    get :edit, :id => r.id
    assert_tag :tag => 'a', :attributes => { :href => admin_research_url(r.id) }
  end

#update

  def test_should_change_fields
    research = create_research
    post :update, :id => research.id, :research => {:title => 'new title', :introduction => 'new introduction', :subtitle => 'new subtitle'}
    research.reload
    assert_equal 'new subtitle', research.subtitle
    assert_equal 'new title', research.title
    assert_equal 'new introduction', research.introduction
  end

#FIXME Action moderators must be better understood 


#new

  def test_should_show_new
    get :new
    assert_response :success
  end

  def test_new_should_have_form
    get :new
    assert_tag :tag => 'form', :attributes => { :method => 'post' } 
  end

  def test_new_should_have_back_link
    r = create_research
    get :edit, :id => r.id
    assert_tag :tag => 'a', :attributes => { :href => admin_research_url(r.id) }
  end


#create

  def test_should_create_research
    count = Research.count
    post :create, :research => {:title => 'new title', :introduction => 'new introduction', :subtitle => 'new subtitle'}
    assert_equal count + 1, Research.count
  end

end
