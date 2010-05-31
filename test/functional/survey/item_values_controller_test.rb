require File.dirname(__FILE__) + '/../../test_helper'
require 'survey/item_values_controller'

# Re-raise errors caught by the controller.
class Survey::ItemValuesController; def rescue_action(e) raise e end; end

class ItemValuesControllerTest < Test::Unit::TestCase
#  fixtures :users

  def setup
    @controller = Survey::ItemValuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = Environment.create(:is_default => true)
    role = create_role(:name => 'Moderator', :permissions => ActiveRecord::Base::PERMISSIONS['survey'].keys)
    user = create_user
    @survey = create_survey
    @item = create_item(:survey_id => @survey.id, :type => "question", :html_type => Question.html_types.invert["single_selection"])
    @ivalue = create_item_value(:info => "info", :item_id => @item.id)
    user.add_role(role, @survey)
    login_as(user.login)
  end

#index

  def test_should_get_index
    get :index, :survey_id => @item.survey_id, :question_id => @item.id 
    assert_response :success
    assert_tag :tag => "ul", :attributes => {:id => "survey_menu" }
  end

#create

  def test_should_create_item
    count = @item.item_values.count
    last_position = @item.item_values.maximum(:position)

    #creates
    post :create, :question_id => @item.id, :item_value => {:info => "test"}
    @item.reload

    assert_equal count + 1, @item.item_values.count
    assert_equal last_position + 1, @item.item_values.maximum(:position)
    assert_response :redirect
    assert_redirected_to survey_survey_question_item_values_path(@item.survey_id, @item)
    assert flash[:notice]
    
    #doesnt create
    post :create, :question_id => @item.id, :item_value => {:info => ""}
    @item.reload
    assert_equal count + 1, @item.item_values.count
    assert_response :redirect
    assert_redirected_to survey_survey_question_item_values_path(@item.survey_id, @item)
  end

#edit

  def test_should_get_edit
    get :edit, :question_id => @item.id, :id => @ivalue.id
    assert_response :success
    assert_template 'edit'
  end

  def test_edit_should_have_form
    get :edit, :question_id => @item.id, :id => @ivalue.id
    assert_tag :tag => 'form'  
 end

#update

  def test_should_update
    ivalue = create_item_value(:item_id => @item.id, :info => "test")
   
    #updates 
    post :update, :question_id => @item.id, :id => ivalue.id, :item_value => {:info => "new_test"}
    ivalue.reload

    assert_equal ivalue.info, "new_test"
    assert_response :redirect
    assert_redirected_to survey_survey_question_item_values_path(@item.survey_id, @item)
 
    #doesnt update
    get :edit, :question_id => @item.id, :id => @ivalue.id
    post :update, :question_id => @item.id, :id => ivalue.id, :item_value => {:info => ""}
    ivalue.reload

    assert_equal ivalue.info, "new_test"
  end

#destroy

  def test_should_destroy_item_value
    @item.item_values.delete_all; @item.reload
    i1 = create_item_value(:item_id => @item.id, :position => 1)
    @item.reload
    assert_equal @item.item_values.count, 1

    post :destroy, :question_id => @item.id, :id => i1.id
    assert flash[:notice]
   
    @item.reload
    assert_equal @item.item_values.count, 0
    
  end

#reorder_item_values
#
  def test_should_reorder_item_values
    #There's already an item_value
    i1 = create_item_value(:item_id => @item.id, :position => 2)
    i2 = create_item_value(:item_id => @item.id, :position => 3)
    i3 = create_item_value(:item_id => @item.id, :position => 4)
    @item.reload

    post :reorder_item_values, :list_item_values => ["4", "1", "2", "3"], :survey_id => @item.survey_id,                               :question_id => @item.id
    @item.reload; i1.reload; i2.reload; i3.reload

    assert_equal i3.position, 0
    assert_equal @item.item_values.find(1).position, 1
    assert_equal i1.position, 2
    assert_equal i2.position, 3

    post :reorder_item_values, :list_item_values => ["1", "2", "3","4"], :survey_id => @item.survey_id,                               :question_id => @item.id
    @item.reload; i1.reload; i2.reload; i3.reload
    
    assert_equal @item.item_values.find(1).position, 0
    assert_equal i1.position, 1
    assert_equal i2.position, 2
    assert_equal i3.position, 3

  end
end
