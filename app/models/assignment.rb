class Assignment < ApplicationRecord
	has_many :assignment_users, dependent: :destroy
	has_many :users, through: :assignment_users

	validates_uniqueness_of :title
end
