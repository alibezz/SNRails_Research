class Admin::ResearchesController < ResourceController::Base

  before_filter :login_required

  before_filter :load_research, :except => [:index, :new, :create]
#  protect 'research_editing', :foo #, :except => [:destroy, :new, :index, :create]
# protect 'research_erasing', :only => [:destroy]

#  def foo
#    Research.first
#  end
end
