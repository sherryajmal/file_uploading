class ApplicationController < ActionController::Base
  before_action :user_is_logged_in?
  def user_is_logged_in?
    if params[:state].blank? && current_user.blank?
  		redirect_to user_oktaoauth_omniauth_authorize_path
  	end
  end

  def after_sign_in_path_for(resource)
  	request.env['omniauth.origin'] || root_path
  end
end
