class Group < ActiveRecord::Base
  attr_accessible :description
  has_many :teams
end
