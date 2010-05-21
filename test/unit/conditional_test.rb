require File.dirname(__FILE__) + '/../test_helper'

class ConditionalTest < ActiveSupport::TestCase
  test "load_operators" do
    assert_equal ActiveRecord::Base::Conditional::OPERATORS.invert.map, Conditional.operators
  end
end
