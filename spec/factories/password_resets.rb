# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :password_reset do
    key ""
    team_id 1
  end
end
