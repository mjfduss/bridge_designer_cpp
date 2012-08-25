class Team < ActiveRecord::Base

  before_validation :set_name_key, :on => :create

  attr_accessible :name, :email, :contest
  attr_accessible :local_contest_code, :member

  has_many :members
  has_many :designs
  has_many :affiliations
  has_many :local_contests, :through => :affiliations
  belongs_to :captain, :class_name => 'Member', :dependent => :destroy

  validates :name_key, :uniqueness => true
  validates :name, :presence => true, :length => { :maximum => 32 }
  validates :local_contest_code, :length => { :maximum => 6 }
  validates :local_contest_code, :length => { :minimum => 4 }, 
            :if => :local_selected?
  # The ActiveRecord for a team tries to put a record in the
  # affiliation table, but will fail if there is no target
  # local contest.  This detects such a condition.
  validates_each :local_contest_code do |record, attr, value|
    record.errors.add(attr, ' is not for an active local contest.') \
      if record.local_selected? && LocalContest.find_by_code(value).nil?
  end

  #validates :email, :presence => true, :length => { :maximum => 40 }

  def set_name_key
    self.name_key = to_name_key(name) unless name.nil?
  end

  def member=(member_hash)
  end

  def contest 
    return local_contests.empty? ? :national : :local
  end

  def contest=(val)
    if val == 'national'&& !local_contests.empty?
      Affiliations.delete_all("team_id = #{_id}");
    else # :local
      contest = LocalContest.find_by_code(local_contest_code)
      local_contests << contest unless contest.nil?
     end
  end

  def local_contest_code
    return local_contests.empty? ? '' : local_contests.first.code
  end

  # all the work is done in contest=
  def local_contest_code=(val)
  end

  def local_selected?
    return contest == 'local'
  end

  protected

  def to_name_key (name)
    return name.downcase.gsub(/[^a-z0-9]/, '')
  end

end
