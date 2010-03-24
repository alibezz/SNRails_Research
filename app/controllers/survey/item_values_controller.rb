class Survey::ItemValuesController < ResourceController::Base

  belongs_to :question

  before_filter :load_survey, :only => [:index, :reorder_item_values, :edit]
  before_filter :load_item
  before_filter :load_item_values, :only => [:index, :reorder_item_values]

  protect 'survey_viewing', :survey, :only => [:index, :show]
  protect 'survey_editing', :survey, :only => [:reorder_item_values, :edit, :update, :destroy, :new, :create]  
 
  index.before do
    @item_value = ItemValue.new
  end

  def create
    @item_value = ItemValue.new(params[:item_value].merge({:position => (@item.item_values.blank? ? 1 :                                        @item.item_values.maximum(:position) + 1)}))
    @item_value.item_id = params[:question_id]
    if @item_value.save
      flash[:notice] = I18n.t(:succesfully_saved)
    end
    redirect_to survey_survey_question_item_values_path(@item.survey_id, @item)
  end

  def reorder_item_values
    item = Item.find(params[:question_id])
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

  def update
    @item_value = ItemValue.find(params[:id])
    if @item_value.update_attributes(params[:item_value])
       redirect_to survey_survey_question_item_values_path(@item.survey_id, @item)
    else
       render :action => 'edit', :question_id => @item.id, :id => @item_value.id 
    end
  end

  #FIXME Change something in the routes, so it can be solved following a pattern.
  def destroy
        @item_value = ItemValue.find(params[:id])
        @item_value.destroy
        @item = Item.find(params[:question_id])
        flash[:notice] = t(:successfully_removed) 
        redirect_to :action => 'index' 
  end

protected

  def collection
    @collection ||= @survey.questions.find(params[:question_id]).item_values
  end

  def survey
    Survey.find(@item.survey_id)
  end
end
