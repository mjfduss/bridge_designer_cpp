# Initialize sequence numbers if not already there.  Value defaults to zero.
%w{design}.each do |tag|
  SequenceNumber.find_or_create_by_tag(tag, :value => 0)
end