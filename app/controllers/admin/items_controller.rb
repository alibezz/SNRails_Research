class Admin::ItemsController < ResourceController::Base

  belongs_to :research

 #FIXME Install ARTS to test methods below

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

  # Put the a item on a page.
  def set_item_to_page
    @research ||= Research.find(params[:research_id]) #FIXME put specific user
    item = @research.items.find(params[:id].split("_").last)
    @page_sent = params[:page_sent].split("_").last
    item.page_id = @page_sent
    item.save
    collection
    respond_to do |format|
      format.js 
    end
  end

  private

  def collection
  #  @research ||= Research.find(params[:research_id])
    @research.items.paginate(:page => params[:page], :per_page => @research.number_of_pages,  :order => :position )
  end

end
