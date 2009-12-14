require File.dirname(__FILE__) + '/../test_helper'

class ResearchTest < Test::Unit::TestCase

  def test_presence_of_title
    research = Research.new
    research.valid?
    assert research.errors.invalid?(:title)
    research.title = "some"
    research.valid?
    assert !research.errors.invalid?(:title)
  end

  def test_presence_of_introduction
    research = Research.new
    research.valid?
    assert research.errors.invalid?(:introduction)
    research.introduction = "some"
    research.valid?
    assert !research.errors.invalid?(:introduction)
  end

  def test_presence_of_number_of_pages
    research = Research.new
    research.valid?
    assert !research.errors.invalid?(:number_of_pages)
    
    # Default number is 1
    research.number_of_pages = 1
    assert_equal 1, research.number_of_pages
  end

  def test_reorder_pages
    research = create_research
    create_item(:page_id => 1, :research => research) 
    create_item(:page_id => 1, :research => research) 
    create_item(:page_id => 1, :research => research) 

    create_item(:page_id => 2, :research => research) 
    create_item(:page_id => 2, :research => research) 

    assert_equal 5, research.items.find(:all).count
    assert 3, research.items.find(:all, :conditions => {:page_id => 1})
    assert 2, research.items.find(:all, :conditions => {:page_id => 2})
    
    research.reorder_pages([2,1])
   
    assert 2, research.items.find(:all, :conditions => {:page_id => 1})
    assert 3, research.items.find(:all, :conditions => {:page_id => 2})
  end

  def test_uniqueness_of_title
    create_research(:title => 'some')
    research = Research.new(:title => 'some')
    research.valid?
    assert research.errors.invalid?(:title)
    
    research = Research.new(:title => 'another')
    research.valid?
    assert !research.errors.invalid?(:title)
  end

  def test_should_not_be_private_by_default
    r = Research.new
    assert_equal false, r.is_private?
  end

  def test_should_be_private_when_defined
    r = create_research(:is_private => true)
    assert_equal true, Research.find(r.id).is_private?
  end

  def test_reorder_items
    research = create_research
    create_item(:position => 1, :research_id => research.id)
    create_item(:position => 2, :research_id => research.id)
    research.reload
    research.reorder_items(2); research.reload
    assert_equal research.items.first.position, 1 
    assert_equal research.items.last.position, 3 
    
  end

  def test_new_position_is_bigger_than_old_position
    research = create_research
    create_item(:position => 1, :research_id => research.id)
    create_item(:position => 2, :research_id => research.id)
    create_item(:position => 3, :research_id => research.id)
    research.reload
    research.update_positions(3, 1); research.reload
   
    assert_equal 1, research.items[0].position
    assert_equal 1, research.items[1].position
    assert_equal 2, research.items[2].position
    #Now, item with :position => 1 previously can be updated by the controller
  end

  def test_new_position_is_smaller_than_old_position
    research = create_research
    create_item(:position => 1, :research_id => research.id)
    create_item(:position => 2, :research_id => research.id)
    create_item(:position => 3, :research_id => research.id)
    research.reload
    research.update_positions(1, 3); research.reload
    
    assert_equal 2, research.items[0].position
    assert_equal 3, research.items[1].position
    assert_equal 3, research.items[2].position
    #Now, item with :position => 3 previously can be updated by the controller
  end

  def test_should_have_questions_to_be_active
    research = create_research
    research.is_active = true
    assert_equal false, research.save
  end

  def test_should_add_questions_only_if_inactive
    research = create_research
    create_item(:research_id => research.id)
    research.is_active = true; research.save
    count = research.items.count
    item = create_item
    assert_raise RuntimeError do
      raise research.items.push(item)
    end
    assert_equal count, research.items.count
    research.is_active = false; research.save
    create_item(:research_id => research.id)
    assert_equal count + 1, research.items.count

  end
  
  def test_some_items_should_have_alternatives_to_be_active
    research = create_research
    item = create_item(:research_id => research.id, :html_type => 1)
    research.reload
   
    research.is_active = true
    assert_equal false, research.save
    
    create_item_value(:item_id => item.id)
    item.reload; research.reload
    
    research.is_active = true
    assert_equal true, research.save
  end

  def test_number_of_max_answers_is_valid_to_be_active
    research = create_research
    # multiple selection item
    item = create_item(:research_id => research.id, :html_type => 0, :min_answers => 1, :max_answers => 2)
    create_item_value(:item_id => item.id)
    research.reload

    research.is_active = true
    assert_equal false, research.save

    create_item_value(:item_id => item.id)
    research.reload
    research.is_active = true
    assert_equal true, research.save

  end
end
