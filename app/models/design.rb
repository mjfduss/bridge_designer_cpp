class Design < ActiveRecord::Base
  attr_accessible :bridge, :scenario, :sequence, :submitted, :team_id
  belongs_to :team
end
