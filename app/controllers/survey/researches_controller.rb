class Survey::ResearchesController < ResourceController::Base

  before_filter :login_required

  before_filter :load_research, :except => [:index, :new, :create]
#  protect 'research_editing', :research, :only => [:edit, :update]
#  protect 'research_erasing', :research, :only => [:destroy]

  def role_management
    @members = @research.members(current_user)
    @non_members = @research.non_members(current_user)
  end

  def new_member
    unless @research.add_member(params[:user][:id], params[:role][:id])
      flash[:error] = I18n.t(:member_not_added)
    end
    redirect_to role_management_survey_research_path(@research)
  end

  def edit_member
    unless @research.change_member_role(params[:user_id], params[:role][:id])
      flash[:error] = I18n.t(:role_not_updated)
    end
    redirect_to role_management_survey_research_path(@research)
  end

  def remove_member
    unless @research.remove_member(params[:user_id])
      flash[:error] = I18n.t(:member_not_removed)
    end
    redirect_to role_management_survey_research_path(@research)
  end

end
