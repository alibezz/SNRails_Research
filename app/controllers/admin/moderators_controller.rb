class Admin::ModeratorsController < ResourceController::Base

  actions :index, :new, :create, :show, :edit, :update, :destroy

  before_filter :load_research
  before_filter :find_users, :only => [:index, :show, :edit, :update]

  belongs_to :research

  create.response do |wants|
    wants.html {redirect_to collection_url}
  end

  create.after do
    @research.moderator_permissions.create(:user => object)
  end

  private

  def find_users
    @users = User.find(:all)
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
