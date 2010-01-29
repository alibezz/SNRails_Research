class QuestionnairesController < ResourceController::Base
  belongs_to :research
  before_filter :load_research

  def new
    @questionnaire = Questionnaire.new

    if params[:commit].nil?
      @page = 1
    elsif /back/i =~ params[:commit]
      @page = params[:page_id].to_i - 1
    elsif /next/i =~ params[:commit] or /submit/i =~ params[:commit]
      @page = params[:page_id].to_i + 1
    end 

    flash[:answers] ||= {}
    #create a method called invalid? that evaluates the result
    flash[:answers] = flash[:answers].merge(params[:object_item_values]) unless params[:object_item_values].nil?
   
    @current_items = @research.questions.find_all { |i| i.page_id == @page }
    if request.post? and /submit/i =~ params[:commit]
      create
    end 
  end

  def create
    @questionnaire = Questionnaire.new
    if @questionnaire.prepare_to_save(flash[:answers], params[:research_id].to_i)
     if @questionnaire.save
        flash[:notice] = t(:succesfully_saved)
        redirect_to research_url(params[:research_id].to_i)
      else
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end

end
