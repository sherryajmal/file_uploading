class Admin::AssignmentsController < Admin::BaseController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy, :sent_to_users]

  def index
    @assignments = Assignment.all
  end

  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save
      dir = "#{Rails.root}/public/#{@assignment.title}"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      redirect_to admin_assignments_path, notice: 'Assignment successfully created'
    else
      render :new
    end
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to admin_assignments_path, notice: 'Assignment successfully updated'
    else
      render :edit
    end
  end

  def show
    @assignment_users = @assignment.assignment_users
  end

  def destroy
    if @assignment.destroy
      flash[:notice] = 'Assignment successfully deleted'
    else
      flash[:alert]  = 'Error in deleting the assignment'
    end
    redirect_to admin_assignments_path
  end

  def sent_to_users
    @assignment.update(sent_to_users: true)
    redirect_to admin_assignments_path, notice: 'Assignment sent to all users'
  end

  private

    def set_assignment
      @assignment = Assignment.find params[:id]
    end

    def assignment_params
      params.require(:assignment).permit(:title, :description, :due_date)
    end
end
