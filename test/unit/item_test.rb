require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  
  def setup
    @survey = create_survey
  end

  def test_should_belong_to_a_survey
   count = Item.count 
   item = create_item(:survey_id => nil)
   assert_equal count, Item.count
   
   item = create_item(:survey_id => @survey.id)
   assert_equal count + 1, Item.count
  end  

  def test_should_have_a_position
   
   assert @survey.items.empty?

   item = create_item(:survey_id => @survey.id, :position => nil)
   @survey.reload
   assert_equal [], @survey.items
   
   item = create_item(:survey_id => @survey.id, :position => @survey.items.length + 1)
   @survey.reload
   assert_equal 1, @survey.items.length
  end

  def test_should_have_an_info
   count = Item.count 
   
   create_item(:info => nil, :survey_id => @survey.id)
   assert_equal count, Item.count
   
   item = create_item(:info => "an info", :survey_id => @survey.id)
   assert_equal count + 1, Item.count
  end

  def test_should_update_survey_max_pages
   item = create_item(:survey_id => @survey.id, :page_id => 1)
   item2 = create_item(:survey_id => @survey.id, :page_id => 3)
   @survey.reload
   assert_equal @survey.number_of_pages, 2
  
   item.destroy
   @survey.reload
   assert_equal @survey.number_of_pages, 1
  end

  def test_should_define_position
    item = Question.new(:info => "a", :html_type => 0, :survey_id => @survey.id)
    item.define_position; item.save
    @survey.reload
    item2 = Question.new(:info => "b", :html_type => 0, :survey_id => @survey.id) 
    item2.define_position; item2.save
    @survey.reload 
    assert_equal item.position, 1
    assert_equal item2.position, 2
  end
end
