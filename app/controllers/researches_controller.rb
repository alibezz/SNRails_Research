class ResearchesController < ResourceController::Base

  before_filter :load_research, :only => :show

  private
  def collection
     Research.find(:all, :conditions => {:is_active => true})
  end
#
end
