require 'rails_helper'

RSpec.describe Product, type: :model do
  let :subject do
    build(:product, price_count: 0)
  end

  describe 'validations' do
    it 'subject is valid' do
      expect(subject).to be_valid
    end

    it 'requires a name' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it 'cannot destroy when prices are given' do
      subject.prices.build(value: rand, from: DateTime.now - 1.day)
      subject.save!
      expect(subject.destroy).to be false
      expect(subject.errors.size).to be 1
    end
  end

  it '#with_prices only returns records with pricing' do
    subject.prices.build(from: DateTime.now - 1.second, value: rand)
    subject.save!
    described_class.create!(name: 'Another')
    expect(described_class.with_prices.count).to eq(Price.select(:product_id).distinct.count)
    expect(described_class.count).to be > described_class.with_prices.count
  end

  it '.price the last price' do
    (0..2).each do |i|
      subject.prices.build(
        from: DateTime.now - (i + 1).seconds,
        value: i + 1
      )
    end
    subject.save!
    expect(subject.price).to eq subject.prices[0]
    expect(subject.price.value.to_i).to be 1
  end
end
