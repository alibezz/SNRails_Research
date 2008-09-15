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

end
