require File.dirname(__FILE__) + '/../test_helper'
require 'questionnaires_controller'

# Re-raise errors caught by the controller.
class QuestionnairesController; def rescue_action(e) raise e end; end

class QuestionnairesControllerTest < Test::Unit::TestCase

  def setup
    @controller = QuestionnairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = create_environment(:is_default => true)

    @survey = create_survey
    @section1 = create_item(:type => "section", :survey_id => @survey.id, :page_id => 1)
    @question1 = create_item(:type => "question", :survey_id => @survey.id, :html_type => Question.html_types.invert["pure_text"], :page_id => 1, :is_optional => false)
    @question2 = create_item(:type => "question", :survey_id => @survey.id, :html_type => Question.html_types.invert["single_selection"], :page_id => 2, :is_optional => false)
    @ivalue1 = create_item_value(:item_id => @question2.id, :info => "info")
    @ivalue2 = create_item_value(:item_id => @question2.id, :info => "info2")
    @survey.reload; @question2.reload
  end

#new

  def test_should_get_new
     post :new, :survey_id => @survey.id
    assert_response :success
    #page_id == 1, because it's the first page 
    assert_tag :tag => 'form', :attributes => {:action => "/questionnaires/new?page_id=0", :method => 'post'}
    assert_tag :tag => "input", :attributes => {:type => "submit", :value => /Next/}


    post :new, :survey_id => @survey.id, :commit => "Next", :page_id => 0
    assert_response :success
    assert_tag :tag => 'form', :attributes => {:action => "/questionnaires/new?page_id=1", :method => 'post'}
   
    post :new, :survey_id => @survey.id, :commit => "Back", :page_id => 1
    assert_response :success
    assert_tag :tag => 'form', :attributes => {:action => "/questionnaires/new?page_id=0", :method => 'post'}
 
 end

#create
  
  def test_should_create_questionnaire
     count = Questionnaire.count

    # Some questions weren't answered.
     
     post :new, :public_id => @survey.id, :commit => "Submit", :page_id => 1, :object_item_values => {}

     assert_equal count, Questionnaire.count

     # All questions were answered. 

     post :new, :public_id => @survey.id, :commit => "Submit",                                                                           :page_id => 1, :object_item_values => {@question1.id.to_s => {:info => "test"},                                                                                     @question2.id.to_s => @ivalue1.id.to_s}
    
     assert_equal count + 1, Questionnaire.count

  end

end
