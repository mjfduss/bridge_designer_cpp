class Group < ActiveRecord::Base

  default_scope order("description ASC")

  attr_accessible :description

  has_many :teams

  validates :description, :uniqueness => true, :length => { :maximum => 40 }

end
