class Team < ActiveRecord::Base

  VALID_EMAIL_ADDRESS = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :name, :email, :contest
  attr_accessible :members_attributes
  attr_accessible :password, :password_confirmation
  attr_accessible :submits, :improves

  attr_accessible :new_local_contest
  attr_accessor :new_local_contest, :completion_status

  future_has_secure_password :validations => false

  has_many :members, :order => 'rank ASC', :dependent => :destroy
  has_many :non_captains, :class_name => 'Member', :order => 'rank ASC', :conditions => 'members.rank != 0'
  has_many :designs
  has_many :affiliations
  has_many :local_contests, :through => :affiliations

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

  validates :password, :presence => true, :confirmation => true, :length => { :minimum => 6 }, :if => :completed_with_password?

  validates_each :new_local_contest do |record, attr, value|
    record.errors.add(attr, 'is not valid. Ask your local contest sponsor for the correct code!') \
      unless record.new_local_contest.blank? || !LocalContest.find_by_code(record.new_local_contest).nil?
  end

  def best_score
    d = designs.select('score').order('score, sequence ASC').limit(1).first
    return d ? d.score : nil
  end

  def best_score_for_scenario(scenario)
    d = designs.select('score').where(:scenario => scenario).order('score, sequence ASC').limit(1).first
    return d ? d.score : nil
  end

  def captain
    members[0]
  end

  def registration_category
    i = members.index {|m| m.category == 'o'}
    i.nil? ? 'e' : 'i'
  end

  def register
    self.category ||= registration_category
  end

  def self.authenticate (name, password)
    team = find_by_name_key(to_name_key(name))
    return team ? team.try(:authenticate, password) : nil
  end

  protected

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
