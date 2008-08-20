class ItemsController < ApplicationController
  resource_controller

  belongs_to :research

#  def index
#@research = Research.find(params[:research_id])
#@items = @research.items
#@items = Item.find(:all, :conditions => {:research_id => params[:research_id]})
#render :text => @items.inspect
#render :text => params.inspect
#  end

end
