require File.dirname(__FILE__) + '/../test_helper'
require 'public_controller'

# Re-raise errors caught by the controller.
class PublicController; def rescue_action(e) raise e end; end

class PublicControllerTest < ActionController::TestCase

  fixtures :users

  def setup
    @environment = create_environment(:is_default => true)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:researches)
  end

  def test_index_should_not_show_inactive_researches
    #Inactive researches
    r1 = create_research(:is_active => false)

    get :index
    assert_response :success
    assert_equal 0, assigns(:researches).count
  end

  def test_index_should_show_active_researches
    r1 = create_research
    i1 = create_item(:type => "Question", :html_type => Question.html_types.invert["pure_text"], :research_id => r1)
    r1.reload; r1.is_active = true; r1.save; r1.reload

    get :index
    assert_response :success
    assert_equal 1, assigns(:researches).count
  end

  def test_should_show_research
    r = create_research
    get :show, :id => r.id
    assert_response :success
  end

end
