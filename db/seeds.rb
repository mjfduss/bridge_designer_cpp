# Make and administrator account.
Administrator.find_or_create_by_name(:name => 'admin', :password => 'admin', :password_confirmation => 'admin')
# For development, use factory girl to build some records.
if Rails.env.development?
  Team.delete_all
  Member.delete_all
  Design.delete_all
  50.times do |n|
    team = FactoryGirl.create(:team)
    team.members << FactoryGirl.create(:member, :team => team)
    FactoryGirl.create(:design, :team => team)
    FactoryGirl.create(:design, :team => team)
  end
end