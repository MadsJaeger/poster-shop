require 'rails_helper'

RSpec.describe Order, type: :model do
  before :all do
    @user = create(:user)
    @items = create_list(:order_item, 10, user: @user)
    @products = @items.map(&:product)
  end

  let :subject do
    build(:order, user: @user, item_count: 0)
  end


  describe 'validation' do
    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'is invalid without any items' do
      subject.user = build(:user)
      expect(subject).to_not be_valid
    end
  end

  describe 'basket' do
    it 'has no items' do
      expect(subject.order_items.length).to be 0
    end

    it 'associates basket before validation' do
      subject.valid?
      expect(subject.order_items.length).to be 10
    end

    it 'updated items with order_id on save' do
      subject.save
      expect(subject.order_items.map(&:order_id_in_database)).to all( be subject.id )
    end
  end

  after :all do
    @items.each(&:destroy!)
    @products.map(&:prices).flatten.each(&:destroy!)
    @products.each(&:reload).each(&:destroy!)
    @user.destroy!
  end
end
