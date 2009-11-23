class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  update.before do
    require 'pp'
    pp params
  end
end
