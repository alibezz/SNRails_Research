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

  def test_user_is_moderator
    r = create_research
    assert_equal false, @user.is_moderator?(r)
    @user.researches << r; @user.reload
    r.moderators << @user; r.reload
    assert @user.is_moderator?(r)
  end

  def test_my_researches
    admin = create_user(:is_administrator => true)
    r1 = create_research  
    r2 = create_research  
    r3 = create_research 

    @user.researches << r1; @user.reload
    r1.moderators << @user; r1.reload

    assert_equal Research.find(:all).count, admin.my_researches.count 
    assert_equal @user.researches.count, @user.my_researches.count 
  end 
end
