# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem
  include PermissionCheck
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '96e3e36e40be10cbdc44d00d4878b676'

  before_filter :load_environment

  design :holder => 'environment' 

  def load_environment
    self.class.design :holder => 'environment' 
    @environment = Environment.default
  end

  #FIXME make this test
  def load_research
    self.class.design :holder => 'research' 
    if !current_user.nil? and current_user.is_administrator?
        @research =  params[:research_id].nil? ? current_user.my_researches.find{ |i| i.id == params[:id].to_i }                                                            : current_user.my_researches.find{ |i| i.id == params[:research_id].to_i}
    else
      @research = params[:research_id].nil? ? Research.find(params[:id]) : Research.find(params[:research_id])
    end
    login_required if @research.is_private?

  end

  #FIXME make this test
  def load_items_position
    @positions = {}; @positions.merge!({"#{t(:in_the_beginning)}\n" => 1})

    unless @research.items.empty?
      @research.items.each { |item| @positions.merge!({"#{t(:after)} #{item.info} \n" => item.position + 1}) }
    end
  end
  
  #FIXME make this test
  def load_item
    @item = Item.find(params[:item_id]||params[:question_id])

  end

  #FIXME make this test
  def load_item_values_position
    @positions = {}; @positions.merge!({"#{t(:in_the_beginning)}\n" => 1})
    unless @item.item_values.empty?
      @item.item_values.each { |ivalue| @positions.merge!({"#{t(:after)} #{ivalue.info}\n" => ivalue.position + 1}) }
    end
  end

  def find_users
    @gusers = User.find(:all)
  end

  def check_permission?
    current_user.nil? ? true : !self.current_user.administrator?
  end

  def load_roles
    @roles = Role.find(:all)
  end
private

  def user
    self.current_user
  end
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
