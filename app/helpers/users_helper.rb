module UsersHelper
	def user_assignment(assignment)
		assignment.assignment_users.find_by(user_id: current_user.id)&.file
	end

  def user_rubric(assignment)
    assignment.assignment_users.find_by(user_id: current_user.id)&.rubric
  end
end
