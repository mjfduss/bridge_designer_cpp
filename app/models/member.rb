class Member < ActiveRecord::Base
  attr_accessible :first_name, :middle_initial, :last_name
  attr_accessible :category, :age, :grade, :phone
  attr_accessible :street, :city, :state, :zip
  attr_accessible :school, :school_city, :school_state
  attr_accessible :sex, :hispanic, :race
  
  belongs_to :team

  validates :first_name, :presence => true, :length => { :maximum => 40 }
  validates :last_name, :presence => true, :length => { :maximum => 40 }
end
