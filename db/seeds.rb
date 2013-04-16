# Make and administrator account.
Administrator.delete_all
Administrator.find_or_create_by_name(:name => 'admin', :password => 'foobarbaz', :password_confirmation => 'foobarbaz')
# For development, use factory girl to build some records.
if Rails.env.development?
  Team.delete_all
  Member.delete_all
  Design.delete_all
  50.times do |n|
    FactoryGirl.create(:local_contest)
  end
  50.times do |n|
    # Team with one member and no designs
    FactoryGirl.create(:team)
    # Team with two members and two designs
    team = FactoryGirl.create(:team)
    team.members << FactoryGirl.create(:member, :team => team)
    FactoryGirl.create(:design, :team => team)
    FactoryGirl.create(:design, :team => team)
  end
end