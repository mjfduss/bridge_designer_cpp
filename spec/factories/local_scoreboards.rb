# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :local_scoreboard do
    code "MyString"
    page 1
    board "MyText"
  end
end
