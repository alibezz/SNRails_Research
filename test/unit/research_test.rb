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
    
    create_item(:page_id => 3, :research => research) 
    
    create_item(:page_id => 4, :research => research) 
    create_item(:page_id => 4, :research => research) 
    create_item(:page_id => 4, :research => research) 
    create_item(:page_id => 4, :research => research) 
    

    assert 3, research.items.find(:all, :conditions => {:page_id => 1})
    assert 2, research.items.find(:all, :conditions => {:page_id => 2})
    assert 1, research.items.find(:all, :conditions => {:page_id => 3})
    assert 4, research.items.find(:all, :conditions => {:page_id => 4})

    research.reorder_pages([4,3,2,1])
   
    assert 3, research.items.find(:all, :conditions => {:page_id => 2})
    assert 2, research.items.find(:all, :conditions => {:page_id => 3})
    assert 1, research.items.find(:all, :conditions => {:page_id => 4})
    assert 4, research.items.find(:all, :conditions => {:page_id => 1})
    
    research.reorder_pages([2,3,4,1])

    assert 3, research.items.find(:all, :conditions => {:page_id => 1})
    assert 2, research.items.find(:all, :conditions => {:page_id => 2})
    assert 1, research.items.find(:all, :conditions => {:page_id => 3})
    assert 4, research.items.find(:all, :conditions => {:page_id => 4})
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
    item = create_item(:type => "question", :research_id => research.id, :html_type => 1)
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
    item = create_item(:type => "question", :research_id => research.id, :html_type => 0, :min_answers => 1, :max_answers => 2)
    create_item_value(:item_id => item.id)
    research.reload

    research.is_active = true
    assert_equal false, research.save

    create_item_value(:item_id => item.id)
    research.reload
    research.is_active = true
    assert_equal true, research.save
  end

  def test_load_correct_number_of_items_per_page
    r = create_research
    i1 = create_item(:research_id => r.id, :page_id => 1)   
    i2 = create_item(:research_id => r.id, :page_id => 1)   
    i3 = create_item(:research_id => r.id, :page_id => 2)
    
    assert_equal r.how_many_items(0), nil
    assert_equal r.how_many_items(nil), 2
    assert_equal r.how_many_items(1), 2
    assert_equal r.how_many_items(2), 1   
    assert_equal r.how_many_items(3), nil   
  end
end
