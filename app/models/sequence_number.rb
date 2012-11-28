class SequenceNumber < ActiveRecord::Base
  attr_accessible :tag, :value
  validates :tag, :uniqueness => true

  def self.get_next(tag)
    rtn = find_by_sql("update sequence_numbers set value=value+1 where tag='#{tag}' returning value")
    return rtn.first.value
  end
end
