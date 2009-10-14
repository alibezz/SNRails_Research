require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/researches_controller'

# Re-raise errors caught by the controller.
class Admin::ResearchesController; def rescue_action(e) raise e end; end

class ResearchesControllerTest < Test::Unit::TestCase
  fixtures :users, :researches

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
    get :index
    assert_tag :tag => "ul", :descendant => { :tag => "li" }
    assert_tag :tag => 'a', :attributes => { :href => admin_research_url(researches(:one).id) }
    assert_tag :tag => 'a', :attributes => { :href => edit_admin_research_url(researches(:one).id) }
  end

  def test_index_should_not_show_links
    id = researches(:one).id
    Research.destroy_all

    get :index
    assert_no_tag :tag => 'a', :attributes => { :href => admin_research_url(researches(:one).id) }
    assert_no_tag :tag => 'a', :attributes => { :href => edit_admin_research_url(id) }
  end

#show

  def test_should_show_research
    get :show, :id => 1
    assert_response :success
  end

end
