class Admin::ItemValuesController < ResourceController::Base

  belongs_to :item

  before_filter :load_research, :only => :index
  before_filter :load_item
  
  before_filter :load_item_values_position

  index.before do
    @item_values = @item.item_values
  end

  create.before do
    require 'pp'
    pp params
    @item.reorder_item_values(params[:item_value][:position].to_i)
  end

  def collection
    @collection ||= @research.items.find(params[:item_id]).item_values
  end

end
