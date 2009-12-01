class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  #FIXME before_create
#  create.before do
#    Questionnaire.validate_obligatory_questions(params[:object_item_values], params[:research_id].to_i)
 # end

  #FIXME after_create
  create.after do
    @questionnaire.associate(params[:object_item_values])
  end

  create.wants.html { redirect_to research_path(@research) }

  def update_page
  end
end
