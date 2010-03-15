class Admin::ItemValuesController < ResourceController::Base

  belongs_to :question

  before_filter :load_research, :only => :index
  before_filter :load_item
  before_filter :load_item_values_position

  index.before do
    #FIXME item_values should be kept sorted since their creation!!
    @item_values = @item.item_values.sort { |a,b| a.position <=> b.position }
  end

  new_action.before do
    @item_values = @item.item_values
  end

  def create
   #   @item.reorder_item_values(params[:item_value][:position].to_i)
    @item_value = ItemValue.new(params[:item_value].merge({:position => (@item.item_values.blank? ? 1 :                                        @item.item_values.maximum(:position) + 1)}))
    @item_value.item_id = params[:question_id]
    if @item_value.save
      flash[:notice] = I18n.t(:succesfully_saved)
    end
    redirect_to :action => 'new'
  end

  def reorder_item_values
    params["list_item_values"].each_with_index do |ivalue_id,position|
      ivalue = @item.item_values.find(ivalue_id)
      ivalue.position = position
      ivalue.save!
    end
    collection
    respond_to do |format|
      format.js
    end
  end

  update.before do
    @item.update_positions(params[:item_value][:position].to_i, ItemValue.find(params[:id]).position)
  end

  #FIXME Change something in the routes, so it can be solved following a pattern.
  def destroy
        @item_value = ItemValue.find(params[:id])
        @item_value.destroy
        @item = Item.find(params[:question_id])
        flash[:notice] = t(:successfully_removed) 
        redirect_to :action => 'new' 
  end

  def collection
    @collection ||= @research.questions.find(params[:question_id]).item_values
  end

end
