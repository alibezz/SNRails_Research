require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase

  def setup
    @types = Question.html_types
    @survey = create_survey
  end


  def test_is_text
   question = create_item(:type => 'Question', :survey_id => @survey.id, :html_type => @types.invert["pure_text"])
   assert question.is_text?

   question = create_item(:type => 'Question', :survey_id => @survey.id, :html_type => @types.invert["single_selection"])
   assert_equal false, question.is_text?
  end

  def test_should_add_ivalues_only_if_survey_is_inactive

    item = create_item(:type => 'Question', :survey_id => @survey.id)
    @survey.reload
    @survey.is_active = true; @survey.save
    count = item.item_values.count
    ivalue = create_item_value
    assert_raise RuntimeError do
      raise item.item_values.push(ivalue)
    end
    assert_equal count, item.item_values.count
    @survey.is_active = false; @survey.save
    create_item_value(:item_id => item.id)
    @survey.reload; item.reload
    assert_equal count + 1, item.item_values.count

  end

  def test_min_before_max_answers
    # :html_type => 0 is equivalent to multiple_selection
    item = create_item(:type => 'Question', :survey_id => @survey.id, :html_type => 0)
    create_item_value(:item_id => item.id)
    create_item_value(:item_id => item.id)
    item.reload

    item.max_answers = 1; item.min_answers = 2
    assert_equal false, item.save
    item.max_answers = 2; item.min_answers = 1
    assert item.save
  end

   def test_define_answers_quantity
    item = create_item(:type => 'Question', :survey_id => @survey.id,                                                                           :html_type => Question.html_types.invert["single_selection"])

    create_item_value(:item_id => item.id)
    item.reload; item.save
    assert_equal 1, item.max_answers
    assert_equal 1, item.min_answers

    item.max_answers = 2; item.min_answers = 1; item.save; item.reload
    assert_equal 1, item.max_answers
    assert_equal 1, item.min_answers #No matter what you set, it will be (min=1,max=1) because it's a single selection.

    item2 = create_item(:type => 'Question', :survey_id => @survey.id,                                                                           :html_type => Question.html_types.invert["pure_text"])
    assert_equal 0, item2.max_answers
    assert_equal 0, item2.min_answers
  end

  def test_invalid_max_answers
    # :html_type => 0 is equivalent to multiple_selection
    item = create_item(:type => 'Question', :survey_id => @survey.id, :html_type => 0, :min_answers => 1, :max_answers => 2)
    assert_equal true, item.invalid_max_answers?

    create_item_value(:item_id => item.id)
    create_item_value(:item_id => item.id)
    item.reload
    assert_equal false, item.invalid_max_answers?
  end

  def test_validate_answers
    ob_question = create_item(:type => 'Question', :survey_id => @survey.id,                                                                           :html_type => Question.html_types.invert["single_selection"])
    create_item_value(:item_id => ob_question.id)
    ob_question.reload; ob_question.save

    assert_equal false, ob_question.validate_answers(["1", "2"]) #more than one answer
    assert_equal false, ob_question.validate_answers([]) #less than one answer
    assert_equal false, ob_question.validate_answers(nil) #less than one answer
    assert_equal true, ob_question.validate_answers("1") #one answer
    
    op_question =  create_item(:type => 'Question', :survey_id => @survey.id, :is_optional => true,                                                                          :html_type => Question.html_types.invert["single_selection"])
    create_item_value(:item_id => op_question.id)
    op_question.reload; op_question.save

    assert_equal false, op_question.validate_answers(["1", "2"]) #more than one answer
    assert_equal true, op_question.validate_answers([]) #less than one answer
    assert_equal true, op_question.validate_answers(nil) #less than one answer
    assert_equal true, op_question.validate_answers("1") #one answer
    

    text_question = create_item(:type => 'Question', :survey_id => @survey.id,                                                                           :html_type => Question.html_types.invert["pure_text"])
  
    assert_equal false, text_question.validate_answers({"info" => nil}) #no answer
    assert_equal false, text_question.validate_answers({"info" => ""}) #no answer
    assert_equal false, text_question.validate_answers({"info" => "        "}) #no answer
    assert_equal true, text_question.validate_answers({"info" => "    info    "}) #answer

    op_text_question = create_item(:type => 'Question', :survey_id => @survey.id, :is_optional => true,                                                                         :html_type => Question.html_types.invert["pure_text"])
  
    assert_equal true, op_text_question.validate_answers({"info" => nil}) #no answer
    assert_equal true, op_text_question.validate_answers({"info" => ""}) #no answer
    assert_equal true, op_text_question.validate_answers({"info" => "        "}) #no answer
    assert_equal true, op_text_question.validate_answers({"info" => "    info    "}) #answer
  end

  def test_validate_answers_presence
    text_question = create_item(:type => 'Question', :survey_id => @survey.id)

    assert_equal false, text_question.validate_answers_presence({"info" => ""})
    assert_equal false, text_question.validate_answers_presence({})
    assert_equal false, text_question.validate_answers_presence(nil)
    assert_equal true, text_question.validate_answers_presence({"info" => "an answer"})

    ss_question = create_item(:type => 'Question', :survey_id => @survey.id,                                                                           :html_type => Question.html_types.invert["single_selection"])
    assert_equal false, ss_question.validate_answers_presence([])
    assert_equal false, ss_question.validate_answers_presence(nil)
    assert_equal false, ss_question.validate_answers_presence("")
    assert_equal true, ss_question.validate_answers_presence("1")
  end

  def test_should_load_html_types
    assert_equal nil, Question.html_types.invert["section"]
  end

  def test_should_load_previous_questions
    i1 = create_item(:type => 'question', :page_id => 1, :position => 4, :survey_id => @survey.id)
    i2 = create_item(:type => 'question', :page_id => 2, :position => 1, :survey_id => @survey.id)
    i3 = create_item(:type => 'question', :page_id => 2, :position => 2, :survey_id => @survey.id)

    assert_equal i1.previous, []
    assert_equal i2.previous, [i1]
    assert_equal i3.previous, [i1, i2]
  end

  def test_should_load_only_free_alternatives
    i1 = create_item(:type => 'question', :page_id => 1, :position => 4, :survey_id => @survey.id)
    i2 = create_item(:type => 'question', :page_id => 2, :position => 1, :survey_id => @survey.id)
    alt1 = create_item_value(:item_id => i1.id)
    alt2 = create_item_value(:item_id => i1.id)
    
    assert_equal i1.free_alts(i2), i1.item_values
    
    alt1.conditionals << i2
    alt1.save!; alt2.save!; alt2.reload
    assert_equal i1.free_alts(i2), [alt2]
  end

  def test_should_remove_dependencies
    i1 = create_item(:type => 'question', :page_id => 1, :position => 4, :survey_id => @survey.id)
    i2 = create_item(:type => 'question', :page_id => 2, :position => 1, :survey_id => @survey.id)
    alt1 = create_item_value(:item_id => i1.id)
    alt2 = create_item_value(:item_id => i1.id)
    i2.dependencies << alt1; i2.dependencies << alt2
    i2.reload
    assert_equal i2.dependencies, [alt1, alt2]
    
    i2.remove_deps([alt1.id]); i2.reload
    assert_equal i2.dependencies, [alt2]
  end 
end
