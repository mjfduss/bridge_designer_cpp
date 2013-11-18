# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :parent do
    first_name "MyString"
    middle_initial "MyString"
    last_name "MyString"
    email "MyString"
  end
end
