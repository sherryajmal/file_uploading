class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :google_oauth2]

  enum role: [:user, :admin]  


  has_many :assignment_users, dependent: :destroy
  has_many :assignments, through: :assignment_users

  class << self
    def from_omniauth(auth)
      data = auth.info
      user = data.email.present? ? User.find_by(email: data.email, provider: auth.provider, uid: auth.uid) : nil
      if data.email.present? && user.blank?
        user = User.create(provider: auth.provider, uid: auth.uid, email: data.email, password: Devise.friendly_token[0, 20],
                           name: data.name, oauth_token: auth.credentials.token)
      end
      user
    end
  end  
end
