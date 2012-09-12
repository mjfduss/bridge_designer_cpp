class Design < ActiveRecord::Base
  attr_accessible :bridge, :scenario, :sequence, :submitted, :team_id, :score
  belongs_to :team

  
end
