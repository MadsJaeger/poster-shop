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

  describe 'pricing' do
    before :each do
      subject.save!
    end

    it '.price is blank' do
      expect(subject.price).to be_blank
    end

    it 'creating a price adds .price' do
      subject.prices.create(value: 1, from: DateTime.now)
      expect(subject.price.to_s).to eq '1.0'
    end

    it 'creating past prices does not update price' do
      subject.prices.create(value: 1, from: DateTime.now)
      subject.prices.create(value: 2, from: DateTime.now-1.hour)
      expect(subject.price.to_s).to eq '1.0'
    end

    it 'crating multiple prices updates price to most recent' do
      subject.prices.create(value: 1, from: DateTime.now - (1/1_000.0).seconds)
      subject.prices.create(value: 2, from: DateTime.now)
      expect(subject.price.to_s).to eq '2.0'
    end
  end
end
