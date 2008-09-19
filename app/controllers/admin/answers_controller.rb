class Admin::AnswersController < ResourceController::Base

  before_filter :load_research

  belongs_to :item

end
