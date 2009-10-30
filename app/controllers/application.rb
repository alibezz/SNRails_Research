# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '96e3e36e40be10cbdc44d00d4878b676'

  before_filter :load_environment

  design :holder => 'environment' 

  def load_environment
    @environment = Environment.default
  end

  #FIXME make this test
  def load_research
    self.class.design :holder => 'research' 
    if !current_user.nil? and current_user.is_administrator?
      @research = params[:research_id].nil? ? current_user.my_researches(params[:id]).first : current_user.my_researches(params[:research_id]).first
    else
      @research = params[:research_id].nil? ? Research.find(params[:id]) : Research.find(params[:research_id])
    end

    login_required if @research.is_private?

  end

  #FIXME make this test
  def load_item
    @item = @research.items.find(params[:item_id]||params[:question_id])

  end

  def find_users
    @gusers = User.find(:all)
  end

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
