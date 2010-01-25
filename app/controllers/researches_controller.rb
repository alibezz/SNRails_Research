class ResearchesController < ResourceController::Base

  before_filter :load_research, :only => :show

  def show
    if !current_user.nil? and current_user.is_moderator?(@research)
      redirect_to admin_research_path(@research)
    end
  end

  private
  def collection
     Research.find(:all, :conditions => {:is_active => true})
  end
#
end
