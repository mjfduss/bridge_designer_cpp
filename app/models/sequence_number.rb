class SequenceNumber < ActiveRecord::Base
  attr_accessible :tag, :value
  validates :tag, :uniqueness => true

  def self.get_next(tag)
    rtn = find_by_sql(['update sequence_numbers set value=value+1 where tag = ? returning value', tag])
    return rtn.first.value
  end

  def self.reset(tag)
    seq = SequenceNumber.find_or_initialize_by_tag(tag);
    seq.value = 0
    logger.fail "Could not reset seqeuence '#{tag}'" unless seq.save
  end
end
