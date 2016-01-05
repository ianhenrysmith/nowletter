FactoryGirl.define do
  factory :newsletter do
    title       { Faker::Book.title  }
  end
end
