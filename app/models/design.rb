class Design < ActiveRecord::Base
  attr_accessible :bridge, :scenario, :sequence, :hash_string, :score
  belongs_to :team

  validates :bridge, :presence => true
  validates :scenario, :length => { :is => 10 }
  validates :sequence, :uniqueness => true
  validates :hash_string, :length => { :is => 40 }
  validates :score, :numericality => true

  def self.get_top_designs(category, limit)
    Design.find_by_sql(
        "select * from
  (select distinct on (d.team_id) d.id, d.team_id, d.score, d.sequence, d.scenario, d.created_at, d.hash_string
     from teams t inner join designs d
     on t.id = d.team_id
     where t.category = '#{category}'
     order by d.team_id, d.score, d.sequence asc
     limit #{limit}) tmp
  order by score asc, sequence asc"
    )
  end
end
