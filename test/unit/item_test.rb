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

   item = create_item(:research_id => @research.id, :position => nil)
   @research.reload
   assert_equal [], @research.items
   
   item = create_item(:research_id => @research.id, :position => @research.items.length + 1)
   @research.reload
   assert_equal 1, @research.items.length
  end

  def test_should_have_an_info
   count = Item.count 
   
   create_item(:info => nil, :research_id => @research.id)
   assert_equal count, Item.count
   
   item = create_item(:info => "an info", :research_id => @research.id)
   assert_equal count + 1, Item.count
  end

  def test_should_update_research_max_pages
   item = create_item(:research_id => @research.id, :page_id => 1)
   item2 = create_item(:research_id => @research.id, :page_id => 3)
   @research.reload
   assert_equal @research.number_of_pages, 2
  
   item.destroy
   @research.reload
   assert_equal @research.number_of_pages, 1
  end

  def test_should_define_position
    item = Question.new(:info => "a", :html_type => 0, :research_id => @research.id)
    item.define_position; item.save
    @research.reload
    item2 = Question.new(:info => "b", :html_type => 0, :research_id => @research.id) 
    item2.define_position; item2.save
    @research.reload 
    assert_equal item.position, 1
    assert_equal item2.position, 2
  end
end
