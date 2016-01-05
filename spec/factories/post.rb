FactoryGirl.define do
  factory :post do
    body       { Faker::Company.catch_phrase }
  end
end
