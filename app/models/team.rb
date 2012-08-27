class Team < ActiveRecord::Base

  attr_accessible :name, :email, :contest
  attr_accessible :local_contest_code, :member
  attr_accessible :password, :password_confirmation
  attr_accessor :local_contest_code, :completed

  has_secure_password

  has_many :members
  has_many :designs
  has_many :affiliations
  has_many :local_contests, :through => :affiliations
  belongs_to :captain, :class_name => 'Member', :dependent => :destroy

  before_validation :tweak_on_create, :on => :create
  before_validation :fix_local_contest_code
  before_save :adjust_local_contests, :downcase_email
  
  validates :name_key, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 32 }
  validates :local_contest_code, :length => { :maximum => 6 }
  validates :local_contest_code, :length => { :minimum => 4 }, :if => :local_selected?

  VALID_EMAIL_ADDRESS = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence => true, :format => { :with => VALID_EMAIL_ADDRESS }, :if => :completed
  validates :password, :presence => true, :length => { :minimum => 6 }, :if => :completed
  validates :password_confirmation, presence: true, :if => :completed

  # The ActiveRecord for a team tries to put a record in the
  # affiliation table, but will fail if there is no target
  # local contest.  This detects such a condition.
  validates_each :local_contest_code do |record, attr, value|
    record.errors.add(attr, 'is not valid. Ask your local contest sponsor for the correct code!') \
      if record.local_selected? && LocalContest.find_by_code(record.local_contest_code).nil?
  end

  #validates :email, :presence => true, :length => { :maximum => 40 }

  def contest
    @contest || :national
  end

  def contest=(val)
    @contest = val.to_sym
  end

  def self.find(*args)
    return super(*args).set_virtual_fields
  end

  # This lazily sets the non-database backed fields.
  def set_virtual_fields
    lc = local_contests.first
    if lc 
      self.local_contest_code = lc.code
      self.contest = :local
    else
      self.contest = :national
    end
    return self
  end

  # This ignores the nested member in the team form. The member
  # fields are handled in the team and member controllers.
  def member=(member_hash)
  end

  def local_selected?
    contest == :local
  end

  protected

  def to_name_key (name)
    return name.downcase.gsub(/[^a-z0-9]/, '')
  end

  # Set the name key from the raw name string.
  # Set a dummy password to suppress empty digest message.
  def tweak_on_create
    self.name_key = to_name_key(name) unless name.nil?
    self.password_confirmation = self.password = 'temporary'
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

end
