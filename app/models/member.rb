class Member < ActiveRecord::Base
  attr_accessible :age, :category, :city, :first_name, :grade, :hispanic
  attr_accessible :last_name, :middle_initial, :phone, :race, :school, 
  attr_accessible :school_city, :sex, :state, :street, :zip
  belongs_to :team
end
