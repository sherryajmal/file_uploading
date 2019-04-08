class Admin::UsersController < Admin::BaseController
	before_action :set_user, only: [:destroy]
	def index
		@users = User.user
	end

	def destroy
		if @user.destroy
      flash[:notice] = 'user successfully deleted'
    else
      flash[:alert]  = 'Error in deleting the user'
    end
    redirect_to admin_users_path
	end

	private

    def set_user
      @user = User.find params[:id]
    end
end
