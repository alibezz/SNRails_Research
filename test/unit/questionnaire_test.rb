require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < Test::Unit::TestCase
  
  def setup
    @research = create_research
  end

  def test_validate_obligatory_questions
    i1 = create_item(:research_id => @research.id, :info => "q1", :is_optional => false) #obligatory
    ivalue1 = create_item_value(:item_id => i1.id)
 
    i2 = create_item(:research_id => @research.id, :info => "q2", :is_optional => false) #obligatory
    ivalue2 = create_item_value(:item_id => i2.id)

    i3 = create_item(:research_id => @research.id, :info => "q3", :is_optional => true)
    ivalue3 = create_item_value(:item_id => i3.id)
    
    i1.reload; i2.reload; i3.reload; @research.reload
    
    quest = Questionnaire.new
    quest.validate_obligatory_questions({}, @research.id)
    assert_equal 2, quest.errors.length

    quest2 = Questionnaire.new
    quest2.validate_obligatory_questions({i1.id.to_s => ivalue1.id.to_s}, @research.id)
    assert_equal 1, quest2.errors.length

    quest3 = Questionnaire.new
    quest3.validate_obligatory_questions({i1.id.to_s => ivalue1.id.to_s, i2.id.to_s => ivalue2.id.to_s}, @research.id)
    assert_equal 0, quest3.errors.length

    quest4 = Questionnaire.new
    quest4.validate_obligatory_questions({i1.id.to_s => ivalue1.id.to_s, i2.id.to_s => ivalue2.id.to_s, i3.id.to_s => ivalue3.id.to_s}, @research.id)
    assert_equal 0, quest4.errors.length

  end
 
  def test_associate_answer
    quest = create_questionnaire(:research_id => @research.id)
    assert_equal 0, quest.object_item_values.count
    quest.associate({"1" =>"1"})
    quest.reload
    assert_equal 1, quest.object_item_values.count

    quest.associate({"1" =>["1", "2"]})
    quest.reload
    assert_equal 2, quest.object_item_values.count

    quest2 = create_questionnaire
    quest2.associate({"1" => ["1", "2"]})
    quest2.reload
    quest.associate({"1" => "2"})
    quest.reload
    assert_equal 1, quest.object_item_values.count
    assert_equal 2, quest2.object_item_values.count
  end
 
 
end
