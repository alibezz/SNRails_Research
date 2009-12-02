class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  def create
    require 'pp'
    pp params[:questionnaire]
    @questionnaire = Questionnaire.new
    @questionnaire.validate_obligatory_questions(params[:object_item_values], params[:research_id].to_i)
    if @questionnaire.errors.empty?
      @questionnaire.research_id = params[:research_id].to_i
      @questionnaire.associate(params[:object_item_values])
      @questionnaire.incomplete = false
      if @questionnaire.save
        flash[:notice] = t(:questionnaire_succesfully_saved)
        redirect_to research_url(params[:research_id].to_i)
      end
    else
      render :action => 'new'
    end
  end

  def update_page
  end
end
