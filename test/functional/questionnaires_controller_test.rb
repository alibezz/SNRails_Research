require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaires_controller'

# Re-raise errors caught by the controller.
class QuestionnairesController; def rescue_action(e) raise e end; end

class QuestionnairesControllerTest < Test::Unit::TestCase

  def setup
    @controller = QuestionnairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @research = create_research
    @i1 = create_item(:research_id => @research.id, :page_id => 1)
    @ivalue1 = create_item_value(:item_id => @i1.id)
    @i2 = create_item(:research_id => @research.id, :page_id => 2)
    @ivalue2 = create_item_value(:item_id => @i2.id)
    @research.reload; @i1.reload; @i2.reload
  end

  def test_should_get_new
    get :new, :research_id => @research.id
    assert_response :success
    #page_id == 1 ou 2
    assert_tag :tag => 'form', :attributes => { :action => new_research_questionnaire_url(@research.id), :method => 'post', :url => {:action => 'new'} }


  end
  
  def test_should_create_questionnaire
    old_count = Questionnaire.count
    post :create, :questionnaire => { }
    assert_equal old_count+1, Questionnaire.count
    
    assert_redirected_to questionnaire_path(assigns(:questionnaire))
  end

  def test_should_show_questionnaire
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_questionnaire
    put :update, :id => 1, :questionnaire => { }
    assert_redirected_to questionnaire_path(assigns(:questionnaire))
  end
  
  def test_should_destroy_questionnaire
    old_count = Questionnaire.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Questionnaire.count
    
    assert_redirected_to questionnaires_path
  end
end
