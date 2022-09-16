# frozen_string_literal: true

require 'rails_helper'
require_relative 'authorized'

RSpec.describe BasketController, type: :controller do
  def create_basket
    @basket = create_list(:order_item, 5, user: @user)
  end

  let :product do
    create(:product, price_count: 1)
  end

  describe 'GET #index' do
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
        expect(response.parsed_body.count).to be 5
        expect(response.parsed_body.map { |h| h['id'].to_i }.sort).to eq @basket.map(&:id).sort
      end

      it 'returns items only owned by this user' do
        create(:order_item)
        get :index
        expect(response.parsed_body.map { |h| h['user_id'].to_i }).to all(eq @user.id)
      end

      it 'it returns the most recent price' do
        prod = @basket[0].product
        prod.prices.create!(from: DateTime.now, value: 500)
        get :index
        item = response.parsed_body.find { |h| h['product_id'].to_i == prod.id }
        expect(item['price'].to_f).to eq 500
      end

      after :all do
        @basket.each(&:destroy)
      end
    end

    describe 'without a basket' do
      it 'returns an empty list' do
        get :index
        expect(response.parsed_body).to be_empty
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'without basket: responds 204' do
      delete :destroy
      expect(response).to have_http_status(204)
      expect(OrderItem.basket.where(user: @user).count).to be 0
    end

    it 'with basket: responds 204 and deletes basket' do
      create_basket
      delete :destroy
      expect(response).to have_http_status(204)
      expect(OrderItem.basket.where(user: @user).count).to be 0
    end
  end

  describe 'PUT #update' do
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

  describe 'PUT #buy' do
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

  describe 'PUT #sell' do
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

  describe 'DELETE #remove' do
    it 'responds 204 on item not found' do
      delete :remove, params: { id: product.id }
      expect(response).to have_http_status(204)
    end

    it 'responds 204 and deletes the item' do
      OrderItem.create!(user: @user, product: product, amount: 1)
      delete :remove, params: { id: product.id }
      expect(response).to have_http_status(204)
      expect(OrderItem.basket.where(user: @user).count).to be 0
    end
  end
end