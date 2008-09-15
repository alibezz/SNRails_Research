require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  def test_attr_is_default_is_false
    env = Environment.new
    assert_equal false, env.is_default
  end

  def test_load_default
    env = create_environment(:is_default => true )
    default = Environment.default
    assert_equal env, default
  end

end
