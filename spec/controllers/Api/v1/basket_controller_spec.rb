# frozen_string_literal: true

require 'rails_helper'
require_relative '../../authorized'

RSpec.describe Api::V1::BasketController, type: :controller do
  def create_basket
    @basket = create_list(:order_item, 5, user: @user)
  end

  let :product do
    create(:product, price_count: 1)
  end

  def body
    response.parsed_body
  end

  def items
    body['items']
  end

  describe 'GET #index, viewing users current or new basket order' do
    it 'returns a succesful response' do
      get :index
      expect(response).to be_successful
    end

    describe 'with a basket' do
      before :all do
        create_basket
      end

      it 'returns the right items' do
        get :index
        expect(body['size']).to be 5
        expect(items.count).to be 5
        expect(items.map { |h| h['id'].to_i }.sort).to eq @basket.map(&:id).sort
      end

      it 'returns items only owned by this user' do
        create(:order_item)
        get :index
        expect(items.map { |h| h['user_id'].to_i }).to all(eq @user.id)
      end

      it 'it returns the most recent price' do
        prod = @basket[0].product
        prod.prices.create!(from: DateTime.now, value: 500)
        get :index
        item = items.find { |h| h['product_id'].to_i == prod.id }
        expect(item['price'].to_f).to eq 500
      end

      after :all do
        @basket.each(&:destroy!)
        @basket.first.order.destroy!
      end
    end

    describe 'without a basket' do
      before :each do
        get :index
      end

      it 'returns a new order' do
        expect(body['id']).to be_nil
      end

      it 'has 0 size' do
        expect(body['size']).to be 0
      end

      it 'has 0 value' do
        expect(body['value'].to_f).to eq 0
      end

      it 'has empty items' do
        expect(body['items']).to eq []
      end
    end
  end

  describe 'DELETE #destroy, destroying a users basker order along all items' do
    it 'without basket: responds 204' do
      delete :destroy
      expect(response).to have_http_status(204)
      expect(Order.basket.where(user: @user).count).to be 0
    end

    it 'with basket: responds 204 and deletes basket' do
      create_basket
      delete :destroy
      expect(response).to have_http_status(204)
      expect(Order.basket.where(user: @user).count).to be 0
    end
  end

  describe 'PUT #update, setting amount for a product, i.e. placing in basket or emptying' do
    it 'creates new order item if it did not exist' do
      put :update, params: { id: product.id }
      prod = OrderItem.find_by!(user: @user, product: product)
      expect(prod.amount).to be(1)
      expect(prod.price).to eq product.price
    end

    it 'sets amount to 1 by default' do
      put :update, params: { id: product.id }
      expect(response.parsed_body['amount']).to be 1
    end

    it 'sets amount to params[:amount]' do
      put :update, params: { id: product.id, amount: 5 }
      expect(response.parsed_body['amount']).to be 5
    end

    it 'can let amount be 0' do
      put :update, params: { id: product.id, amount: 0 }
      expect(response.parsed_body['amount']).to be 0
    end

    it 'coerces negative values to 0' do
      put :update, params: { id: product.id, amount: -1 }
      expect(response.parsed_body['amount']).to be 0
    end

    it 'coerces stings into 0 amount' do
      put :update, params: { id: product.id, amount: 'douche user here!' }
      expect(response.parsed_body['amount']).to be 0
    end

    it 'it updates an order item if it existed' do
      OrderItem.create(user: @user, product: product, amount: 2)
      put :update, params: { id: product.id, amount: 4 }
      expect(response.parsed_body['amount']).to be 4
    end

    it 'returns 404 on unknown product' do
      put :update, params: { id: 0, amount: 4 }
      expect(response).to have_http_status(404)
    end
  end

  describe 'PUT #buy, incerementing amount or placing product in basket' do
    it 'increments amount by 1 by default' do
      put :buy, params: { id: product.id }
      prod = OrderItem.find_by!(user: @user, product: product)
      expect(prod.amount).to be(1)
      expect(prod.updated_at).to eq prod.created_at
    end

    it 'increments amount by params[:amount] by default' do
      prod = OrderItem.create!(user: @user, product: product, amount: 5)
      put :buy, params: { id: product.id, amount: 5 }
      expect(response.parsed_body['amount']).to be 10
      prod.reload
      expect(prod.updated_at).to be > prod.created_at
    end

    it 'decrements on negative value' do
      OrderItem.create!(user: @user, product: product, amount: 5)
      put :buy, params: { id: product.id, amount: -2 }
      expect(response.parsed_body['amount']).to be 3
    end

    it 'returns 422 on exceedingly high amounts' do
      put :buy, params: { id: product.id, amount: 999_999_999_999 }
      expect(response).to have_http_status(422)
    end
  end

  describe 'PUT #sell, decrementing amount or emptying item in basket' do
    it 'decrements amount by 1 by default' do
      prod = OrderItem.create!(user: @user, product: product, amount: 1)
      put :sell, params: { id: product.id }
      prod.reload
      expect(prod.amount).to be(0)
      expect(prod.updated_at).to be > prod.created_at
    end

    it 'cannot decrement to negative values' do
      put :sell, params: { id: product.id, amount: 5 }
      expect(response.parsed_body['amount']).to be 0
    end
  end

  describe 'DELETE #remove, completely removing a product from basket' do
    it 'responds 204 on item not found' do
      delete :remove, params: { id: product.id }
      expect(response).to have_http_status(204)
    end

    it 'responds 204 and deletes the item' do
      OrderItem.create!(user: @user, product: product, amount: 1)
      delete :remove, params: { id: product.id }
      expect(response).to have_http_status(204)
      expect(OrderItem.where(user: @user).count).to be 0
    end
  end

  describe 'GET #checkout, placing basket for checkout, getting size and value' do
    describe 'checkout out invalid order' do
      it 'with no basket, returns 422' do
        get :checkout
        expect(response).to have_http_status(422)
      end

      it 'with 0 amount basket returns 422' do
        OrderItem.create(amount: 0, user: @user, product: @product)
        get :checkout
        expect(response).to have_http_status(422)
      end
    end

    describe 'with a basket' do
      before :each do
        create_basket
        get :checkout
      end

      it 'returns 200' do
        expect(response).to have_http_status(200)
      end

      it 'has order as json' do
        ord = Order.basket_for(@user).as_json
        expect(body.slice(*ord.keys)).to eq(ord)
      end

      it 'has location to confirm' do
        expect(response.location).to include('basket/checkout/confirm')
      end

      it 'repating checkout changes checkout_at' do
        checkout_at_was = body['checkout_at']
        get :checkout
        expect(response).to have_http_status(200)
        expect(body['checkout_at']). to be > checkout_at_was
      end
    end
  end

  describe 'PUT #confirm, confirming checkout, converting basket to order' do
    it 'with new order returns 422' do
      put :confirm
      expect(response).to have_http_status(422)
    end

    describe 'with basket' do
      before :each do
        create_basket
      end

      it 'returns 422 when not checked out' do
        put :confirm
        expect(response).to have_http_status(422)
      end

      it 'returns 200 when checked out' do
        get :checkout
        put :confirm
        expect(response).to have_http_status(200)
        ord = Order.find(body['id']).as_json
        expect(body.slice(*ord.keys)).to eq(ord)
      end

      it 'confirming again returns 422' do
        get :checkout
        put :confirm
        put :confirm
        expect(response).to have_http_status(422)
      end
    end
  end
end