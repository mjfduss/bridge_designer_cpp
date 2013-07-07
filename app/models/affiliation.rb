class Affiliation < ActiveRecord::Base
  belongs_to :team
  belongs_to :local_contest, :counter_cache => true

  # validates :team, :uniqueness => { :scope => :local_contest }
end
