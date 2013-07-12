# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :html_document do
    subject "MyString"
    text "MyText"
  end
end
