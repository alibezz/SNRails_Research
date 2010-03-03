class Admin::ItemsController < ResourceController::Base

  belongs_to :research
  before_filter :load_research
  before_filter :load_items_position

  new_action.before do
    # @item_type is "question" by default
    @item_type = params[:item_type].nil? ? "question" : params[:item_type]
  end

  def create
    #@research.reorder_items(params[:item][:position].to_i)
    params[:item_type] == "question" ? @item = Question.new(params[:item]) : @item = Section.new(params[:item])
    @item.research_id = params[:research_id].to_i
    @item.define_position
     
    if request.post? and @item.save
      redirect_to admin_research_item_path(@research, @item) 
    else
      #TODO: error message
      redirect_to :action => "new"
    end
  end

  edit.before do
    @item_type = params[:item_type].nil? ? "question" : params[:item_type]
  end


  # Reorder the items definition according to user definition.
  def reorder_items
    @research ||= Research.find(params[:research_id]) #FIXME get the research by user
    params["list_items"].each_with_index do |item_id,position|
      item = @research.items.find(item_id)
      item.position = position
      item.save!
    end
    collection
    respond_to do |format|
      format.js 
    end
  end

  # Reorder the pages how the user definition.
  def reorder_pages
    @research ||= Research.find(params[:research_id]) #FIXME put specific user
    @research.reorder_pages(params[:page_links])
    collection
    respond_to do |format|
      format.js 
    end
  end

#  # Put an item on a page.
#  def set_item_to_page
#    @research ||= Research.find(params[:research_id]) #FIXME put specific user
#    item = @research.items.find(params[:id].split("_").last)
#    @page_sent = params[:page_sent].split("_").last
#    item.page_id = @page_sent
#    item.save
#    collection
#    respond_to do |format|
#      format.js 
#    end
#  end

  private

  def collection
    page = params[:page] || 1
    @research.items.find(:all, :conditions => {:page_id => page}, :order => :position)
  end

end
