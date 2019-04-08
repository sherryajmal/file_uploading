class UsersController < ApplicationController
	def index
	  @assignments = Assignment.all.where(sent_to_users: true)
	end

	def upload_file
	  user_assignment = AssignmentUser.find_by(assignment_id: params[:assignment_id], user_id: current_user.id) 		
	  if user_assignment.present?
	  	user_assignment.destroy
	  end	
	  @assignment_user = AssignmentUser.new(assignment_params)
	  @assignment_user.user_id       = current_user.id
	  @assignment_user.assignment_id = params[:assignment_id]
	  @assignment_user.submit_date   = Time.now
	  if @assignment_user.save
	  	redirect_to users_path
	    flash[:notice] = 'File created successfully'
	  else
	  	flash[:alert] = 'File not created successfully'
	    redirect_to users_path	
	  end  	
	end

	private
	  def assignment_params 
	    params.require(:assignment_user).permit(:assigment_id, :file)
	  end	
end
