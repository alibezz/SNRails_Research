require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < Test::Unit::TestCase
  
  def setup
    @research = create_research

    @i1 = create_item(:type => 'Question', :research_id => @research.id, :info => "q1", :is_optional => false,                                     :html_type => Question.html_types.invert["single_selection"])
    @ivalue1 = create_item_value(:item_id => @i1.id)
    @i1.reload; @i1.save 

 
    @i2 = create_item(:type => 'Question', :research_id => @research.id, :info => "q2", :is_optional => false,                                     :html_type => Question.html_types.invert["single_selection"])
    @ivalue2 = create_item_value(:item_id => @i2.id)
    @i2.reload; @i2.save 


    @i3 = create_item(:type => 'Question', :research_id => @research.id, :info => "q3", :is_optional => true,                                     :html_type => Question.html_types.invert["single_selection"])
    @ivalue3 = create_item_value(:item_id => @i3.id)
    @ivalue4 = create_item_value(:item_id => @i3.id)
    @i3.reload; @i3.save 
    @research.reload
    
  end

  def test_validate_obligatory_questions
    @i1.html_type = Question.html_types.invert["pure_text"]
    @i1.save; @i1.reload

    obligatory = @research.questions.find_all { |q| q.is_optional == false}
    quest = Questionnaire.new
    quest.validate_obligatory_questions(obligatory, {})
    assert_equal 2, quest.errors.length

    quest2 = Questionnaire.new
    quest2.validate_obligatory_questions(obligatory, {@i1.id.to_s => {"info" => "an info"}})
    assert_equal 1, quest2.errors.length

    quest3 = Questionnaire.new
    quest3.validate_obligatory_questions(obligatory, {@i1.id.to_s =>  {"info" => "an info"}, @i2.id.to_s => @ivalue2.id.to_s})
    assert_equal 0, quest3.errors.length

    quest4 = Questionnaire.new
    quest4.validate_obligatory_questions(obligatory, {@i1.id.to_s => {"info" => "an info"}, @i2.id.to_s => @ivalue2.id.to_s, @i3.id.to_s => @ivalue3.id.to_s})
    assert_equal 0, quest4.errors.length

    quest5 = Questionnaire.new
    quest5.validate_obligatory_questions(obligatory, {@i1.id.to_s => {"info" => ""}, @i2.id.to_s => @ivalue2.id.to_s})
    assert_equal 1, quest5.errors.length
  end
 
  def test_associate_answers
    @i1.html_type = Question.html_types.invert["pure_text"]
    @i3.html_type = Question.html_types.invert["multiple_selection"]
    @i2.html_type = Question.html_types.invert["single_selection"]

    @i1.save; @i2.save; @i3.save
    @i1.reload; @i2.reload; @i3.reload

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

  def test_validate_questions
    quest = create_questionnaire(:research_id => @research.id)
    quest.validate_questions({}, @research.id)
    quest.reload
    assert_equal quest.errors.count, 1 
    
    quest2 = create_questionnaire(:research_id => @research.id)
    quest2.validate_questions({@i1.id.to_s => @ivalue1.id.to_s, @i2.id.to_s => @ivalue2.id.to_s, @i3.id.to_s => @ivalue3.id.to_s}, @research.id)
    quest2.reload
    assert_equal quest2.errors.count, 0 
  end

  def test_validate_answers
    @i1.html_type = Question.html_types.invert["pure_text"]
    @i1.save; @i1.reload
    quest = create_questionnaire(:research_id => @research.id)
    quest.validate_answers([@i1, @i2], {@i1.id.to_s => {:info => ""}, @i2.id.to_s => ""})
    quest.reload
    assert_equal quest.errors.count, 2
  end 
end
