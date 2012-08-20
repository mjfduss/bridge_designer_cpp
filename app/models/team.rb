class Team < ActiveRecord::Base

  before_validation :save_name_key

  attr_accessible :name, :email, :contest 
  attr_accessible :local_contest_code, :member

  has_many :members
  has_many :designs
  has_many :affiliations
  has_many :local_contests, :through => :affiliations
  belongs_to :captain, :class_name => 'Member', :dependent => :destroy

  validates :name, :presence => true, :length => { :maximum => 32 }
  #validates :name_key, :uniqueness => true
  #validates :email, :presence => true, :length => { :maximum => 40 }

  def member=(val)
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

  end

  protected
  
  def save_name_key
     self.name_key ||= name.downcase.gsub!('[^a-z0-9]', '')
  end
end
