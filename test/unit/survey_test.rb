require File.dirname(__FILE__) + '/../test_helper'

class SurveyTest < Test::Unit::TestCase

  def test_presence_of_title
    survey = Survey.new
    survey.valid?
    assert survey.errors.invalid?(:title)
    survey.title = "some"
    survey.valid?
    assert !survey.errors.invalid?(:title)
  end

  def test_presence_of_introduction
    survey = Survey.new
    survey.valid?
    assert survey.errors.invalid?(:introduction)
    survey.introduction = "some"
    survey.valid?
    assert !survey.errors.invalid?(:introduction)
  end

  def test_presence_of_number_of_pages
    survey = Survey.new
    survey.valid?
    assert !survey.errors.invalid?(:number_of_pages)
    
    # Default number is 0; a survey is created without pages
    assert_equal 0, survey.number_of_pages
  end

  def test_reorder_pages
    survey = create_survey
    create_item(:page_id => 1, :survey => survey) 
    create_item(:page_id => 1, :survey => survey) 
    create_item(:page_id => 1, :survey => survey) 

    create_item(:page_id => 2, :survey => survey) 
    create_item(:page_id => 2, :survey => survey) 
    
    create_item(:page_id => 3, :survey => survey) 
    
    create_item(:page_id => 4, :survey => survey) 
    create_item(:page_id => 4, :survey => survey) 
    create_item(:page_id => 4, :survey => survey) 
    create_item(:page_id => 4, :survey => survey) 
    

    assert 3, survey.items.find(:all, :conditions => {:page_id => 1})
    assert 2, survey.items.find(:all, :conditions => {:page_id => 2})
    assert 1, survey.items.find(:all, :conditions => {:page_id => 3})
    assert 4, survey.items.find(:all, :conditions => {:page_id => 4})

    #downto

    survey.reorder_pages([3,1,2,4])
    assert 1, survey.items.find(:all, :conditions => {:page_id => 1})
    assert 3, survey.items.find(:all, :conditions => {:page_id => 2})
    assert 2, survey.items.find(:all, :conditions => {:page_id => 3})
    assert 4, survey.items.find(:all, :conditions => {:page_id => 4})

    #upto
    survey.reorder_pages([2,3,4,1])
   
    assert 3, survey.items.find(:all, :conditions => {:page_id => 1})
    assert 2, survey.items.find(:all, :conditions => {:page_id => 2})
    assert 4, survey.items.find(:all, :conditions => {:page_id => 3})
    assert 1, survey.items.find(:all, :conditions => {:page_id => 4})
    
    end


  def test_uniqueness_of_title
    create_survey(:title => 'some')
    survey = Survey.new(:title => 'some')
    survey.valid?
    assert survey.errors.invalid?(:title)
    
    survey = Survey.new(:title => 'another')
    survey.valid?
    assert !survey.errors.invalid?(:title)
  end

  def test_should_not_be_private_by_default
    r = Survey.new
    assert_equal false, r.is_private?
  end

  def test_should_be_private_when_defined
    r = create_survey(:is_private => true)
    assert_equal true, Survey.find(r.id).is_private?
  end

  def test_should_have_questions_to_be_active
    survey = create_survey
    survey.is_active = true
    assert_equal false, survey.save
  end

  def test_should_add_questions_only_if_inactive
    survey = create_survey
    create_item(:survey_id => survey.id)
    survey.is_active = true; survey.save
    count = survey.items.count
    item = create_item
    assert_raise RuntimeError do
      raise survey.items.push(item)
    end
    assert_equal count, survey.items.count
    survey.is_active = false; survey.save
    create_item(:survey_id => survey.id)
    assert_equal count + 1, survey.items.count

  end
  
  def test_some_items_should_have_alternatives_to_be_active
    survey = create_survey
    item = create_item(:type => "question", :survey_id => survey.id, :html_type => 1)
    survey.reload
   
    survey.is_active = true
    assert_equal false, survey.save
    
    create_item_value(:item_id => item.id)
    item.reload; survey.reload
    
    survey.is_active = true
    assert_equal true, survey.save
  end

  def test_number_of_max_answers_is_valid_to_be_active
    survey = create_survey
    # multiple selection item
    item = create_item(:type => "question", :survey_id => survey.id, :html_type => 0, :min_answers => 1, :max_answers => 2)
    create_item_value(:item_id => item.id)
    survey.reload

    survey.is_active = true
    assert_equal false, survey.save

    create_item_value(:item_id => item.id)
    survey.reload
    survey.is_active = true
    assert_equal true, survey.save
  end

  def test_load_correct_number_of_items_per_page
    r = create_survey
    i1 = create_item(:survey_id => r.id, :page_id => 1)   
    i2 = create_item(:survey_id => r.id, :page_id => 1)   
    i3 = create_item(:survey_id => r.id, :page_id => 2)
    
    assert_equal r.how_many_items(0), nil
    assert_equal r.how_many_items(nil), 2
    assert_equal r.how_many_items(1), 2
    assert_equal r.how_many_items(2), 1   
    assert_equal r.how_many_items(3), nil   
  end

  def test_select_members_of_a_survey
    User.destroy_all
    role = create_role(:name => "Moderator", :permissions => ['survey_viewing', 'survey_editing', 'survey_erasing']) 
    user1 = create_user(:login => 'susan', :administrator => true)
    r = create_survey(:user_id => user1.id)

    user2 = create_user(:login => 'julia', :administrator => false)
    user3 = create_user(:login => 'peter', :administrator => false)
    user4 = create_user(:login => 'samuel', :administrator => false)

  
    user2.add_role(role, r); user2.reload; r.reload

    assert_equal r.members, [user2]
    assert_equal r.members(user2), []
    assert_equal r.non_members, [user3, user4]
    assert_equal r.non_members(user4), [user3]
  end

  def test_add_member
    User.destroy_all

    role = create_role(:name => "Moderator", :permissions => ['survey_viewing', 'survey_editing', 'survey_erasing']) 
    user1 = create_user(:login => 'julia', :administrator => false)
    r = create_survey(:user_id => user1.id)
  
    assert_equal false, r.add_member(user1.id, role.id)
    assert_equal false, r.add_member(nil, role.id)
    assert_equal false, r.add_member(user1.id, nil)
  end

  def test_change_member_role
    User.destroy_all
    role = create_role(:name => "Moderator", :permissions => ['survey_viewing', 'survey_editing', 'survey_erasing']) 
    user1 = create_user
    r = create_survey(:user_id => user1.id)
    user2 = create_user(:login => 'julia', :administrator => false)
    user3 = create_user(:login => 'peter', :administrator => false)
    
    role2 = create_role(:name => "Editor", :permissions => ['survey_viewing', 'survey_editing']) 
    
    r.add_member(user2.id, role.id); r.reload; user2.reload
    assert r.change_member_role(user2.id, role2.id)
    assert_equal false, r.change_member_role(nil, role2.id)
    assert_equal false, r.change_member_role(user2.id, nil)
    assert r.change_member_role(user3.id, role.id)

    r.change_member_role(user1.id, role2.id)
    r.reload; user1.reload
  end

  def test_remove_member
    r = create_survey
    User.destroy_all

    user1 = create_user(:login => 'julia', :administrator => false)
    user2 = create_user(:login => 'peter', :administrator => false)
    
    role = create_role(:name => "Moderator",                                              :permissions => ['survey_viewing', 'survey_editing',                       'survey_erasing']) 
    r.add_member(user1.id, role.id); r.reload; user1.reload

    assert r.remove_member(user1.id)
    assert_equal false, r.remove_member(nil)
    assert_equal false, r.remove_member(user2.id)

  end

  def test_set_moderator
    r = create_survey
    user1 = create_user(:login => 'julia', :administrator => false)
    Role.destroy_all
    count = Role.find(:all).count
    r.set_moderator(user1)
    assert_equal Role.find(:all).count, count + 1

    Role.destroy_all
    role = create_role(:name => "Moderator",                                              :permissions => ['survey_viewing', 'survey_editing',                       'survey_erasing']) 

    user2 = create_user(:login => 'peter', :administrator => false)
    r.set_moderator(user2)
    user2.reload

    assert_equal user2.role_assignments.first.role_id, role.id 
  
    Role.destroy_all
    role2 = create_role(:name => "moderator",                                              :permissions => ['survey_viewing', 'survey_editing',                       'survey_erasing']) 

    user3 = create_user(:login => 'frankie', :administrator => false)
    r.set_moderator(user3)
    user3.reload

    assert_equal user3.role_assignments.first.role_id, role2.id 
  end

  def test_should_order_items
    r = create_survey
    i1 = create_item(:survey_id => r.id, :page_id => 1, :position => 2)   
    i2 = create_item(:survey_id => r.id, :page_id => 1, :position => 1)   
    i3 = create_item(:survey_id => r.id, :page_id => 2, :position => 3)
    r.reload

    assert_equal r.ordered_items(1).first, i2
    assert_equal r.ordered_items(1).last, i1
    assert_equal r.ordered_items(1).count, r.items.find_all{|i| i.page_id == 1 }.count
  end

  def test_should_get_public_surveys
    r1 = create_survey
    i1 = create_item(:survey_id => r1.id, :type => "question")   
    r1.save; r1.reload
    r1.is_private = true; r1.is_active = true 
    r1.save; r1.reload
    assert_equal Survey.public_surveys.count, 0

    r1.is_private = false
    r1.save; r1.reload

    assert_equal Survey.public_surveys.count, 1

  end

  def test_should_change_activation
    r1 = create_survey
    i1 = create_item(:survey_id => r1.id, :type => "question")
    r1.save; r1.reload
    
    r1.change_activation
    assert_equal r1.is_active, true

    r1.change_activation
    assert_equal r1.is_active, false
  end

  def test_should_select_items_per_page
    s = create_survey
    i0 = create_item(:survey_id => s.id, :page_id => 1, :position => 1)
    i1 = create_item(:survey_id => s.id, :page_id => 1, :position => 2)
    i2 = create_item(:survey_id => s.id, :page_id => 2, :position => 1)

    assert_equal s.page_items(nil), [i0, i1]
    assert_equal s.page_items(1), [i0, i1]
    assert_equal s.page_items(2), [i2]
  end

  def test_should_destroy_items
    s = create_survey; s2 = create_survey(:title => "other title") 
    i0 = create_item(:type => "Section", :survey_id => s.id, :page_id => 1, :position => 1)
    i1 = create_item(:survey_id => s.id, :page_id => 1, :position => 2)
    i2 = create_item(:survey_id => s.id, :page_id => 1, :position => 3)
    i3 = create_item(:type => "Section", :survey_id => s.id, :page_id => 1, :position => 4)

    i4 = create_item(:survey_id => s.id, :page_id => 2, :position => 1)
    i5 = create_item(:survey_id => s2.id, :page_id => 1, :position => 1)

    s.reload; s2.reload

    s.destroy_items(i0.position, i3.position, 1)
    s.reload; s2.reload

    assert_equal s.items, [i4, i3]
    assert_equal s2.items, [i5]
  end

  def test_last_page_question
    s = create_survey; s2 = create_survey(:title => "other title")
    i0 = create_item(:type => "Section", :survey_id => s.id, :page_id => 1, :position => 1)
    i1 = create_item(:type => "question", :survey_id => s.id, :page_id => 1, :position => 2)
    i2 = create_item(:type => "question", :survey_id => s.id, :page_id => 1, :position => 3)
    i3 = create_item(:type => "question", :survey_id => s.id, :page_id => 2, :position => 3)

    i4 = create_item(:type => "Section", :survey_id => s2.id, :page_id => 1, :position => 1)

    s.reload; s2.reload
    assert_equal s.last_page_question(i0), i2
    assert_equal s2.last_page_question(i4), i4
    assert_equal s.last_page_question(i3), i3
  end

  def test_next_section
    s = create_survey
    i0 = create_item(:type => "section", :survey_id => s.id, :page_id => 1, :position => 1)
    i1 = create_item(:type => "question", :survey_id => s.id, :page_id => 1, :position => 2)
    i2 = create_item(:type => "section", :survey_id => s.id, :page_id => 1, :position => 3)
    i3 = create_item(:type => "section", :survey_id => s.id, :page_id => 2, :position => 1)
    i4 = create_item(:type => "question", :survey_id => s.id, :page_id => 2, :position => 2)
 
    s.reload
    assert_equal s.next_section(i2), i2
    assert_equal s.next_section(i0), i2
    assert_equal s.next_section(i3), i4 
  end

  def test_remove_section_items
    s = create_survey
    i0 = create_item(:type => "section", :survey_id => s.id, :page_id => 1, :position => 1)
    i1 = create_item(:type => "question", :survey_id => s.id, :page_id => 1, :position => 2)
    i2 = create_item(:type => "section", :survey_id => s.id, :page_id => 1, :position => 3)
    i3 = create_item(:type => "question", :survey_id => s.id, :page_id => 1, :position => 4)
    i4 = create_item(:type => "question", :survey_id => s.id, :page_id => 1, :position => 5)
 
    s.reload
    s.remove_section_items(i0.id); s.reload
    assert_equal s.items, [i2,i3,i4]
    s.remove_section_items(i2.id); s.reload
    assert s.items.blank?
  end

  def test_creator_moderates
    user = create_user
    s = create_survey(:user_id => user.id)
    s.reload
    assert_equal s.role_assignments.first.accessor_id, user.id
    assert_equal s.role_assignments.first.id, Role.first.id
    assert_equal Role.first.name, "Moderator"
  end

  def test_section_items
    s = create_survey
    sec0 = create_item(:survey_id => s.id, :type => "section") 
    sec1 = create_item(:survey_id => s.id, :type => "section") 
    q1 = create_item(:survey_id => s.id, :type => "question") 
    sec2 = create_item(:survey_id => s.id, :type => "section") 

    assert_equal s.section_items(q1.id), []
    assert_equal s.section_items(sec1.id), [sec1, q1]
    assert_equal s.section_items(sec0.id), [sec0]
    assert_equal s.section_items(sec2.id), [sec2]
  end

  def test_section
    s = create_survey
    sec = create_item(:survey_id => s.id, :type => "section")
    assert !s.section(sec.id).blank?
    assert_equal s.section(sec.id), sec
    assert !s.section(sec.id + 1)
  end
end
