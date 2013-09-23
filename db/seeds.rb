# Make and administrator account.
Administrator.delete_all
%w{gene steve cathy}.each {|name| Administrator.find_or_create_by_name(:name => name, :password => 'foobarbaz', :password_confirmation => 'foobarbaz') }
# For development, use factory girl to build some records.
if false && Rails.env.development?
  REDIS.flushall
  Team.delete_all
  Member.delete_all
  Design.delete_all
  Best.delete_all
  LocalContest.delete_all
  Affiliation.delete_all
  # Reset the design sequence number generator.
  seq = SequenceNumber.find_by_tag('design')
  seq.update_attribute(:value, 0) if seq
  50.times do |n|
    FactoryGirl.create(:local_contest)
  end
  lc = LocalContest.all
  195.times do |n|
    # Team with one member and one designs
    team = FactoryGirl.create(:team)
    FactoryGirl.create(:design, :team => team)
    # Team with two members and one designs
    team = FactoryGirl.create(:team, :member_count => 2)
    FactoryGirl.create(:design, :team => team)
    team.local_contests << lc[rand(lc.size)]
  end
end