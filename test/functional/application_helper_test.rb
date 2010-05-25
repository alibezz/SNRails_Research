require File.dirname(__FILE__) + '/../test_helper'
require 'application_helper'

# Re-raise errors caught by the controller. 
class ApplicationHelperTestController <  ApplicationController

  def title
    render :inline => '<%= title("some title") %>'
  end

  def subtitle
    render :inline => '<%= subtitle("some subtitle") %>'
  end

end 

class ApplicationHelperTestController; def rescue_action(e) raise e end; end

class ApplicationHelperTest < Test::Unit::TestCase

  def setup
    @controller = ApplicationHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_title
    get :title
    assert_tag :tag => 'h1', :content => 'some title', :attributes => {:class => 'title'}
  end

  def test_subtitle
    get :subtitle
    assert_tag :tag => 'h2', :content => 'some subtitle', :attributes => {:class => 'subtitle'}
  end

end
