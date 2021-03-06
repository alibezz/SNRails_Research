ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def create_survey(params = {})
    s = Survey.create(survey_params(params))
  end
  
  def survey_params(params = {})
   user = User.first || create_user
   {
      :title => 'some survey',
      :introduction => 'some survey',
      :number_of_pages => 1,
      :user_id => user.id
    }.merge(params)
  end

  def create_item(params = {})
    unless params[:type].nil?
      params[:type].downcase == 'question' ? Question.create(item_params(params)) : Section.create(item_params(params))
    else
      Item.create(item_params(params))
    end
  end
  
  def item_params(params = {})
    {
      :info => 'some survey',
      :html_type => Item.html_types.invert["pure_text"],
      :position => Item.count + 1
    }.merge(params)
  end

  def create_item_value(params = {})
    ItemValue.create(item_value_params(params))
  end
  
  def item_value_params(params = {})
    {
      :position => ItemValue.count + 1
    }.merge(params)
  end

  def create_environment(params = {})
    @environment = Environment.new({ :is_default => false,
                                     :design_data => {
                                       :template => "default",
                                       :theme => "default",
                                       :icon_theme => "default" }}.merge(params))
    @environment.save!
    @environment
  end
  
  def create_user(params = {})
    User.create!(user_params(params))
  end
  
  def user_params(params = {})
    {
      :login => 'some',
      :password => 'somepass',
      :password_confirmation => 'somepass',
      :email => params[:login].nil? ? 'myemail@something.com' : params[:login] + '@something.com',
      :administrator => false
    }.merge(params)
  end

  def create_questionnaire(params = {})
    Questionnaire.create(questionnaire_params(params))
  end

  def questionnaire_params(params = {})
    {    
    }.merge(params)
  end

  def create_role(params = {})
    Role.find_by_name(params[:name]) || Role.create({:name => "testrole"}.merge(params))
  end

  def create_conditional(question_id, alt_id, relation=0)
    Conditional.create(:relation => relation, :question_id => question_id, :item_value_id => alt_id)
  end

  # Sets the current user in the session from the user fixtures.
  def login_as(login)
    user = User.find_by_login(login)
    unless user.nil?
      @request.session[:user_id] = login ? user.id : nil
    else
      @request.session[:user_id] = login ? users(login).id : nil
    end
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
  end
  

end
