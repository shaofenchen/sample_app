#This file need to be encoded as UTF-8 to get annotate to work
# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#  remember_token  :string(255)
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :public_flag
  before_save { |user| user.email = email.downcase }
  has_secure_password
  
  before_save :create_remember_token 
  #This arranges for Rails to look for a method called create_remember_token 
  #and run it before saving the user
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  
  
    private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
	  #without self the assignment would create a local variable called remember_token, 
	  #which isnt what we want at all. Using self ensures that assignment sets the users remember_token 
	  #so that it will be written to the database along with the other attributes when the user is saved.
    end
end
