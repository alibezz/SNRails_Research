class Admin::QuestionsController < ResourceController::Base

  before_filter :load_research

  belongs_to :research

  private

  def model_name
    'item'
  end

  def object_name
    'item'
  end

end
