class PasswordReset < ActiveRecord::Base
  belongs_to :team
  validates :key, :uniqueness => true
end
