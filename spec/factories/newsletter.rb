FactoryGirl.define do
  factory :newsletter do
    title       { Faker::Book.title  }
    slug        { Faker::Internet.domain_word  }
  end
end
