class Design < ActiveRecord::Base
  attr_accessible :bridge, :scenario, :sequence, :hash_string, :score
  belongs_to :team

  validates :bridge, :presence => true
  validates :scenario, :length => { :is => 10 }
  validates :sequence, :uniqueness => true
  validates :hash_string, :length => { :is => 40 }
  validates :score, :numericality => true

  def sketch(width = 120, height = 80)
    WPBDC.sketch(bridge, width, height)
  end

  def analysis_table
    WPBDC.analysis_table(bridge)
  end
end
