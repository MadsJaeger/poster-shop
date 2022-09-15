FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email  { Faker::Internet.email }
    admin { false }
    password { '!Secure1' }
    password_confirmation { '!Secure1' }
  end

  factory :product do |_prod|
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

    transient do
      item_count { [(rand * 25).to_i, 1].max  }
    end

    order_items do |ord|
      Array.new(item_count) { association(:order_item, user: ord.user, product: build(:product)) }
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