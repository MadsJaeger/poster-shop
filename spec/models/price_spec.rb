require 'rails_helper'

RSpec.describe Price, type: :model do
  before :all do
    @product = Product.create!(
      name: 'Test',
      description: 'Lipsum'
    )
  end

  let :subject do 
    Price.new(
      product: @product,
      from: DateTime.now - 1.second,
      value: rand
    )
  end

  describe 'validations' do
    it 'subject is valid' do
      expect(subject).to be_valid
    end

    it 'requires :product' do
      subject.product = nil
      expect(subject).to_not be_valid
    end

    it 'requires :from' do
      subject.from = nil
      expect(subject).to_not be_valid
    end

    it 'is unique on :from and :product_id' do
      subject.save
      other = described_class.new(**subject.attributes)
      expect(other).to_not be_valid
    end

    it 'from must not be in the future' do
      subject.from += 1.day
      expect(subject).to_not be_valid
    end

    it 'from canot be before 2000' do
      subject.from = Price::MIN_FROM-1.second
      expect(subject).to_not be_valid
    end

    it 'requires :value' do
      subject.value = nil
      expect(subject).to_not be_valid
    end

    it 'value cant be negative' do
      subject.value = -0.01
      expect(subject).to_not be_valid
    end

    it 'value cant be exceedingly large' do
      subject.value = 1_000_000
      expect(subject).to_not be_valid
    end
  end

  after :all do
    @product.destroy!
  end
end