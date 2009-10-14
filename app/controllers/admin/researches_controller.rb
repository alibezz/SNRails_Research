class Admin::ResearchesController < ResourceController::Base

  before_filter :login_required

  before_filter :load_research, :except => [:index, :new, :create]

  #FIXME make this test
  def moderators
  end
end
