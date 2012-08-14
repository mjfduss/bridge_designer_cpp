class Team < ActiveRecord::Base
  attr_accessible :name, :name_key, :email, :password_digest, :local_contest, :submits, :improves, :ip 
  has_many :members
  has_many :designs
  has_many :local_contests
  belongs_to :captain, :class_name => 'Member', :dependent => :destroy
end
