class Admin::ModeratorsController < ResourceController::Base

  belongs_to :research

#FIXME remove this informations
#  private
#
#  def collection
#    @research ||= Research.find(params[:research_id])
#    @collection = @research.items.paginate(:page => params[:page], :fixed_page => @research.number_of_pages, :page_attr => :page_id, :order => :position )
#  end

end
