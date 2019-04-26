class UsersController < ApplicationController

  require 'open3'
  require 'timeout'

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
      run_script(@assignment_user)
      if @timeout
        flash[:alert] = 'Assignment not saved successfully due to error in your code'
      else
        flash[:notice] = 'File created successfully'
      end
    elsif @assignment_user.file.blob.byte_size > 1000
      flash[:alert] = 'Assignment size should be less than or equal to 100kb'
    else
      flash[:alert] = 'Assignment not created successfully'
    end   
    redirect_to users_path  
  end

  def save_file_separate_folder
    assignment = Assignment.find_by(id: params[:assignment_user][:assignment_id])
    uploaded_io = params[:assignment_user][:file]
    dest_folder = "#{Rails.root}/temp/#{assignment.title}"
    FileUtils.mkdir_p(dest_folder) unless File.directory?(dest_folder)
    filename = ActiveStorage::Blob.service.path_for(assignment.assignment_users.first.file.blob.key)
    FileUtils.cp(filename, "#{dest_folder}/#{current_user.name}_#{uploaded_io.original_filename}")
  end

  def run_script(assignment_user)
    assignment         = Assignment.find_by(id: params[:assignment_user][:assignment_id])
    argument           = assignment.argument.present? ? assignment.argument : " "
    command            = assignment.command
    student_assignment = ActiveStorage::Blob.service.path_for(assignment_user.file.blob.key)
    grading_script     = ActiveStorage::Blob.service.path_for(assignment.grading_script_file.blob.key)
    FileUtils.cd("#{Rails.root}/temp/#{assignment.title}")
    command = "#{command} #{grading_script} #{argument} #{student_assignment}"
    begin
      stdout, stderr, status = Timeout::timeout(5) do
         Open3.capture3(command)
      end
      @timeout = false
    rescue Timeout::Error => e
      @timeout = true
    end
    if @timeout
      assignment_user.destroy
    else
      FileUtils.cd("#{Rails.root}")
      assignment_user.grade = stdout.to_f
      dest_folder = "#{Rails.root}/temp/#{assignment.title}/#{current_user.name}_#{assignment.title}_rubric"
      File.open(dest_folder, "w") { |file| file.puts "#{stderr}"}
      assignment_user.rubric.attach(
        io: File.open(dest_folder),
        filename: "#{current_user.name}_#{assignment.title}_rubric"
      )
      assignment_user.save

      uploaded_file = params[:assignment_user][:file]
      destination = "#{Rails.root}/public/#{assignment.title}"
      FileUtils.mkdir_p(destination) unless File.directory?(destination)

      filename = ActiveStorage::Blob.service.path_for(assignment.assignment_users.first.file.blob.key)
      FileUtils.cp(filename, "#{destination}/#{current_user.name}_#{uploaded_file.original_filename}")

      filename = ActiveStorage::Blob.service.path_for(assignment_user.rubric.blob.key)
      FileUtils.cp(filename, "#{destination}/#{current_user.name}_#{assignment.title}_rubric}")
    end
    return @timeout
  end

  private
    def assignment_params 
      params.require(:assignment_user).permit(:assignment_id, :file)
    end 
end
