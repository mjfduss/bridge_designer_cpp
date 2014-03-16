class Certificate < ActiveRecord::Base

  belongs_to :design
  belongs_to :local_contest, :counter_cache => true
  belongs_to :team
  belongs_to :group

  def self.generate_for_qualifiers

  end

  def self.revoke_for_local_contests(ids)
    return [] if ids.blank?
    lcs = LocalContest.where(:id => ids)
    Certificate.destroy_all(:local_contest_id => ids)
    lcs
  end

  def self.generate_for_local_contests(ids)
    lcs = revoke_for_local_contests(ids)
    lcs.each do |lc|
      # We can't use affiliation count here as we do in the administrator
      # because we want to take bridges and reject status into account.
      basis = Team.get_local_contest_basis(lc.code)
      awarded_on = Date.today
      page = 1
      loop do
        teams = Team.get_ranked_local_contest_teams(lc.code, page, 1000)
        teams.each do |team|
          Certificate.create do |c|
            c.team = team
            c.local_contest = lc
            c.design = team.best_design
            c.standing = team.rank
            # Since we aren't locking the team table, really bad timing could
            # cause the standing to be more than the basis.  Patch that here.
            c.basis = [basis, c.standing].max
            c.awarded_on = awarded_on
          end
        end
        break if teams.empty?
        page += 1
      end
    end
    lcs
  end
end

=begin
t.integer  "team_id",          :null => false
t.integer  "local_contest_id"
t.integer  "design_id",        :null => false
t.integer  "standing",         :null => false
t.integer  "basis",            :null => false
t.integer  "group_id"
t.integer  "group_standing"
t.integer  "group_basis"
t.date     "awarded_on",       :null => false
t.datetime "created_at",       :null => false
t.datetime "updated_at",       :null => false
=end
