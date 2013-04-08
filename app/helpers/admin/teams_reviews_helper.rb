module Admin::TeamsReviewsHelper

  # Assumes the teams list is already sorted ascending on score.
  # Returns an array parallel to teams that holds the correct rank
  # for each or 'x' if no rank is assigned.  For a team to be
  # ranked, it must be accepted and there must be no more than
  # max_ranked_in_group - 1 ranked teams in the same group before it.
  def team_ranks(teams, max_ranked_in_group)
    rank = 0;
    group_counts = Hash.new(0)
    teams.map do |team|
      g = team.group
      team.status == 'a' && (g.nil? || group_counts[g.id] += 1 <= max_ranked_in_group) ? ++rank : 'x'
    end
  end

end
