# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :military do
    consultant
    rank
    branch
    clearance_level
    investigation_date    { 1.years.ago }
    service_start_date    { 6.months.ago }
  end
end
