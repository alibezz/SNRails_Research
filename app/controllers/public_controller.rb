class PublicController < ResourceController::Base

  before_filter :load_research, :only => :show

  private

  def model_name
    'research'
  end

  def collection
     @researches = Research.find(:all, :conditions => {:is_active => true})
  end
end
