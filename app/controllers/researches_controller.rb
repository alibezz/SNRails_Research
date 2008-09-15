class ResearchesController < ApplicationController

  before_filter :load_research, :only => :show

  def load_research
    self.class.design :holder => 'research' 
    @research = Research.find(params[:id])
    login_required
  end

  resource_controller

  actions :index, :show

end
