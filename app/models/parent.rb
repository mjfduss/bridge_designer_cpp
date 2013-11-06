class Parent < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :middle_initial
  belongs_to :member
  validates :email, :first_name, :last_name, :presence => true

  def full_name
    middle_initial.blank? ? "#{first_name} #{last_name}" : "#{first_name} #{middle_initial}. #{last_name}"
  end
end
