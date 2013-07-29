# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reminder_request do
    referer "MyString"
    tag "MyString"
    email "MyString"
  end
end
