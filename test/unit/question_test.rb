require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase
  
  def test_should_have_info
    research = create_research

    count = research.items.length
    question = Question.create(:research_id => research.id, :info => nil, :position => count + 1)
    research.reload
    assert_equal count, research.items.length	

    question = create_item(:type => 'question', :research_id => research.id, :info => 'info')
    research.reload
    assert_equal count + 1, research.items.length	
  end
end
