class Admin::UsersController < ResourceController::Base

  def new
    @user = AdminViewUser.new
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
end
