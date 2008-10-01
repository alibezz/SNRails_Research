class Admin::AnswersController < ResourceController::Base

  belongs_to [:research, :item]

end
