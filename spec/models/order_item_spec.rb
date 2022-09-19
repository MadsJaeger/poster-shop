require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  before :all do
    @user = create(:user)
    @product = create(:product)
  end

  let :subject do
    build :order_item, product: @product, user: @user, order: nil
  end

  describe 'validation' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'requires an user' do
      subject.user = nil
      expect(subject).to_not be_valid
    end

    it 'requires a order' do
      subject.user = nil
      subject.valid?
      err = subject.errors.find { |error| error.attribute == :order }
      expect(err.type).to be :blank
    end

    it 'makes and order from user upon validation' do
      subject.valid?
      expect(subject.order).to be_instance_of Order
      expect(subject.order.id).to be_blank
    end

    it 'finds existing order from user upon validation' do
      ord = create(:order, user: @user)
      subject.valid?
      expect(subject.order).to eq ord
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

    it 'price cannot be blank' do
      subject.price = nil
      expect(subject).to_not be_valid
    end

    it 'cannot duplicate product_id per order_id basket item' do
      subject.save
      evil_twin = build(:order_item, user: @user, product: @product, order_id: subject.order_id)
      expect(evil_twin).to_not be_valid
    end

    it 'a user cannot have have the same product twice in on order' do
      order = create(:order, user: @user, items: [subject])
      expect(subject.order_id).to eq(order.id)

      evil_twin = build(:order_item, user: @user, product: @product, order: order)
      expect(evil_twin).to_not be_valid
    end

    it 'a user may order the same product in different orders' do
      order = create(:order, user: @user, items: [subject])
      order.checkout
      order.confirm
      expect(subject.id).to_not be_blank

      twin_order = build(:order, user: @user, items: [build(:order_item, user: @user, product: @product)])
      expect(twin_order.save!).to be true
      expect(twin_order.items.first).to be_valid
    end

    it 'cannot associate to order with alien user' do
      subject.save
      subject.user = create(:user)
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 2
    end

    it 'cannot change product of saved' do
      subject.save
      subject.product = create(:product)
      expect(subject).to_not be_valid
    end

    it 'cannot change order of saved' do
      subject.save
      subject.order = create(:order)
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 2
    end
  end

  describe 'saving' do
    it 'saves associated build order' do
      expect(subject.save).to be true
      expect(subject.order_id).to_not be_blank
    end

    it 'updates order with size and value' do
      expect(subject.save).to be true
      expect(subject.order.value).to eq subject.value
      expect(subject.order.size).to be 1
      expect(subject.order.updated_at).to be > subject.updated_at
    end

    it 'creating sibling updates order' do
      subject.save
      sibling = create(:order_item, user: @user, order: subject.order)
      expect(sibling.order.size).to eq 2
      expect(sibling.order.value).to eq sibling.value + subject.value
    end
  end

  describe 'destroying' do
    it 'de-caches size on order' do
      subject.save
      subject.destroy
      expect(subject.order.size).to eq 0
      expect(subject.order.value).to eq 0
    end
  end

  describe 'pricing' do
    it 'setting product sets price' do
      item = build(:order_item, product: nil)
      expect(item.product).to be_nil

      item.product = @product
      expect(item.price).to eq @product.price

      item.product = nil
      expect(item.price).to be_nil
    end

    it 'update_price resolves to most recent price' do
      new_price = create(:price, from: DateTime.now, product: @product)
      subject.update_price
      expect(subject.price).to eq new_price.value
    end
  end

  it 'value is product if price and amount' do
    expect(subject.value).to eq subject.price * subject.amount
  end

  after :all do
    @user.destroy!
    @product.prices.destroy_all
    @product.destroy!
  end
end
