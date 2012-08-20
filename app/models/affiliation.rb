class Affiliation < ActiveRecord::Base
  belongs_to :team
  belongs_to :local_contest
end
