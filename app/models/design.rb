class Design < ActiveRecord::Base
  attr_accessible :bridge, :scenario, :sequence, :hash_string, :submitted, :team_id, :score
  belongs_to :team

  validates :sequence, :uniqueness => true
  
end
