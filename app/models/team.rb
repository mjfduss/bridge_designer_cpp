class Team < ActiveRecord::Base

  VALID_EMAIL_ADDRESS = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :name, :email, :contest
  attr_accessible :local_contest_code, :members_attributes
  attr_accessible :password, :password_confirmation
  attr_accessor :local_contest_code

  future_has_secure_password :validations => false

  has_many :members, :order => 'rank ASC', :dependent => :destroy
  has_one :captain, :class_name => 'Member', :conditions => 'members.rank == 0'
  has_many :non_captains, :class_name => 'Member', :order => 'rank ASC', :conditions => 'members.rank != 0'
  has_many :designs
  has_many :affiliations
  has_many :local_contests, :through => :affiliations

  accepts_nested_attributes_for :members

  before_validation :set_name_key, :on => :create
  before_validation :fix_local_contest_code
  before_save :adjust_local_contests, :downcase_email
  after_find :set_non_db_fields
  
  validates :name_key, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 32 }
  validates :local_contest_code, :length => { :maximum => 6 }
  validates :local_contest_code, :length => { :minimum => 4 }, :if => :local_selected?

  with_options :if => :completed do |v|
    v.validates :email, :presence => true, :format => { :with => VALID_EMAIL_ADDRESS }
    v.validates :password, :presence => true, :confirmation => true, :length => { :minimum => 6 }

    v.validates_associated :members
    v.validates :captain , :presence => true
  end

  # The ActiveRecord for a team tries to put a record in the
  # affiliation table, but will fail if there is no target
  # local contest.  This detects such a condition.
  validates_each :local_contest_code do |record, attr, value|
    record.errors.add(attr, 'is not valid. Ask your local contest sponsor for the correct code!') \
      if record.local_selected? && LocalContest.find_by_code(record.local_contest_code).nil?
  end

  def completed
    @completed
  end
  
  def completed=(val)
    @completed = val
  end

  def contest 
    @contest || :national
  end

  def contest=(val)
    @contest = val.to_sym
  end

  def registration_category
    i = members.index {|m| m.category == 'o'}
    i.nil? ? 'e' : 'i'
  end

  def register
    self.category ||= registration_category
  end

  def local_selected?
    contest == :local
  end

  def self.authenticate (name, password)
    find_by_name_key(to_name_key(name)).try(:authenticate, password)
  end

  protected

  def self.to_name_key (name)
    return name.downcase.gsub(/[^a-z0-9]/, '')
  end

  # Set the name key from the raw name string.
  # Set a dummy password to suppress empty digest message.
  def set_name_key
    self.name_key = Team.to_name_key(name) unless name.nil?
    # self.password_confirmation = self.password = 'temporary'
  end

  def fix_local_contest_code
    self.local_contest_code = local_contest_code.upcase unless local_contest_code.nil?
  end

  def adjust_local_contests
    if local_selected? 
      c = LocalContest.find_by_code(local_contest_code)
      local_contests << c unless c.nil?
    else
      local_contests.clear
    end
  end

  def downcase_email
    self.email = email.downcase unless email.nil?
  end

  def set_non_db_fields
    lc = local_contests.first
    if lc 
      self.local_contest_code = lc.code
      self.contest = :local
    else
      self.contest = :national
    end
    return self
  end

end
