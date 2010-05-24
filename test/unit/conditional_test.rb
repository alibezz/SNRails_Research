require File.dirname(__FILE__) + '/../test_helper'

class ConditionalTest < ActiveSupport::TestCase
  def setup
    @s = create_survey
    @q1 = create_item(:type => 'question', :survey_id => @s.id)
    @q2 = create_item(:type => 'question', :survey_id => @s.id)
    @alt1 = create_item_value(:item_id => @q1.id)

  end
  test "should stringify relation" do
    @q2.create_dependency(@alt1, "0")
    assert Conditional.stringify_relation(@q2, @alt1).index("of ")
    assert_nil Conditional.stringify_relation(@q2, @alt1).index("to ")
    
    @q2.remove_deps([@alt1.id]); @q2.reload
    @q2.create_dependency(@alt1, "1")
    assert Conditional.stringify_relation(@q2, @alt1).index("to ")
    assert_nil Conditional.stringify_relation(@q2, @alt1).index("of ")
  end

  test "should validate presence of relation" do
    count = Conditional.count
    create_conditional(@q2.id, @alt1.id, nil)
    assert_equal count, Conditional.count
    create_conditional(@q2.id, @alt1.id)
    assert_equal count + 1, Conditional.count
  end

  test "should validate uniqueness of conditional" do
    count = Conditional.count
    create_conditional(@q2.id, @alt1.id)
    assert_equal count + 1, Conditional.count
  
    create_conditional(@q2.id, @alt1.id)
    assert_equal count + 1, Conditional.count
  end
end
