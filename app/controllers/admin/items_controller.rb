class Admin::ItemsController < ResourceController::Base

  belongs_to :research

  # Reorder the items definition according user definition.
  def reorder_items
    @research ||= Research.find(params[:research_id])
    @items = @research.items.paginate(:page => params[:page], :fixed_page => 5, :page_attr => :page_id )
    respond_to do |format|
      format.js 
    end
  end

  # Reorder the pages how the user definition.
  def reorder_pages
    @research ||= Research.find(params[:research_id])
    @items = @research.items.paginate(:page => params[:page], :fixed_page => 5, :page_attr => :page_id )
    respond_to do |format|
      format.js 
    end
  end

  private
  def collection
    @research ||= Research.find(params[:research_id])
    @collection = @research.items.paginate(:page => params[:page], :fixed_page => 5, :page_attr => :page_id )
  end

end
