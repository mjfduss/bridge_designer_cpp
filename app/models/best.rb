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

  # Return a hash from local contest code to best entry for that contest (nil if none).
  # The keys of the hash are in alpha order of local contest code.
  def self.all_local_contests_for_team(team)
    # We could do this with a fancy outer join, but Arel will only give us the Best's, so another
    # query would be needed anyway to get the local contests. This seems simpler.
    lc_code_to_scenario = Hash[team.local_contests.pluck(:code).map {|code| [code, WPBDC.local_contest_code_to_id(code)]}]
    scenario_to_best = Hash[Best.where(:team_id => team, :scenario => lc_code_to_scenario.values.uniq).map{|b| [b.scenario, b]}]
    lc_code_to_scenario.merge(lc_code_to_scenario) {|c, s| scenario_to_best[s]}
  end

  def self.rebuild
    org_count = Best.count
    Best.delete_all
    Team.find_each do |team|
      best_for_team = nil
      Design.where(:team_id => team.id).pluck(:scenario).each do |scenario|
        best_design = Design.where(:team_id => team.id, :scenario => scenario).order('score ASC, sequence ASC').first
        Best.create do |best|
          best.team = team
          best.design = best_design
          best.scenario = scenario
          best.score = best_design.score
          best.sequence = best_design.sequence
          best_for_team = {:team => team,
                           :design => best_design,
                           :score => best_design.score,
                           :sequence => best_design.sequence} if
            best_for_team.nil? ||
              best.score < best_for_team[:score] ||
              (best.score == best_for_team[:score] && best.sequence < best_for_team[:sequence])
        end
      end

      # Add overall best (across all scenarios)
      if best_for_team
        Best.create do |best|
          best.team = best_for_team[:team]
          best.design = best_for_team[:design]
          best.score = best_for_team[:score]
          best.sequence = best_for_team[:sequence]
        end
      end
    end
    [org_count, Best.count]
  end

end
