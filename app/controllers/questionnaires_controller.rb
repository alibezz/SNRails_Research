class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  create.after do
   @questionnaire.associate(params[:object_item_values])
  end

  create.wants.html { redirect_to research_path(@research) }
end
