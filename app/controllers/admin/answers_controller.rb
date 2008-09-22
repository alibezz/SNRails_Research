class Admin::AnswersController < ResourceController::Base

  before_filter :load_research
  before_filter :load_item

end
