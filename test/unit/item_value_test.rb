require File.dirname(__FILE__) + '/../test_helper'

class ItemValueTest < Test::Unit::TestCase

  def setup
    @types = Item.html_types
  end 
 
  def test_should_belong_to_an_item
   count = ItemValue.count 
   ivalue = create_item_value(:item_id => nil)
   assert_equal count, ItemValue.count
   
   research = create_research
   item = create_item(:research_id => research.id)
   ivalue = create_item_value(:item_id => item.id)
   assert_equal count + 1, ItemValue.count
  end  

  def test_should_have_a_position
   research = create_research
   item = create_item(:research_id => research.id)
   
   count = item.item_values.length
   ivalue = create_item_value(:item_id => item.id, :position => nil)
   item.reload
   assert_equal count, item.item_values.length
   
   ivalue = create_item_value(:item_id => item.id, :position => item.item_values.length + 1)
   item.reload
   assert_equal count + 1, item.item_values.length
  end

  def test_position_should_be_unique
   research = create_research
   item = create_item(:research_id => research.id)
   
   count = item.item_values.length
   ivalue = create_item_value(:item_id => item.id, :position => count + 1)
   item.reload
   assert_equal ivalue.position, count + 1
   assert_equal count + 1, item.item_values.length 

   ivalue = create_item_value(:item_id => item.id, :position => count + 1)
   item.reload
   assert_equal count + 1, item.item_values.length #Second item_value wasn't created
  end
  
  def test_has_info
   research = create_research

   # Pure text item
   item = create_item(:research_id => research.id, :html_type => @types.invert["pure_text"])

   count = item.item_values.length
   ivalue = create_item_value(:item_id => item.id, :info => nil)
   item.reload
   assert_equal count + 1, item.item_values.length   
   ivalue = create_item_value(:item_id => item.id, :info => "info")
   item.reload
   assert_equal count + 1, item.item_values.length   

   # Single selection item
   item = create_item(:research_id => research.id, :html_type => @types.invert["single_selection"])
   count = item.item_values.length
   ivalue = create_item_value(:item_id => item.id, :info => nil)
   item.reload
   assert_equal count, item.item_values.length   
   ivalue = create_item_value(:item_id => item.id, :info => "info")
   item.reload
   assert_equal count + 1, item.item_values.length   
 end

end
