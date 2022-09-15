require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  before :all do
    @user = create(:user)
    @product = create(:product)
  end

  let :subject do
    build :order_item, product: @product, user: @user, order: nil
  end

  it '#basket returns only items with nil order_id' do
    expect(described_class.basket.to_sql).to include 'WHERE "order_items"."order_id" IS NULL'
  end

  describe 'validation' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires a user' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it 'requires a product' do
      subject.product = nil
      expect(subject).to_not be_valid
    end

    it 'requires an amount' do
      subject.amount = nil
      expect(subject).to_not be_valid
    end

    it 'amount must be positive' do
      subject.amount = -1
      expect(subject).to_not be_valid
    end

    it 'amount 0 with as basket item is valid' do
      subject.amount = 0
      expect(subject).to be_valid
    end

    it 'amount 0 is invalid if is ordered' do
      subject.order = build(:order, item_count: 0)
      subject.amount = 0
      expect(subject).to_not be_valid
    end

    it 'cannot duplicate product_id per user basket item' do
      subject.save
      evil_twin = build(:order_item, user: @user, product: @product)
      expect(evil_twin).to_not be_valid
    end

    it 'a user cannot have have the same product twice in on order' do
      order = create(:order, user: @user, item_count: 0, order_items: [subject])
      expect(subject.order_id).to eq(order.id)

      evil_twin = build(:order_item, user: @user, product: @product, order: order)
      expect(evil_twin).to_not be_valid
    end

    it 'a user may order the same product in different orders' do
      create(:order, user: @user, item_count: 0, order_items: [subject])
      expect(subject.id).to_not be_blank

      twin_order = build(:order, user: @user, item_count: 0, order_items: [build(:order_item, user: @user, product: @product)])
      expect(twin_order.save!).to be true
      expect(twin_order.order_items.first).to be_valid
    end
  end

  describe 'pricing' do
    it 'setting product sets price' do
      item = build(:order_item, product: nil)
      expect(item.product).to be_nil

      item.product = @product
      expect(item.price).to be @product.price

      item.product = nil
      expect(item.price).to be_nil
    end 
    
    it 'update_price resolves to most recent price' do
      new_price = create(:price, from: DateTime.now, product: @product)
      @product.reload
      expect(@product.price).to eq new_price
      
      subject.update_price
      expect(subject.price).to eq new_price
    end
  end

  after :all do
    @user.destroy!
    @product.prices.destroy_all
    @product.destroy!
  end
end
