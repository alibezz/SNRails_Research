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

 def test_dependants
   survey = create_survey
   i1 = create_item(:type => "question", :survey_id => survey.id)
   alt1 = create_item_value(:item_id => i1.id)
   i2 = create_item(:type => "question", :survey_id => survey.id)
   i3 = create_item(:type => "question", :survey_id => survey.id)
   i2.create_dependency(alt1, Conditional.hash_ops.keys.first.to_s)
   i3.create_dependency(alt1, Conditional.hash_ops.keys.last.to_s)
   alt1.reload
   assert_equal alt1.dependants, [[i2.id, Conditional.hash_ops.keys.first], [i3.id, Conditional.hash_ops.keys.last]]
 end
end
