class ItemsController < ResourceController::Base

  belongs_to :research

  def index
    @items = Item.find(:all) 
#render :text => @items.inspect
  end

  def bla
#    @items = Item.find(:all) 
#render :text => @items.inspect
render :text => 'testando bla'
  end

  def bli
    render :text => "testando bli"
  end

  private
  def collection
    @research ||= Research.find(params[:research_id])
   @collection = @research.items.paginate(:page => params[:page], :fixed_page => 5, :page_attr => :page_id )
  end
end
