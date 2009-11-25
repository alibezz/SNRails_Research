class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  update.before do
   @questionnaire.associate(params[:object_item_values])
  end

end
