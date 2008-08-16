require 'test_helper'

class ResearchesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:researches)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_research
    assert_difference('Research.count') do
      post :create, :research => { }
    end

    assert_redirected_to research_path(assigns(:research))
  end

  def test_should_show_research
    get :show, :id => researches(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => researches(:one).id
    assert_response :success
  end

  def test_should_update_research
    put :update, :id => researches(:one).id, :research => { }
    assert_redirected_to research_path(assigns(:research))
  end

  def test_should_destroy_research
    assert_difference('Research.count', -1) do
      delete :destroy, :id => researches(:one).id
    end

    assert_redirected_to researches_path
  end
end
