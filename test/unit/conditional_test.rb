require File.dirname(__FILE__) + '/../test_helper'

class ConditionalTest < ActiveSupport::TestCase
  test "should_stringify_relation" do
    s = create_survey
    q1 = create_item(:type => 'question', :survey_id => s.id)
    q2 = create_item(:type => 'question', :survey_id => s.id)
    alt1 = create_item_value(:item_id => q1.id)
    q2.create_dependency(alt1, "0")
    assert Conditional.stringify_relation(q2, alt1).index("of ")
    assert_nil Conditional.stringify_relation(q2, alt1).index("to ")
    
    q2.remove_deps([alt1.id]); q2.reload
    q2.create_dependency(alt1, "1")
    assert Conditional.stringify_relation(q2, alt1).index("to ")
    assert_nil Conditional.stringify_relation(q2, alt1).index("of ")
  end
end
