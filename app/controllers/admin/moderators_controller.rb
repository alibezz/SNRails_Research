class Admin::ModeratorsController < ResourceController::Base

  actions :index, :new, :create

  before_filter :load_research

  belongs_to :research

  create.response do |wants|
    wants.html {redirect_to collection_url}
  end

  create.after do
    @research.moderator_permissions.create(:user => object)
  end

  def index
    @users = User.find(:all)
  end

  private

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
