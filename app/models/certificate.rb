class Certificate < ActiveRecord::Base

  class PerGroupInfo
    attr_reader :group_id, :standing, :basis

    def initialize(group_id, standing, basis)
      @group_id = group_id
      @standing = [standing, basis].min
      @basis = basis
    end

    def group
      Group.find_by_id(@group_id)
    end

    # A relative place quotient in (0.0 .. 1.0]
    def placement
      Float(standing) / basis
    end
  end

  # Avoid a separate table just to store group info for certificates...
  # This is an array of PerGroupInfo
  serialize :group_info, Array

  belongs_to :design
  belongs_to :local_contest, :counter_cache => true
  belongs_to :team
  # validates_uniqueness_of :team_id, :scope => :local_contest_id

  def self.revoke_for_qualifiers(category)
    Certificate.joins(:team).destroy_all(:local_contest_id => nil, :teams => { :category => category })
  end

  def self.generate_for_qualifiers(category)
    Certificate.revoke_for_qualifiers(category)
    basis = Team.get_basis(category)
    awarded_on = Date.today
    Team.each_team_receiving_qualifying_certificate(category) do |team, group_standing_and_basis|
      Certificate.create! do |c|
        c.team = team
        c.design = team.best_qualifying_design
        c.standing = team.rank
        c.basis = [basis, c.standing].max
        # Squeeze out null groups, duplicates, placements less than half. Sort best placement first.
        # TODO: Should we drop low placements, say less than half?
        c.group_info = group_standing_and_basis.select{|x| x[0]}.uniq.
            map{|t| PerGroupInfo.new(*t)}.
            # select{|g| g.placement >= 0.5 }.
            sort_by(&:placement)
        c.awarded_on = awarded_on
      end
    end
  end

  def self.revoke_for_local_contests(ids)
    return [] if ids.blank?
    lcs = LocalContest.where(:id => ids)
    Certificate.destroy_all(:local_contest_id => ids)
    lcs
  end

  def self.generate_for_local_contests(ids)
    lcs = revoke_for_local_contests(ids)
    awarded_on = Date.today
    lcs.each do |lc|
      # We can't use affiliation count here as we do in the administrator
      # because we want to take bridges and reject status into account.
      basis = Team.get_local_contest_basis(lc.code)
      page = 1
      loop do
        # TODO: Implement a non-paginated get to eliminate this hack.
        teams = Team.get_ranked_local_contest_teams(lc.code, page, 1000)
        teams.each do |team|
          Certificate.create do |c|
            c.team = team
            c.local_contest = lc
            c.design = team.best_qualifying_design
            c.standing = team.rank
            # Since we aren't locking the team table, really bad timing could
            # cause a race where the standing is more than the basis.  Patch that here.
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
