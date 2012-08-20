class LocalContest < ActiveRecord::Base
  has_many :affiliations
  has_many :teams, :through => :affiliations
end
