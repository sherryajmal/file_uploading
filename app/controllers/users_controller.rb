class UsersController < ApplicationController
  def index
    @assignments = Assignment.all.where(sent_to_users: true)
  end

  def upload_file
    user_assignment = current_user.assignment_users.find_by(assignment_id: params[:assignment_user][:assignment_id])    
    if user_assignment.present?
      user_assignment.destroy
    end 
    @assignment_user = current_user.assignment_users.new(assignment_params)
    if @assignment_user.save
      save_file_separate_folder
      flash[:notice] = 'File created successfully'
    else
      flash[:alert] = 'File not created successfully'
    end   
    redirect_to users_path  
  end

  def save_file_separate_folder
    assignment = Assignment.find_by(id: params[:assignment_user][:assignment_id])
    uploaded_io = params[:assignment_user][:file]
    File.open(Rails.root.join('public', "#{assignment.title}", "#{current_user.name}_#{uploaded_io.original_filename}"), 'wb') do |file|
      file.write(uploaded_io.read)
    end
  end

  private
    def assignment_params 
      params.require(:assignment_user).permit(:assignment_id, :file)
    end 
end
