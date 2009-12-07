class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  def new
    @questionnaire = Questionnaire.new
    @page = params[:page_id].nil? ? 1 : params[:page_id].to_i 
    flash[:answers] ||= {}
    flash[:answers] = flash[:answers].merge(params[:object_item_values]) unless params[:object_item_values].nil?
    @current_items = @research.items.find_all { |i| i.page_id == @page }
    if request.post? and @page > @research.items.maximum('page_id')
      create
    end 
  end

  def create
    @questionnaire = Questionnaire.new
    if @questionnaire.prepare_to_save(flash[:answers], params[:research_id].to_i)
     if @questionnaire.save
        flash[:notice] = t(:questionnaire_succesfully_saved)
        redirect_to research_url(params[:research_id].to_i)
      else
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end
end
