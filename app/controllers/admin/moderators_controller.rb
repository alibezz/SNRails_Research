class Admin::ModeratorsController < ResourceController::Base

  actions :index, :new, :create, :show, :edit, :update, :destroy

  before_filter :load_research
  before_filter :find_users, :only => [:index, :new, :show, :edit, :update]
  before_filter :load_moderators, :only => [:index, :new]

  belongs_to :research

  create.response do |wants|
    wants.html {redirect_to collection_url}
  end

  def update
    params[:moderator_ids].each { |moderat|
      #XXXcaiotiago: TODO revoke attributes
      user = User.find(moderat)
      @research.moderator_permissions.create(:user => user, :is_moderator => true)
    }
    redirect_to :action => :index
  end

  private

  def load_moderators
    @moderators = @research.moderators
  end

  def attribute
  end

  def model_name
    'user'
  end

  def object_name
    'user'
  end

  def collection
    @collection ||= @research.moderators
  end

end
