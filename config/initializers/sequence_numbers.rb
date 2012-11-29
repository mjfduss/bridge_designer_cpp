# Initialize sequence numbers if not already there.  Value defaults to zero.
SequenceNumber.find_or_create_by_tag('design', :value => 0) \
  if ActiveRecord::Base.connection.table_exists? 'sequence_numbers'
