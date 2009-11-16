class Admin::ItemValuesController < ResourceController::Base

  belongs_to :item

  before_filter :load_research, :only => :index
  before_filter :load_item
  before_filter :load_item_values_position

  index.before do
    #FIXME item_values should be kept sorted since their creation!!
    @item_values = @item.item_values.sort { |a,b| a.position <=> b.position }
  end

  create.before do
    @item.reorder_item_values(params[:item_value][:position].to_i)
  end

  update.before do
    require 'pp'
    pp  ItemValue.find(params[:id]).position
    @item.update_positions(params[:item_value][:position].to_i, ItemValue.find(params[:id]).position)
  end


  def collection
    @collection ||= @research.items.find(params[:item_id]).item_values
  end

end
