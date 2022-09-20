require 'rails_helper'

RSpec.describe '/order_items', type: :request do
  include AuthHelpers::RequestHelpers

  before :all do
    @uri   = 'order_items'
    @user  = admin
    @token = sign_in(@user)
  end

  describe 'as admin' do
    describe 'GET, listing order_items' do
      before :each do
        # binding.pry
        @order_items = create_list(:order_item, 5)
        get
      end
  
      it 'it returns 200' do
        expect(response).to have_http_status(200)
      end
  
      it 'it returns all order_items' do
        expect(body.size).to be OrderItem.count
      end
  
      it 'returns order_item as json' do
        expect(body).to eq OrderItem.all.eager_load(:product).as_json(include: :product)
      end
    end
  
    describe 'POST, creating a order_item' do
      describe 'Valid order_item' do
        before :each do
          @order = create(:order)
          @product = create(:product)
          @order_item = build(:order_item, order: @order, user: @order.user, product: @product).slice(:user_id, :product_id, :amount, :order_id)
          post params: { order_item: @order_item }
        end
  
        it 'returns 201' do
          expect(response).to have_http_status(201)
        end
  
        it 'returns order_item as json' do
          item = OrderItem.find body['id']
          expect(body).to eq item.as_json
        end
      end
  
      describe 'invalid order_item' do
        it 'returns 400 on missing bag name' do
          post
          expect(response).to have_http_status(400)
        end
  
        it 'returns 422 on invalid item' do
          post params: { order_item: { amount: -2 } }
          expect(response).to have_http_status(422)
        end
      end
    end
  
    describe '/order_items/:id' do
      before :each do
        @order_item = create(:order_item)
        @uri = "order_items/#{@order_item.id}"
      end
  
      describe 'GET, shows a order_item' do
        it 'returns 404 on bad :id' do
          get 'order_items/0'
          expect(response).to have_http_status(404)
        end
  
        it 'returns 200' do
          get
          expect(response).to have_http_status(200)
        end
  
        it 'returns as_json' do
          get
          expect(body).to eq @order_item.as_json
        end
      end
  
      describe 'PUT, updates a order_item' do
        it 'returns 422 with invalid data' do
          put params: { order_item: { amount: -1 } }
          expect(response).to have_http_status(422)
        end
  
        it 'returns 200 with valid data' do
          put params: { order_item: { amount: 5 } }
          expect(response).to have_http_status(200)
        end
      end
  
      describe 'DELETE, destroys a order_item' do
        it 'returns 204' do
          delete
          expect(response).to have_http_status(204)
        end
      end
    end
  end

  describe 'As guest/customer' do
    before :all do
      @user = guest
      @token = sign_in(@user)
      @uri = 'order_items'
    end

    describe 'GET, #index' do
      before :each do 
        @orders = create_list(:order_item, 5, user: @user)
        get
      end

      it 'returns all ordered items' do
        expect(body.size).to be 5
      end

      it 'responds 200' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET, #show' do
      before :each do 
        @own = create(:order_item, user: @user)
        @other = create(:order_item, user: admin)
      end

      it 'returns 403 for alien users order_items' do
        get "order_items/#{@other.id}"
        expect(response).to have_http_status(403)
      end

      it 'returns 200 on own order item' do
        get "order_items/#{@own.id}"
        expect(response).to have_http_status(200)
      end

      it 'returns 200 json includes product, price and value' do
        get "order_items/#{@own.id}"
        expect(body.keys).to include 'price'
        expect(body.keys).to include 'product'
        expect(body['product'].keys).to include 'price'
        expect(body.keys).to include 'value'
      end
    end
  end
end
