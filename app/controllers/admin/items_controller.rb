class Admin::ItemsController < ResourceController::Base

  belongs_to :research

  # Reorder the items definition according user definition.
  def reorder_items
    @research ||= Research.find(params[:research_id]) #FIXME get the research by user
    params["list_items"].each_with_index do |item_id,position|
      item = @research.items.find(item_id)
      item.position = position
      item.save!
    end
    @items = @research.items.paginate(:page => params[:page], :fixed_page => @research.number_of_pages, :page_attr => :page_id, :order => :position )
    respond_to do |format|
      format.js 
    end
  end

  # Reorder the pages how the user definition.
  def reorder_pages
    @research ||= Research.find(params[:research_id]) #FIXME put specific user
    @research.reorder_pages(params[:page_items])

    @items = @research.items.paginate(:page => params[:page], :fixed_page => @research.number_of_pages, :page_attr => :page_id, :order => :position)
    respond_to do |format|
      format.js 
    end
  end

  # Put the a item on a page.
  def set_item_to_page
    @research ||= Research.find(params[:research_id]) #FIXME put specific user

#    @research.reorder_pages(params[:page_items])

    @items = @research.items.paginate(:page => params[:page], :fixed_page => @research.number_of_pages, :page_attr => :page_id, :order => :position)
    respond_to do |format|
      format.js 
    end
  end

  private

  def collection
    @research ||= Research.find(params[:research_id])
    @collection = @research.items.paginate(:page => params[:page], :fixed_page => @research.number_of_pages, :page_attr => :page_id, :order => :position )
  end

end
