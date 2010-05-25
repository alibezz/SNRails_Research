class PublicController < ResourceController::Base

  before_filter :load_survey, :only => :show
  before_filter :publication_required, :only => :show
  #place this filter at the end
  before_filter :load_survey_design, :only => :show

  show.wants.html{ render :action => 'show', :layout => 'survey'}

  private

  def model_name
    'survey'
  end

  def collection
     @surveys = Survey.public_surveys
  end
end
