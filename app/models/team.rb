class Team < ActiveRecord::Base

  VALID_EMAIL_ADDRESS = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  NONE = "[none]"

  attr_accessible :name, :email, :contest
  attr_accessible :members_attributes
  attr_accessible :password, :password_confirmation
  attr_accessible :submits, :improves, :status, :group

  attr_accessible :new_local_contest
  attr_accessor :new_local_contest, :completion_status

  future_has_secure_password :validations => false

  has_many :members, :order => 'rank ASC', :dependent => :destroy
  has_many :designs
  has_many :affiliations
  has_many :local_contests, :through => :affiliations
  belongs_to :group

  accepts_nested_attributes_for :members

  before_validation :set_name_key, :on => :create
  before_validation :upcase_new_local_contest
  before_save :downcase_email
  before_save :add_new_affiliation
  
  validates :name_key, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 32 }
  validates :new_local_contest, :length => { :maximum => 6 }
  
  with_options :if => :completed? do |v|
    v.validates :email, :presence => true, :format => { :with => VALID_EMAIL_ADDRESS }
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

  def best_design
    designs.select('score').order('score, sequence ASC').first
  end

  def best_score
    d = best_design
    return d ? d.score : nil
  end

  def self.synch_standings
    Team.all.each do |team|
      if team.status == 'x'
        Standing.delete(team)
      else
        d = team.best_design
        Standing.insert(team, d) if d
      end
    end
  end

  def best_score_for_scenario(scenario)
    d = designs.select('score').where(:scenario => scenario).order('score, sequence ASC').first
    return d ? d.score : nil
  end

  # Compute the registration category from the member categories.
  def registration_category
    i = members.index {|m| m.category == 'o'}
    i.nil? ? 'e' : 'i'
  end

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

  def self.authenticate (name, password)
    team = find_by_name_key(to_name_key(name))
    return team ? team.try(:authenticate, password) : nil
  end

  def self.get_top_teams(category, statuses, limit)
    return [] if statuses.empty?
    return [] unless %w(- e i 2).include?(category)
    limit = 50 unless limit.to_i > 0
    # PSQL specific
    Team.find_by_sql("select * from
      (select distinct on (d.team_id) t.*, d.score, d.sequence
        from teams t inner join designs d
        on t.id = d.team_id
        where t.category = '#{category}'
          and t.status in (#{statuses.map {|s| "'#{s}'"}.join(",") })
        order by d.team_id, d.score asc, d.sequence asc
        limit #{limit}) tmp
      order by score asc, sequence asc")
  end

  def scoreboard_data
    { }
  end

  def status_style_id
    TablesHelper::STATUS_MAP[status].downcase
  end

  def formatted(visible)
    visible.map { |item| send("#{item}_formatted") }
  end

  def self.format_all(teams, visible)
    teams.map { |t| t.formatted(visible) }
  end

  def status_formatted
    ["Review status", TablesHelper::STATUS_MAP[status] || NONE ]
  end

  def team_name_formatted
    ["Team name", name ]
  end

  def category_formatted
    ["Category",  TablesHelper::CATEGORY_MAP[category] || NONE]
  end

  def captain_name_formatted
    ["Captain name", captain.full_name]
  end

  def captain_category_formatted
    ["Captain category", captain.category_formatted]
  end

  def captain_age_grade_formatted
    ["Captain age/grade", captain.age_grade_formatted]
  end

  def captain_contact_formatted
    ["Captain contact", captain.contact_formatted]
  end

  def captain_school_formatted
    ["Captain school", captain.school_formatted]
  end

  def captain_demographics_formatted
    ["Captain demographics", captain.demographics_formatted]
  end

  def member_name_formatted
    ["Member name", Team.optional(non_captains.first, :full_name)]
  end

  def member_category_formatted
    ["Member category", Team.optional(non_captains.first, :category_formatted)]
  end


  def member_age_grade_formatted
    ["Member age/grade", Team.optional(non_captains.first, :age_grade_formatted)]
  end

  def member_contact_formatted
    ["Member contact", Team.optional(non_captains.first, :contact_formatted)]
  end

  def member_school_formatted
    ["Member school", Team.optional(non_captains.first, :school_formatted)]
  end

  def member_demographics_formatted
    ["Member demographics", Team.optional(non_captains.first, :demographics_formatted)]
  end

  def email_formatted
    ["Email", email]
  end

  def local_contests_formatted
    codes = local_contests.map {|t| t.code}
    ["Local contests", codes.blank? ? NONE : codes]
  end

  def best_score_formatted
    ["Best score", best_score]
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
    self.email = email.downcase unless email.nil?
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
    return completion_status == :complete_with_fresh_password
  end

  def completed?
    return [:complete_with_fresh_password, :complete_with_old_password].include?(completion_status)
  end

end
