class QuestionnairesController < ResourceController::Base
  belongs_to :survey
  before_filter :load_survey
  before_filter :publication_required
  #place this filter at the end
  before_filter :load_survey_design
  layout 'survey'

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
    flash[:answers] = flash[:answers].merge(params[:object_item_values]) unless params[:object_item_values].nil?

   @current_items = @survey.ordered_items(@survey.page_ids[@page])
   #FIXME Second arg isn't necessary, but makes testing easier. Change it.
   current_dependencies(flash[:answers], @current_items) 
 
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

protected unless Rails.env == "test"

  def current_dependencies(answers, items)
    alts = []; @data_deps = {}
    #FIXME Move the 3 lines below to a Module
    answers.invert.keys.each {|a|
      alts << a.to_i if a.kind_of?(String)
    }

    items.each { |item|
      @data_deps.merge!({item.id => item.needed_alts - alts}) if item.kind_of?(Question)
    }
    @data_deps
  end 
end
