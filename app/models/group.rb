class Group < ActiveRecord::Base

  default_scope order("description ASC")

  attr_accessible :description

  has_many :teams

  validates :description, :uniqueness => true, :length => { :maximum => 40 }

  def self.fetch(filter)
    filter =~ /\S/ ? Group.where('description SIMILAR TO ?', filter) : Group.all
  end
end
