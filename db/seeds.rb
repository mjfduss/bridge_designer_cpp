# Make and administrator account.
Administrator.delete_all
Administrator.find_or_create_by_name(:name => 'admin', :password => 'foobarbaz', :password_confirmation => 'foobarbaz')
# For development, use factory girl to build some records.
#if Rails.env.development?
  Team.delete_all
  Member.delete_all
  Design.delete_all
  LocalContest.delete_all
  Affiliation.delete_all
  # Reset the design sequence number generator.
  SequenceNumber.find_by_tag('design').update_attribute(:value, 0)
  50.times do |n|
    FactoryGirl.create(:local_contest)
  end
  50.times do |n|
    # Team with one member and no designs
    FactoryGirl.create(:team)
    # Team with two members and two designs
    team = FactoryGirl.create(:team, :member_count => 2)
    FactoryGirl.create(:design, :team => team)
    FactoryGirl.create(:design, :team => team)
    Affiliation.create(:team => team, :local_contest => LocalContest.first)
  end
#end