class Team < ActiveRecord::Base
  has_many :members
  has_many :designs
  has_many :local_contests, :through => :affiliations
  belongs_to :captain, :class_name => 'Member', :dependent => :destroy
  belongs_to :group, :class_name => 'Team'
  validates :name, :presence => true, :length => { :maximum => 16 }
  # can't validate others here because they're initially nil and filled in later
end
