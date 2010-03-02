require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  
  def setup
    @research = create_research
  end

  def test_should_belong_to_a_research
   count = Item.count 
   item = create_item(:research_id => nil)
   assert_equal count, Item.count
   
   item = create_item(:research_id => @research.id)
   assert_equal count + 1, Item.count
  end  

  def test_should_have_a_position
   
   assert @research.items.empty?

   count = @research.items.length 
   item = create_item(:research_id => @research.id, :position => nil)
   @research.reload
   assert_equal count, @research.items.length
   
   item = create_item(:research_id => @research.id, :position => @research.items.length + 1)
   @research.reload
   assert_equal count + 1, @research.items.length
  end

  def test_should_have_an_info
   count = Item.count 
   
   create_item(:info => nil, :research_id => @research.id)
   assert_equal count, Item.count
   
   item = create_item(:info => "an info", :research_id => @research.id)
   assert_equal count + 1, Item.count
  end

  def test_should_update_research_max_pages
   item = create_item(:info => "an info", :research_id => @research.id)
   max_pages = @research.number_of_pages

   item.page_id = max_pages + 1
   item.save; @research.reload

   assert_equal @research.number_of_pages, item.page_id
   
   item.page_id = max_pages
   item.save; @research.reload
   
   assert_equal @research.number_of_pages,max_pages
  end
end
