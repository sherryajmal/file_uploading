class UsersController < ApplicationController
	def index
		@assignments = Assignment.all.where(sent_to_users: true)
	end
end
