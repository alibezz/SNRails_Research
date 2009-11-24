require File.dirname(__FILE__) + '/../test_helper'

class QuestionnaireTest < Test::Unit::TestCase
  
  def setup
    @research = create_research
    @quest = create_questionnaire(:research_id => @research.id)
  end

  def test_associate_answer
    assert_equal 0, @quest.object_item_values.count
    @quest.associate({"1" =>"1"})
    @quest.reload
    assert_equal 1, @quest.object_item_values.count

    @quest.associate({"1" =>["1", "2"]})
    @quest.reload
    assert_equal 2, @quest.object_item_values.count
  end
end
