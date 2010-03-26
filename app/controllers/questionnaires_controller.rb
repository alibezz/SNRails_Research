class QuestionnairesController < ResourceController::Base
  belongs_to :survey
  before_filter :load_survey
  before_filter :load_survey_design

  def new
    @questionnaire = Questionnaire.new

    if params[:commit].nil?
       @page = 0
    elsif /back/i =~ params[:commit]
      @page = params[:page_id].to_i - 1
    elsif /next/i =~ params[:commit]      
      @page = params[:page_id].to_i + 1  
    elsif /submit/i =~ params[:commit]
      @page = params[:page_id].to_i
    end 
    flash[:answers] ||= {}  
    #FIXME create a method called invalid? that evaluates the result
    flash[:answers] = flash[:answers].merge(params[:object_item_values]) unless params[:object_item_values].nil?

    @current_items = @survey.items.find_all { |i| i.page_id == @survey.page_ids[@page] }
   if request.post? and /submit/i =~ params[:commit]
      create
   end 
  end

  def create
    @questionnaire = Questionnaire.new
    saved = @questionnaire.prepare_to_save(flash[:answers], params[:public_id].to_i)
    if not saved or not @questionnaire.save
      flash[:answers] = flash[:answers]
      render :action => 'new'
    else
      flash[:notice] = t(:succesfully_saved)
      redirect_to public_url(params[:public_id].to_i)
    end
  end

end
