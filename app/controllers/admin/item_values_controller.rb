class Admin::ItemValuesController < ResourceController::Base

  belongs_to :item

  index.before do
    @research = Research.find(params[:research_id])
    @item_values = @research.items.find(params[:item_id]).item_values
  end
end
