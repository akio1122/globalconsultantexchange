# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :approved_status do
    code { Faker::Code.isbn[0..24] }
    label { Faker::Lorem.characters(256) }
  end
end
