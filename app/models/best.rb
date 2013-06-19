class Best < ActiveRecord::Base
  attr_accessible :scenario, :score, :sequence
  belongs_to :team
  belongs_to :design

  def self.ordered_by_standing
    order("score ASC, sequence ASC")
  end

  def self.for_review(categories, statuses)
    ordered_by_standing.joins(:team).where(:teams => { :category => categories, :status => statuses})
  end

  def self.for_local_contest_scoreboard(scenario = nil)
    join = ordered_by_standing.joins(:team)
    scenario.nil? ?
        join.where("scenario is null and teams.status <> 'r'") :
        join.where("scenario = ? and teams.status <> 'r'", scenario)
  end

  def self.for_national_scoreboard
    ordered_by_standing.joins(:team).where(:scenario => nil, :teams => { :status => 'a' })
  end

end
