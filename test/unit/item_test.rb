require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  
  def setup
    @types = Item.html_types
  end

  def test_should_belong_to_a_research
   count = Item.count 
   item = create_item(:research_id => nil)
   assert_equal count, Item.count
   
   research = create_research
   item = create_item(:research_id => research.id)
   assert_equal count + 1, Item.count
  end  

  def test_should_have_a_position
  
   research = create_research
   assert research.items.empty?

   count = research.items.length 
   item = create_item(:research_id => research.id, :position => nil)
   research.reload
   assert_equal count, research.items.length
   
   item = create_item(:research_id => research.id, :position => research.items.length + 1)
   research.reload
   assert_equal count + 1, research.items.length
  end

  def test_position_should_be_unique
   research = create_research
   count = research.items.length 
   
   item = create_item(:research_id => research.id, :position => count + 1)
   research.reload
   assert_equal item.position, count + 1
   assert_equal count + 1, research.items.length
   
   item = create_item(:research_id => research.id, :position => count  + 1)
   research.reload
   assert_equal count + 1, research.items.length #Second item wasn't created
  end
  
  def test_is_text
   research = create_research
   
   item = create_item(:research_id => research.id, :html_type => @types.invert["pure_text"])
   assert item.is_text? 

   item = create_item(:research_id => research.id, :html_type => @types.invert["single_selection"])
   assert_equal false, item.is_text? 
  end
end
