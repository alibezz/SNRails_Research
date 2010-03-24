require File.dirname(__FILE__) + '/../test_helper'

class ItemValueTest < Test::Unit::TestCase

  def setup
    @types = Question.html_types
  end 
 
  def test_should_belong_to_an_item
   count = ItemValue.count 
   ivalue = create_item_value(:item_id => nil)
   assert_equal count, ItemValue.count
   
   survey = create_survey
   item = create_item(:type => "question", :survey_id => survey.id)
   ivalue = create_item_value(:item_id => item.id)
   assert_equal count + 1, ItemValue.count
  end  

  def test_should_have_a_position
   survey = create_survey
   item = create_item(:type => "question", :survey_id => survey.id)
   
   count = item.item_values.length
   ivalue = create_item_value(:item_id => item.id, :position => nil)
   item.reload
   assert_equal count, item.item_values.length
   
   ivalue = create_item_value(:item_id => item.id, :position => item.item_values.length + 1)
   item.reload
   assert_equal count + 1, item.item_values.length
  end

  def test_has_info
   survey = create_survey

   # Single selection item
   item = create_item(:type => "question", :survey_id => survey.id, :html_type => @types.invert["single_selection"])
   count = item.item_values.length
   ivalue = create_item_value(:item_id => item.id, :info => "")
   item.reload
   assert_equal count, item.item_values.length   
   ivalue = create_item_value(:item_id => item.id, :info => "info")
   item.reload
   assert_equal count + 1, item.item_values.length   
 end

end
