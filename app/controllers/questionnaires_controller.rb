class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

end
