require 'rails_helper'

RSpec.describe Order, type: :model do
  before :all do
    @user = create(:user)
    # @products = create_list(:product, 3)
  end

  let :subject do
    build(:order, user: @user)
  end

  def create_basket
    build_list(:order_item, 5, user: @user, order: subject)
  end

  def get_error(attr)
    subject.errors.find { |err| err.attribute == attr }
  end

  describe 'class methods' do
    describe '#basket_for, reutns a' do
      let(:basket) { described_class.basket_for(@user) }

      it 'new basket for user' do
        expect(basket.id).to be_blank
      end

      it 'stored basket for user when allready created' do
        item = Order.create!(user: @user)
        expect(basket).to eq item
      end
    end

    it '#for, returns orders for a given user' do
      expect(described_class.for(@user).to_sql).to include("WHERE \"orders\".\"user_id\" = #{@user.id}")
    end

    it '#basket, returns unconfirmed orders' do
      expect(described_class.basket.to_sql).to include('WHERE "orders"."confirmed_at" IS NULL')
    end
  end

  describe 'intial satate' do
    it 'has 0 value' do
      expect(subject.attributes['value']).to eq 0
    end

    it 'has 0 size' do
      expect(subject.attributes['size']).to eq 0
    end

    it 'has 0 amount' do
      expect(subject.amount).to eq 0
    end

    it { is_expected.to be_empty }
    it { is_expected.to_not be_confirmed }
    it { is_expected.to_not be_checkout }
    it { is_expected.to be_valid }
  end

  describe 'validation' do
    it 'must have auser' do
      subject.user = nil
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 1
    end

    it 'cant change user after save' do
      subject.save 
      subject.user = build(:user)
      expect(subject).to_not be_valid
      expect(subject.errors.size).to be 1
    end

    it 'one user cant have multiple unconfirmed orders' do
      subject.save
      evil_twin = build(:order, user: @user)
      expect(evil_twin).to_not be_valid
      expect(evil_twin.errors.size).to be 1
    end

    it 'one user may have multiple confirmed orders' do
      first = create(:order, :with_items, user: @user)
      expect(first.checkout).to be true
      expect(first.confirm).to be true
      
      second = create(:order, user: @user)
      first.items.each do |item|
        create(:order_item, order: second, product: item.product, user: @user)
      end
      expect(second.checkout).to be true
      expect(second.confirm).to be true
    end

    describe 'when checking out' do
      describe 'with empty basket' do
        before :each do 
          subject.checkout_at = DateTime.now
          subject.valid?
        end
  
        it { is_expected.to_not be_valid }
  
        it '3 errors will be raised' do
          expect(subject.errors.size).to be 3
        end
  
        it 'Size must not be 0' do
          err = get_error(:size)
          expect(err.type).to be :greater_than
        end
  
        it 'Amount must not be zero' do
          err = get_error(:amount)
          expect(err.type).to be :greater_than
        end
  
        it 'checkout_at must be blank' do
          err = get_error(:checkout_at)
          expect(err.type).to be :present
        end
      end

      describe 'with basket' do
        let :subject do
          create(:order, :with_items, user: @user)
        end

        before :each do
          @res = subject.checkout
        end

        it 'returns true' do
          expect(@res).to be true
        end

        it 'sets checkout_at' do
          expect(subject.checkout_at).to be > DateTime.now - 1.second
        end

        it { is_expected.to be_checkout }
        it { is_expected.to_not be_confirmed }

        it 'updates prices' do
          value_was = subject.value.dup
          prod = subject.items[0].product
          price = create(:price, product: prod, from: DateTime.now)
          expect(subject.checkout).to be true
          expect(subject.items[0].reload.price).to eq price.value
          expect(subject.value).to_not eq value_was
        end

        it 'destroys zero amount items' do
          zero = create(:order_item, user: @user, order: subject, amount: 0)
          expect(subject.checkout).to be true
          expect { zero.reload }.to raise_error ActiveRecord::RecordNotFound
          expect(subject.size).to be 5
        end

        it 'is invalid if all items has 0 amount' do
          subject.checkout_at = nil 
          subject.save
          subject.items.each { |item| item.amount = 0; item.save}
          expect(subject.checkout).to be false
          expect(subject.errors.size).to be 2
        end
      end
    end

    describe 'when confirming' do
      describe 'with an empty basket' do
        before :each do
          subject.checkout_at = DateTime.now
          subject.confirmed_at = DateTime.now + 1.second
          subject.valid?
        end

        it { is_expected.to_not be_valid }
        
        it '4 errors will be raised' do
          expect(subject.errors.size).to be 4
        end

        it 'confirmed_at must be blank' do
          err = get_error(:confirmed_at)
          expect(err.type).to be :present
        end
      end

      describe 'with a basket' do
        let :subject do
          create(:order, :with_items, user: @user)
        end

        before :each do
          subject.checkout
        end

        it 'can confirm' do
          expect(subject.confirm).to be true
          expect(subject.confirmed_at).to be > subject.checkout_at
        end

        it 'is valid when confirming in short time after checkout' do
          subject.confirmed_at = DateTime.now
          expect(subject).to be_valid
        end

        it 'is invalid when confirming on checkout' do
          subject.confirmed_at = subject.checkout_at
          expect(subject).to_not be_valid
        end

        it 'is invalid when confirming before checkout' do
          subject.confirmed_at = subject.checkout_at - 1.second
          expect(subject).to_not be_valid
        end

        it 'is invalid when confirming 15 minutes after checkout' do
          subject.confirmed_at = subject.checkout_at + 15.minutes
          expect(subject).to_not be_valid
        end

        it 'cant confirm when empty' do
          subject.items.each(&:destroy!)
          subject.checkout_at = DateTime.now
          expect(subject.confirm).to be false
          expect(subject.errors.size).to be 1
        end

        it 'cant confirm whence not checkoed out' do
          subject.checkout_at = nil
          expect(subject.confirm).to be false
          expect(subject.errors.size).to be 1
        end
      end
    end
  end

  after :all do
    @user.destroy!
  end
end
