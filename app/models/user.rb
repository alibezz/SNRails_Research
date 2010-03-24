require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

#  # HACK HACK HACK -- how to do attr_accessible from here?
#  # prevents a user from submitting a crafted form that bypasses activation
#  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation

#XXXcaiotiago: is there any security implication?
  attr_accessible :administrator

  acts_as_accessor
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def my_surveys(params = {})
    if self.is_administrator? 
      Survey.find(:all, params) 
    else
      survey_ids = self.role_assignments.map(&:resource_id).uniq
      Survey.find(:all, :conditions => ["id IN (#{survey_ids.join(',')})"])
    end
  end

  def is_administrator?
    self.administrator?
  end

  def is_collaborator?(survey)
    self.has_role("Collaborator", survey)
  end

  def is_moderator?(survey)
    self.has_role("Moderator", survey)
  end

protected

  def has_role(role, survey)
    assignment = self.role_assignments.find_by_resource_id(survey.id)
    unless assignment.blank?
      return Role.find(assignment.role_id).name == role ||                                                                         Role.find(assignment.role_id).name == role.downcase 
    end
  end
end
