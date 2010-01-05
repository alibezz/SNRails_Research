require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < Test::Unit::TestCase
  
  def setup
    @research = create_research
  
    @i1 = create_item(:type => "question", :research_id => @research.id, :info => "q1", :is_optional => false) #obligatory
    @ivalue1 = create_item_value(:item_id => @i1.id)
 
    @i2 = create_item(:type => "question", :research_id => @research.id, :info => "q2", :is_optional => false) #obligatory
    @ivalue2 = create_item_value(:item_id => @i2.id)

    @i3 = create_item(:type => "question", :research_id => @research.id, :info => "q3", :is_optional => true)
    @ivalue3 = create_item_value(:item_id => @i3.id)
    @ivalue4 = create_item_value(:item_id => @i3.id)
    
    @i1.reload; @i2.reload; @i3.reload; @research.reload
    
  end

  def test_validate_obligatory_questions
    quest = Questionnaire.new
    quest.validate_obligatory_questions({}, @research.id)
    assert_equal 2, quest.errors.length

    quest2 = Questionnaire.new
    quest2.validate_obligatory_questions({@i1.id.to_s => @ivalue1.id.to_s}, @research.id)
    assert_equal 1, quest2.errors.length

    quest3 = Questionnaire.new
    quest3.validate_obligatory_questions({@i1.id.to_s => @ivalue1.id.to_s, @i2.id.to_s => @ivalue2.id.to_s}, @research.id)
    assert_equal 0, quest3.errors.length

    quest4 = Questionnaire.new
    quest4.validate_obligatory_questions({@i1.id.to_s => @ivalue1.id.to_s, @i2.id.to_s => @ivalue2.id.to_s, @i3.id.to_s => @ivalue3.id.to_s}, @research.id)
    assert_equal 0, quest4.errors.length

  end
 
  def test_associate_answers

    @i3.html_type = 0 #multiple selection
    @i2.html_type = 1 #single selection

    @i2.save; @i3.save; @i2.reload; @i3.reload

    quest = create_questionnaire(:research_id => @research.id)
    assert_equal 0, quest.object_item_values.count
    quest.associate({@i1.id.to_s => {"info" => "an answer"}, @i2.id.to_s => @ivalue2.id.to_s})
    quest.reload
    assert_equal 2, quest.object_item_values.count

    quest.associate({@i3.id.to_s => [@ivalue3.id.to_s, @ivalue4.id.to_s]})
    quest.reload
    assert_equal 4, quest.object_item_values.count
  end

  def test_prepare_to_save
    quest = Questionnaire.new    
    assert quest.prepare_to_save({@i1.id.to_s => @ivalue1.id.to_s, @i2.id.to_s => @ivalue2.id.to_s, @i3.id.to_s => @ivalue3.id.to_s}, @research.id)
    quest.save; quest.reload
    assert_equal false, quest.incomplete
    assert_equal quest.object_item_values.count, 3

    quest2 = Questionnaire.new    
    assert_equal false, quest2.prepare_to_save({@i1.id.to_s => @ivalue1.id.to_s, @i3.id.to_s => @ivalue3.id.to_s}, @research.id)
  end 
 
end
