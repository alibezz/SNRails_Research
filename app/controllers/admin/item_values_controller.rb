class Admin::ItemValuesController < ResourceController::Base

  belongs_to :item

  before_filter :load_research, :only => :index

  index.before do
    @item_values = @research.items.find(params[:item_id]).item_values
  end

  new_action.before do
     @item =  Item.find(params[:item_id])
  end    

  show.before do
    @item = Item.find(params[:item_id])
  end
 
  def collection
    @collection ||= @research.items.find(params[:item_id]).item_values
  end

end
