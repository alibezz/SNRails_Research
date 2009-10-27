class Admin::ItemValuesController < ResourceController::Base

  belongs_to :item

  def index
    @research = Research.find(params[:research_id])
  end
end
