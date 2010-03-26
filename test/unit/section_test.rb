require File.dirname(__FILE__) + '/../test_helper'

class SectionTest < Test::Unit::TestCase

  def test_sets_html_type_when_created
    s = Section.new
    assert_equal s.html_type, Section.html_types.invert["section"]
  end
end
