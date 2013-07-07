# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :asset do
    name "MyString"
    type ""
    assetable_id 1
    assetable_type "MyString"
    width 1
    height 1
    content "MyText"
    content_type "MyString"
  end
end
