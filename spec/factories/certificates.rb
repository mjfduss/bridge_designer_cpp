# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :certificate do
    team_id 1
    local_contest_id 1
    design_id 1
    standing 1
    awarded_on "2014-02-27"
  end
end
