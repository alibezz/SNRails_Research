class Survey::ItemsController < ResourceController::Base

  belongs_to :survey
  before_filter :load_survey
  
  protect 'survey_viewing', :survey, :only => [:index, :show]
  protect 'survey_editing', :survey, :only => [:new, :create, :edit, :update, :reorder_items, :reorder_pages, :destroy]

  new_action.before do
    # @item_type is "question" by default
    @item_type = params[:item_type].blank? ? "question" : params[:item_type]
  end

  def create
    params[:item_type] == "question" ? @item = Question.new(params[:item]) : @item = Section.new(params[:item])
    @item.survey_id = params[:survey_id].to_i
    @item.define_position
    
    if request.post? and @item.save
      redirect_to survey_survey_item_path(@survey, @item) 
    else
      #TODO: error message
      redirect_to :action => "new", :item_type => params[:item_type]
    end
  end

  edit.before do
    @item_type = params[:item_type].blank? ? "question" : params[:item_type]
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      redirect_to survey_survey_item_path(@survey, @item) 
    else
      redirect_to :action => "edit", :item_type => @item.type.blank? ? "question" : @item.type.downcase
    end
  end

  def reorder_items
    @survey ||= Survey.find(params[:survey_id]) 
    params["list_items"].each_with_index do |item_id,position|
      item = @survey.items.find(item_id)
      item.position = position
      item.save!
    end
    collection
    respond_to do |format|
      format.js 
    end
  end

  def reorder_pages
    @survey ||= Survey.find(params[:survey_id])
    @survey.reorder_pages(params[:page_links])
    collection
    respond_to do |format|
      format.js 
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    redirect_to :action => 'index'
  end

private 

  def parent_object
    Survey.find(params[:survey_id])
  end
  
  def collection
    unless params[:page].blank?
      page = params[:page]
    else
      page = @survey.items.blank? ? 1 : @survey.items.minimum(:page_id)
    end  
    @survey.items.find(:all, :conditions => {:page_id => page}, :order => :position)
  end

end