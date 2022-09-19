FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email  { Faker::Internet.email }
    admin { false }
    password { '!Secure1' }
    password_confirmation { '!Secure1' }
  end

  factory :product do
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }

    transient do
      price_count { [10 * rand, 1].max }
    end

    prices do
      Array.new(price_count) { association(:price) }.sort_by(&:from)
    end
  end

  factory :price do
    association :product, price_count: 0
    value { (rand * 1_000).round(2) }
    from { DateTime.now - rand * 6.months }
  end

  factory :order do
    user

    trait :with_items do
      after(:create) do |ord|
        create_list(:order_item, 5, order: ord, user: ord.user)
      end
    end
  end

  factory :order_item do
    product
    user
    amount { [(10 * rand).to_i, 1].max }

    before(:create) do |item|
      item.product.save
    end
  end
end