require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper

  def setup
    User.delete_all
    @user = create_user(:login => 'quentin', :password => 'monkey', :password_confirmation => 'monkey')
  end

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = User.new(user_params(:login => nil))
      u.valid?
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = User.new(user_params(:password => nil))
      u.valid?
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = User.new(user_params(:password_confirmation => nil))
      u.valid?
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = User.new(user_params(:email => nil))
      u.valid?
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    @user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal @user, User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    @user.update_attributes(:login => 'quentin2')
    assert_equal @user, User.authenticate('quentin2', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal @user, User.authenticate('quentin', 'monkey')
  end

  def test_should_set_remember_token
    @user.remember_me
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
  end

  def test_should_unset_remember_token
    @user.remember_me
    assert_not_nil @user.remember_token
    @user.forget_me
    assert_nil @user.remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    @user.remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
    assert @user.remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    @user.remember_me_until time
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
    assert_equal @user.remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    @user.remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil @user.remember_token
    assert_not_nil @user.remember_token_expires_at
    assert @user.remember_token_expires_at.between?(before, after)
  end

  def test_my_surveys
    admin = create_user(:administrator => true)
    assert_equal Survey.find(:all).count, admin.my_surveys.count 
    
    r1 = create_survey  
    r2 = create_survey(:title => "other test")  
    role = create_role(:name => "Collaborator", :permissions => ['survey_viewing'])
    role2 = create_role(:name => "Editor", :permissions => ['survey_viewing', 'survey_editing'])

    @user.add_role(role, r1)
    @user.add_role(role, r2)
    @user.reload
    assert_equal @user.my_surveys.count, 2
    @user.add_role(role2, r2)
    @user.reload

    assert_equal @user.my_surveys.count, 2

  end 

  def test_is_administrator
    admin = create_user(:administrator => true)
    assert admin.is_administrator?
    User.destroy_all
    user = create_user
    assert_equal false, user.is_administrator?    
  end

  def test_has_role
    r1 = create_survey  
    r2 = create_survey(:title => "other test")  
    role = create_role(:name => "Collaborator", :permissions => ['survey_viewing'])
    role2 = create_role(:name => "Moderator", :permissions => ['survey_viewing', 'survey_editing', 'survey_erasing'])
    
    user = create_user
    user.add_role(role, r1)
    user.add_role(role2, r2)
    user.reload

    assert user.is_moderator?(r2)
    assert user.is_moderator?(r2.id)
    assert user.is_collaborator?(r1)
    assert user.is_collaborator?(r1.id)

    r3 = create_survey(:title => "test3")
    assert !user.is_moderator?(r1)
    assert !user.is_collaborator?(r2)
    assert !user.is_moderator?(r3)
    assert !user.is_collaborator?(r3)
  end
end
