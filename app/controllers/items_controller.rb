class ItemsController < ResourceController::Base

  belongs_to :research

  private
  def collection
    @research ||= Research.find(params[:research_id])
    @collection = @research.items.paginate(:per_page => 1, :page => params[:page] )
  end
end
