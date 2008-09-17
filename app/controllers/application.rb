# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '96e3e36e40be10cbdc44d00d4878b676'

  GetText.locale = 'pt_BR'
  init_gettext 'rails_research'

  before_filter :load_environment

  design :holder => 'environment' 

  def load_environment
    @environment = Environment.default
  end

  def load_research
    login_required
    self.class.design :holder => 'research' 
    if !current_user.nil? and current_user.is_administrator?
      @research = params[:research_id].nil? ? current_user.researches(params[:id]) : current_user.researches(params[:research_id])
    else
      @research = params[:research_id].nil? ? Research.find(params[:id]) : Research.find(params[:research_id])
    end
  end

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
