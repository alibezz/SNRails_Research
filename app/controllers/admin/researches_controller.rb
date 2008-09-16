class Admin::ResearchesController < ResourceController::Base

  before_filter :load_research, :except => :index

  #FIXME make this test
  def moderators
    @users = @research.moderators
  end

end
