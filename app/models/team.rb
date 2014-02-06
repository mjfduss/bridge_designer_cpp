require 'pippa'

class Team < ActiveRecord::Base

  VALID_EMAIL_ADDRESS = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  NONE = '[none]'
  PER_PAGE = 20

  attr_accessible :name, :email
  attr_accessible :password, :password_confirmation
  attr_accessible :members_attributes

  attr_accessible :new_local_contest
  attr_accessor :new_local_contest, :completion_status, :rank

  future_has_secure_password :validations => false

  has_many :members, :order => 'rank ASC', :dependent => :destroy
  has_many :designs, :order => 'score ASC, sequence ASC', :dependent => :destroy
  has_one :best_design, :class_name => 'Design', :order => 'score ASC, sequence ASC'
  has_many :affiliations, :dependent => :destroy
  has_many :local_contests, :through => :affiliations
  has_many :bests, :dependent => :destroy
  has_many :password_resets, :dependent => :destroy
  belongs_to :group

  scope :ordered_by_name, :order => "name_key ASC"

  accepts_nested_attributes_for :members

  before_validation :set_name_key
  before_validation :upcase_new_local_contest
  before_save :downcase_email
  before_save :add_new_affiliation

  validates :name_key, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 32 }
  validates :new_local_contest, :length => { :maximum => 6 }

  with_options :if => :completed? do |v|
    v.validates :email, :length => { :maximum => 80 }, :presence => true, :format => { :with => VALID_EMAIL_ADDRESS }
    v.validates_associated :members
    v.validates :captain, :presence => true
  end

  with_options :if => :completed_with_password? do |v|
    v.validates :password_confirmation, :presence => true
    v.validates :password, :presence => true, :confirmation => true, :length => { :minimum => 6 }
  end

  validates_each :new_local_contest do |record, attr, value|
    record.errors.add(attr, 'is not valid. Ask your local contest sponsor for the correct code!') \
      unless record.new_local_contest.blank? || !LocalContest.find_by_code(record.new_local_contest).nil?
  end

  def captain
    members[0]
  end

  def non_captains
    self.members[1..-1]
  end

  def best_score
    d = best_design
    d ? d.score : nil
  end

  def self.synch_standings
    Team.all.each do |team|
      if team.rejected?
        Standing.delete(team)
      else
        d = team.best_design
        Standing.insert(team, d) if d
      end
    end
  end

  def best_score_for_scenario(scenario)
    d = designs.select('score').where(:scenario => scenario).order('score ASC, sequence ASC').first
    d ? d.score : nil
  end

  # Compute the registration category from the member categories.
  def registration_category
    if members.all? {|m| m.middle_school? }
      'm'
    elsif members.all? {|m| m.high_school? }
      'h'
    else
      'i'
    end
  end

  # Mark this team as fully registered. This enables future logins.
  def register
    self.reg_completed = Time.now unless registered?
  end

  def registered?
    !reg_completed.blank?
  end

  def accepted_or_hidden?
    status == 'a'
  end

  def rejected?
    status == 'r'
  end

  def semifinalist?
    status == '2'
  end

  # This is where we check that the team completed registration fully.
  def self.authenticate (name, password)
    team = find_by_name_key(to_name_key(name))
    return team && team.reg_completed ? team.try(:authenticate, password) : nil
  end

  # @param [Array] categories list of team categories to select from
  # @param [Array] statuses list of statuses to select from
  # @param [Integer] limit maximum number of teams to get
  def self.get_top_teams(categories, statuses, scenario, limit)
    limit = limit.to_i
    return [] if statuses.empty? || categories.empty? || limit <= 0
    includes(:members, :best_design).
      joins(:bests).
      where(:bests => { :scenario => scenario }, :category => categories, :status => statuses).
      order('bests.score ASC, bests.sequence ASC').limit(limit)
=begin
    # PSQL specific
    Team.find_by_sql ['select * from
      (select distinct on (d.team_id) t.*, d.score, d.sequence
        from teams t inner join designs d
        on t.id = d.team_id
        where t.category in (?) and t.status in (?)
        order by d.team_id, d.score asc, d.sequence asc) tmp
      order by score asc, sequence asc
      limit ?', categories, statuses, limit]
=end
  end

  def standing_query(statuses)
    bd = best_design
    Team.count_by_sql([
      'SELECT count(DISTINCT COALESCE(t.group_id, t.id)) ' +
      'FROM teams t INNER JOIN bests b ' +
      'ON t.id = b.team_id ' +
      "WHERE  t.status IN (?) " +
      'AND t.category = ? ' +
      'AND b.scenario IS NULL ' +
      'AND (b.score < ? ' +
      'OR (b.score = ? AND b.sequence <= ?)) ',
      statuses, category, bd.score, bd.score, bd.sequence])
  end

  def basis_query
    Team.count_by_sql([
    'SELECT count(DISTINCT COALESCE(t.group_id, t.id)) ' +
    'FROM teams t INNER JOIN bests b ' +
    'ON t.id = b.team_id ' +
    'WHERE t.category = ? ' +
    "AND t.status IN ('-', 'a', '2') " +
    'AND b.scenario IS NULL ',
    category])
  end

  def standing
    [ standing_query( %w{a 2}.include?(status) ? %w{a 2} : %w{- a 2} ), basis_query ]
  end

  # Get the teams in a local contest correctly sorted by score.
  # Offset and limit are to serve our pagination mechanism,
  # since we can't use any of the standard gems for scoreboards.
  # @param [String] code local contest code or nil for 4-char-code local contests
  # @param [Integer] page page of records to return (as for will_paginate)
  # @return [Array] array of Teams
  def self.get_local_contest_teams(code, page = 1)
    includes(:members, :best_design).
      joins(:bests, :affiliations => :local_contest).
      # This is dangerous code.  We want "not rejected, but can't get it until Rails 4"
      where(:status => %w{- a 2 h},
            :bests => { :scenario => WPBDC.local_contest_code_to_id(code) || nil },
            :local_contests => { :code => code }).
      order('bests.score ASC, bests.sequence ASC').
      offset((page - 1) * PER_PAGE).
      limit(PER_PAGE)

=begin
    Team.paginate_by_sql scenario ?

      ["select * from
        (select distinct on (d.team_id) lct.*, d.score, d.sequence
          from (select t.* from teams t
                inner join affiliations a
                  on t.id = a.team_id
                inner join local_contests lc
                  on a.local_contest_id = lc.id
                where lc.code = ?) lct
          inner join designs d
            on lct.id = d.team_id
          where lct.status <> 'r' and d.scenario = ?
          order by d.team_id, d.score asc, d.sequence asc) tmp
        order by score, sequence", code, scenario] :

      ["select * from
        (select distinct on (d.team_id) lct.*, d.score, d.sequence
          from (select t.* from teams t
                inner join affiliations a
                  on t.id = a.team_id
                inner join local_contests lc
                  on a.local_contest_id = lc.id
                where lc.code = ?) lct
          inner join designs d
            on lct.id = d.team_id
          where lct.status <> 'r'
          order by d.team_id, d.score asc, d.sequence asc) tmp
        order by score, sequence", code],

        :page => page, :per_page => PER_PAGE
=end
  end

  def self.get_teams_by_name(name_likeness, categories, statuses, limit)
    name_likeness.strip!
    Team.where('name_key ILIKE ? AND category IN (?) AND status IN (?) AND reg_completed IS NOT NULL',
      name_likeness.blank? ? '%' : name_likeness, categories, statuses).order('name_key ASC').limit(limit.to_i)
  end

  def self.assign_top_ranks(teams, truncate_at_rank = -1)
    max_ranked_in_group = 1
    rank = 0
    rankable = 0  # Could be ranked if accepted.
    group_counts = Hash.new(0)
    teams.each_with_index do |team, index|
      g = team.group
      team.rank = case team.status
        when 'a', '2'
          if g.nil? || (group_counts[g.id] += 1) <= max_ranked_in_group
            rank += 1
          else
            :o
          end
        when '-'
          # :x for "Would be visible if this alone were accepted"; :o for "Would be hidden even if accepted"
          if g.nil? || group_counts[g.id] <= max_ranked_in_group
            rankable += 1
            :x
          else
            :o
          end
        else
          rankable += 1
          :x
      end
      return [teams.replace(teams[0..index]), rank] if rank == truncate_at_rank || rankable == truncate_at_rank
    end
    [teams, rank]
  end

  def self.get_ranked_top_teams(category, status, scenario, limit)
    # Number to fetch from database trying to reach limit
    n = 3 * limit
    loop do
      top_teams = get_top_teams(category, status, scenario, n)
      ranked_top_teams, top_rank = assign_top_ranks(top_teams, limit)
      # We're done if we already fetched all records or if we reached the desired limit.
      return ranked_top_teams if top_teams.length < n || top_rank == limit
      # We didn't get enough records. Try again.
      n *= 2
    end
  end

  def self.assign_simple_ranks(teams, page)
    base = 1 + [page.to_i - 1, 0].max * PER_PAGE
    teams.each_with_index { |t, i| t.rank = base + i }
  end

  def self.assign_unofficial_ranks(teams)
#    ranks = Standing.all_standings(teams)
#    teams.zip(ranks).each do |team, rank|
#      team.rank = rank || :x
#    end
    # TODO Pipeline or remote script this loop
    teams.each do |team|
      team.rank = Standing.rank(team) || :x
    end if teams
    teams
  end

  # Best information on city and state given team type.
  def city_state(member)
    if category == 'i'
      member.school_city.strip
    else
      (member.city && member.state) ? "#{member.city.strip}, #{member.state.strip}" : '--'
    end
  end

  def scoreboard_row(score_p=false)
    bd = best_design
    row = {
      :rank => rank,
      :team_name => name,
      :category => category,
      :members => members.map{|m| m.first_name }, # Don't uniquify first names!
      :city_state => members.map{|m| city_state(m) }.uniq,
      :school => members.map{|m| m.school ? m.school.strip : '--'}.uniq,
      :location => members.map{|m| m.school_city ? m.school_city.strip : '--' }.uniq,
      :submitted => bd ? bd.created_at.to_s(:nice) : '---',
    }
    row[:score] = format("$%.2f", 0.01 * best_score) if score_p
    row
  end

  def self.new_local_scoreboard(teams = [], rows = [])
    {
      :created_at => Time.now.to_s(:nice),
      :teams => teams,
      :rows => rows
    }
  end

  def self.get_local_contest_scoreboard(code, page)
    teams = assign_simple_ranks(get_local_contest_teams(code, page), page)
    new_local_scoreboard(teams, teams.map {|t| t.scoreboard_row })
  end

  def self.get_scoreboard(category, limit = 0, option = '-')

    # Translate scoreboard category into team category and status.
    # The mapping is:
    # Scoreboard             Team
    # Category               Category                    Status
    # c-combined             {h-HS, m-MS, i-ineligible}  {a-accepted, 2-semifinal}
    # h-HS                   h-HS                        {a-accepted, 2-semifinal}
    # m-MS                   m-MS                        {a-accepted, 2-semifinal}
    # i-ineligible (open)
    # 2-semifinal
    team_category = category
    team_status = %w{a 2}
    scenario = nil
    case category
      when 'c' # combined
        team_category = %w{i h m}
      when '2' # semifinal
        team_category = %w{h m}
        team_status = '2'
        scenario = WPBDC::SEMIFINAL_SCENARIO_ID
    end

    scoreboard = {
      :created_at => Time.now.to_s(:nice),
      :category => category,
      :rows => option == 'x' ? nil : # No rows at all if option is 'x'
        get_ranked_top_teams(team_category, team_status, scenario, limit).
          select { |t| t.rank.is_a? Integer }.map {|t| t.scoreboard_row(option == 's') }
    }
    scoreboard[:unavailable] = true if option == 'x'
    # Attach an instance method that knows how to
    # save this hash to the Scoreboard database table.
    def scoreboard.save(admin_id)
      r = Scoreboard.create(:admin_id => admin_id, :category => self[:category], :board => self.to_json)
      if r
        # Copy key data only
        self[:created_at] = r.created_at.to_s(:nice)
        self[:id] = r.id
      end
    end
    scoreboard
  end

  require 'diff_markups'

  def self.splat(pair, key)
    pair.map{|hash| hash[key]}
  end

  def self.scoreboard_diff(from, to)
    diff = {
      :id => to[:id],
      :created_at => to[:created_at],
      :category => to[:category],
      :unavailable => to[:unavailable],
      :rows =>
        if from[:rows].nil? then
          to[:rows].map {|b_row| b_row.merge(:ins => true)}
        elsif to[:rows].nil? then
          from[:rows].map {|a_row| a_row.merge(:del => true)}
        else
          a_map = from[:rows].each_with_object({}) { |row, hash| hash[row[:team_name]] = row }
          diff_rows = to[:rows].map do |b_row|
            a_row = a_map[b_row[:team_name]]
            if a_row
              team_data = {
                :rank => DiffMarkups.diff_markup(a_row[:rank], b_row[:rank]),
                :team_name => b_row[:team_name],
                :category => b_row[:category],
                :members => DiffMarkups.getMarkedUpPair(a_row[:members], b_row[:members]),
                :city_state => DiffMarkups.getMarkedUpPair(a_row[:city_state], b_row[:city_state]),
                :school => DiffMarkups.getMarkedUpPair(a_row[:school], b_row[:school]),
                :location => DiffMarkups.getMarkedUpPair(a_row[:location], b_row[:location]),
                :submitted => DiffMarkups.diff_markup(a_row[:submitted], b_row[:submitted]),
              }
              if a_row[:score] || b_row[:score]
                team_data[:score] = DiffMarkups.diff_markup(a_row[:score] || '', b_row[:score] || '')
              end
              team_data
            else
              b_row.merge(:ins => true)
            end
          end
          # Insert the deleted rows at the correct places
          b_map = to[:rows].each_with_object({}) { |row, hash| hash[row[:team_name]] = row }
          n_inserted = 0
          from[:rows].each do |a_row|
            unless b_map[a_row[:team_name]]
              pos = a_row[:rank].to_i + n_inserted
              if pos < diff_rows.length
                diff_rows.insert(pos, a_row.merge(:del => true))
              else
                diff_rows << a_row.merge(:del => true)
              end
              n_inserted += 1
            end
          end
          diff_rows
        end
    }
  end

  # @return CSS style name for status.
  def status_style_id
    TablesHelper::STATUS_MAP[status].downcase.delete('-')
  end

  ATTRIBUTE_TAGS = {
      :status => 'Review status',
      :team_name => 'Team name',
      :category => 'Category',
      :captain_name => 'Captain name',
      :captain_category => 'Captain category',
      :captain_age_grade => 'Captain age/grade',
      :captain_contact => 'Captain contact',
      :captain_school => 'Captain school',
      :captain_demographics => 'Captain demographics',
      :captain_parent => 'Captain parent',
      :member_name => 'Member name',
      :member_category => 'Member category',
      :member_age_grade => 'Member age/grade',
      :member_contact => 'Member contact',
      :member_school => 'Member school',
      :member_demographics => 'Member demographics',
      :member_parent => 'Member parent',
      :email => 'Email',
      :reg_completed => 'Registration',
      :local_contests => 'Local contests',
      :best_score => 'Best score',
      :best_design => 'Best design',
  }
  def status_formatted;               TablesHelper::STATUS_MAP[status] || NONE end
  def team_name_formatted;            name end
  def category_formatted;             TablesHelper::CATEGORY_MAP[category] || NONE end
  def captain_name_formatted;         captain.full_name end
  def captain_category_formatted;     captain.category_formatted end
  def captain_age_grade_formatted;    captain.age_grade_formatted end
  def captain_contact_formatted;      captain.contact_formatted end
  def captain_school_formatted;       captain.school_formatted end
  def captain_demographics_formatted; Team.optional(captain, :demographics_formatted) end
  def captain_parent_formatted;       Team.optional(captain, :parent_formatted) end
  def member_name_formatted;          Team.optional(non_captains.first, :full_name) end
  def member_category_formatted;      Team.optional(non_captains.first, :category_formatted) end
  def member_age_grade_formatted;     Team.optional(non_captains.first, :age_grade_formatted) end
  def member_contact_formatted;       Team.optional(non_captains.first, :contact_formatted) end
  def member_school_formatted;        Team.optional(non_captains.first, :school_formatted) end
  def member_demographics_formatted;  Team.optional(non_captains.first, :demographics_formatted) end
  def member_parent_formatted;        Team.optional(non_captains.first, :parent_formatted) end
  def email_formatted;                email end
  def reg_completed_formatted;        reg_completed ? reg_completed.to_s(:nice) : NONE end
  def local_contests_formatted;       codes = local_contests.pluck(:code); codes.blank? ? NONE : codes end
  def best_score_formatted;           d = best_design; d ? "#{format("$%.2f", 0.01 * d.score)} @ #{d.created_at.to_s(:nice)}" : NONE end
  def best_design_formatted;          best_design || NONE end

  def formatted_item(item)
    send("#{item}_formatted")
  end

  def formatted(visible)
    visible.map { |item| [ ATTRIBUTE_TAGS[item.to_sym], formatted_item(item) ] }
  end

  def self.format_all(teams, visible)
    teams.map { |t| t.formatted(visible) }
  end

  def self.format_csv(teams, visible)
    return '' if teams.empty?
    v = visible - %w{best_design}
    CSV.generate do |csv|
      csv << v.map{|item| ATTRIBUTE_TAGS[item.to_sym] }
      teams.each do |team|
        csv << v.map do |item|
          fi = team.formatted_item(item)
          fi.kind_of?(Array) ? fi.join(';') : fi
        end
      end
    end
  end

  protected

  def self.optional(inst, fld)
    inst ? inst.send(fld) : NONE
  end

  def self.to_name_key (name)
    return name.downcase.gsub(/[^a-z0-9]/, '')
  end

  # Set the name key from the raw name string.
  # Set a dummy password to suppress empty digest message.
  def set_name_key
    self.name_key = Team.to_name_key(name) unless name.nil?
    # Now done with next gen authentication handler that allows turning off validations
    # self.password_confirmation = self.password = 'temporary'
  end

  def downcase_email
    self.email = email.strip.downcase unless email.nil?
  end

  def upcase_new_local_contest
    self.new_local_contest = new_local_contest.upcase unless new_local_contest.nil?
  end

  def add_new_affiliation
    return if new_local_contest.blank? || local_contests.index {|c| c.code == new_local_contest }
    c = LocalContest.find_by_code(new_local_contest)
    local_contests << c unless c.nil?
  end

  def completed_with_password?
    completion_status == :complete_with_fresh_password
  end

  def completed?
    [:complete_with_fresh_password, :complete_with_old_password].include?(completion_status)
  end

end
