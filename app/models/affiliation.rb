class Affiliation < ActiveRecord::Base
  attr_accessible :team, :local_contest
  belongs_to :team
  belongs_to :local_contest
end
