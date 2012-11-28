class Affiliation < ActiveRecord::Base
  belongs_to :team
  belongs_to :local_contest

  # validates :team, :uniqueness => { :scope => :local_contest }
end
