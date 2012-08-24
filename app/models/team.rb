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
  validates :local_contest_code, :presence => true, :if => :local_selected?
  #validates :email, :presence => true, :length => { :maximum => 40 }

  def set_name_key
    self.name_key = name.downcase.gsub(/[^a-z0-9]/, '') unless name.nil?
  end

  def member=(member_hash)
  end

  def contest 
    return local_contests.empty? ? :national : :local
  end

  def contest=(val)

  end

  def local_contest_code
    return local_contests.empty? ? '' : local_contests.first.code
  end

  def local_contest_code=(val)
    local_contest = LocalContest.find_by_code(val)
  end

  protected

  def local_selected?
    contest == 'local'
  end
end
