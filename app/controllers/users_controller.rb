class UsersController < ApplicationController
  def index
    @assignments = Assignment.all.where(sent_to_users: true)
  end

  def upload_file
    user_assignment = current_user.assignment_users.find_by(assignment_id: params[:assignment_id])    
    if user_assignment.present?
      user_assignment.destroy
    end 
    @assignment_user = current_user.assignment_users.new(assignment_params)
    if @assignment_user.save
      flash[:notice] = 'File created successfully'
    else
      flash[:alert] = 'File not created successfully'
    end   
    redirect_to users_path  
  end

  private
    def assignment_params 
      params[:assignment_user].merge!(assignment_id: params[:assignment_id])
      params.require(:assignment_user).permit(:assignment_id, :file)
    end 
end
