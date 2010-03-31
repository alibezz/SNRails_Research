class Survey::SurveysController < ResourceController::Base

  uses_tiny_mce
  
  before_filter :login_required

  before_filter :load_survey, :except => [:index, :new, :create]

  protect 'survey_viewing', :survey, :only => [:show]
  protect 'survey_editing', :survey, :only => [:edit, :update]
  protect 'survey_erasing', :survey, :only => [:destroy, :role_management, :new_member, :edit_member, :remove_member]

  def create
    @survey = Survey.new(params[:survey])
    if @survey.save
      @survey.set_moderator(current_user)
      redirect_to object_path(@survey)
    else
      render :action => 'new'
    end
  end

  def role_management
    @members = @survey.members(current_user)
    @non_members = @survey.non_members(current_user)
  end

  def new_member
    unless @survey.add_member(params[:user][:id], params[:role][:id])
      flash[:error] = I18n.t(:member_not_added)
    end
    redirect_to role_management_survey_survey_path(@survey)
  end

  def edit_member
    unless @survey.change_member_role(params[:user_id], params[:role][:id])
      flash[:error] = I18n.t(:role_not_updated)
    end
    redirect_to role_management_survey_survey_path(@survey)
  end

  def remove_member
    unless @survey.remove_member(params[:user_id])
      flash[:error] = I18n.t(:member_not_removed)
    end
    redirect_to role_management_survey_survey_path(@survey)
  end

private
  def collection
    @collection ||= current_user.my_surveys
  end
end
