class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:oktaoauth]

  enum role: [:user, :admin]  


  has_many :assignment_users, dependent: :destroy
  has_many :assignments, through: :assignment_users

  class << self
    def from_omniauth(auth)
      user = User.find_or_create_by(email: auth['info']['email']) do |user|
        user.provider = auth['provider']
        user.uid      = auth['uid']
        user.email    = auth['info']['email']
      end
    end
  end  
end
