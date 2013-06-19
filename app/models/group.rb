class Group < ActiveRecord::Base

  default_scope order("description ASC")

  attr_accessible :description

  has_many :teams, :dependent => :nullify

  validates :description, :uniqueness => true, :length => { :maximum => 40 }

  # Query by example using the given params keyed on column names.
  def self.qbe(params)
    q = Group.scoped  # Make null query scope
    Group.column_names.each do |name|
      param = params[name.to_s]
      q = q.where("#{name} ILIKE ?", "%#{param}%") unless param.blank?
    end
    q.all
  end

end