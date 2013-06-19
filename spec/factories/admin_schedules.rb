# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin_schedule, :class => 'Admin::Schedule' do
    name "MyString"
    active false
    message "MyText"
    start_quals_prereg "2013-06-15 20:44:08"
    start_quals "2013-06-15 20:44:08"
    end_quals "2013-06-15 20:44:08"
    quals_tally_complete false
    start_semis_prereg "2013-06-15 20:44:08"
    start_semis "2013-06-15 20:44:08"
    semis_tally_complete false
  end
end
