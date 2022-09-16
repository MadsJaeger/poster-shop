require 'rails_helper'

RSpec.describe Price, type: :model do
  before :all do
    @product = create(:product, price_count: 0)
  end

  let :subject do
    build(:price, product: @product)
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
      subject.from = DateTime.now + 1.day
      expect(subject).to_not be_valid
    end

    it 'from canot be before 2000' do
      subject.from = Price::MIN_FROM - 1.second
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

  it 'saving copies value to product' do
    subject.save
    expect(@product.price).to eq subject.value
  end

  it 'removing all prices sets price on product to nil' do
    subject.save
    subject.destroy
    expect(@product.price).to be_nil
  end

  after :all do
    @product.destroy!
  end
end
