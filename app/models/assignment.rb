class Assignment < ApplicationRecord
	has_many :assignment_users
	has_many :users, through: :assignment_users
end
