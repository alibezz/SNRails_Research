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
    
    # Default number is 0; a research is created without pages
    assert_equal 0, research.number_of_pages
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

    #downto

    research.reorder_pages([3,1,2,4])
    assert 1, research.items.find(:all, :conditions => {:page_id => 1})
    assert 3, research.items.find(:all, :conditions => {:page_id => 2})
    assert 2, research.items.find(:all, :conditions => {:page_id => 3})
    assert 4, research.items.find(:all, :conditions => {:page_id => 4})

    #upto
    research.reorder_pages([2,3,4,1])
   
    assert 3, research.items.find(:all, :conditions => {:page_id => 1})
    assert 2, research.items.find(:all, :conditions => {:page_id => 2})
    assert 4, research.items.find(:all, :conditions => {:page_id => 3})
    assert 1, research.items.find(:all, :conditions => {:page_id => 4})
    
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

  def test_select_members_of_a_research
    r = create_research
    User.destroy_all

    user1 = create_user(:login => 'susan', :administrator => true)
    user2 = create_user(:login => 'julia', :administrator => false)
    user3 = create_user(:login => 'peter', :administrator => false)
    user4 = create_user(:login => 'samuel', :administrator => false)

    role = create_role(:name => "Moderator",                                              :permissions => ['research_viewing', 'research_editing',                       'research_erasing']) 
  
    user2.add_role(role, r); user2.reload; r.reload

    assert_equal r.members, [user2]
    assert_equal r.members(user2), []
    assert_equal r.non_members, [user3, user4]
    assert_equal r.non_members(user4), [user3]
  end

  def test_add_member
    r = create_research
    User.destroy_all

    user1 = create_user(:login => 'julia', :administrator => false)

    role = create_role(:name => "Moderator",                                              :permissions => ['research_viewing', 'research_editing',                       'research_erasing']) 
  
    assert r.add_member(user1.id, role.id)
    assert_equal false, r.add_member(user1.id, role.id)
    assert_equal false, r.add_member(nil, role.id)
    assert_equal false, r.add_member(user1.id, nil)
  end

  def test_change_member_role
    r = create_research
    User.destroy_all

    user2 = create_user(:login => 'julia', :administrator => false)
    user3 = create_user(:login => 'peter', :administrator => false)

    role = create_role(:name => "Moderator",                                              :permissions => ['research_viewing', 'research_editing',                       'research_erasing']) 
    
    role2 = create_role(:name => "Editor",                                                 :permissions => ['research_viewing', 'research_editing']) 
    
    r.add_member(user2.id, role.id); r.reload; user2.reload
    assert r.change_member_role(user2.id, role2.id)
    assert_equal false, r.change_member_role(nil, role2.id)
    assert_equal false, r.change_member_role(user2.id, nil)
    assert r.change_member_role(user3.id, role.id)
  end

  def test_remove_member
    r = create_research
    User.destroy_all

    user1 = create_user(:login => 'julia', :administrator => false)
    user2 = create_user(:login => 'peter', :administrator => false)
    
    role = create_role(:name => "Moderator",                                              :permissions => ['research_viewing', 'research_editing',                       'research_erasing']) 
    r.add_member(user1.id, role.id); r.reload; user1.reload

    assert r.remove_member(user1.id)
    assert_equal false, r.remove_member(nil)
    assert_equal false, r.remove_member(user2.id)

  end
end
