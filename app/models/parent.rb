class Parent < ActiveRecord::Base
  include ValidationHelper
  attr_accessible :email, :first_name, :last_name, :middle_initial
  belongs_to :member
  validates :first_name, :last_name, :presence => true
  validates :email, :presence => true, :format => { :with => Team::VALID_EMAIL_ADDRESS }
  def full_name
    middle_initial.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{middle_initial}. #{last_name}"
  end
end
