require 'rails_helper'

RSpec.describe '/orders', type: :request do
  include AuthHelpers::RequestHelpers

  before :all do
    @uri   = 'orders'
    @user  = admin
    @token = sign_in(@user)
  end

  describe 'GET, listing orders' do
    before :each do
      @orders = create_list(:order, 5)
      get
    end

    it 'it returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'it returns all orders' do
      expect(body.size).to be Order.count
    end

    it "returns order as json" do
      expect(body).to eq Order.all.as_json
    end
  end

  describe 'POST, creating a order' do
    describe 'Valid order' do
      before :each do
        post params: { order: { user_id: admin.id } }
      end

      it 'returns 200' do
        expect(response).to have_http_status(201)
      end

      it 'returns order as json' do
        prod = Order.find body['id']
        expect(body).to eq prod.as_json
      end
    end

    describe 'invalid order' do
      it 'returns 400 on missing bag name' do
        post
        expect(response).to have_http_status(400)
      end

      it 'returns 422 on invalid item' do
        post params: { order: { user_id: nil } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe '/orders/:id' do
    before :each do
      @order = create(:order, :with_items)
      @uri = "orders/#{@order.id}"
    end

    describe 'GET, shows a order' do
      it 'returns 404 on bad :id' do
        get 'orders/0'
        expect(response).to have_http_status(404)
      end

      it 'returns 200' do
        get
        expect(response).to have_http_status(200)
      end

      it 'returns as_json' do
        get
        expect(body).to eq @order.as_json(include: [items: { include: :product }])
        expect(body.keys).to include 'items'
        expect(body['items'][0].keys).to include 'price'
        expect(body['items'][0].keys).to include 'product'
        expect(body['items'][0]['product'].keys).to include 'price'
      end
    end

    describe 'PUT, updates a order' do
      it 'returns 422 with invalid data' do
        put params: { order: { user_id: 1 } }
        expect(response).to have_http_status(422)
      end

      it 'returns 200 with valid data' do
        put params: { order: { user_id: @order.user_id } }
        expect(response).to have_http_status(200)
      end
    end

    describe 'DELETE, destroys a order' do
      it 'returns 422 as items are given' do
        delete
        expect(response).to have_http_status(422)
      end

      it 'returns 204' do
        @order.items.destroy_all
        delete
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'As guest/customer' do
    before :all do
      @user = guest
      @token = sign_in(@user)
      @uri = 'orders'
    end

    describe 'GET, #index' do
      before :each do
        2.times do
          ord = create(:order, :with_items, user: @user)
          ord.checkout
          ord.confirm
        end
        get
      end

      it 'returns all ordered items' do
        expect(body.size).to be 2
      end

      it 'responds 200' do
        expect(response).to have_http_status(200)
      end
    end

    describe 'GET, #show' do
      before :each do
        @own = create(:order, :with_items, user: @user)
        @other = Order.basket_for(admin)
        @other.save
      end

      it 'returns 403 for alien users order_items' do
        get "orders/#{@other.id}"
        expect(response).to have_http_status(403)
      end

      it 'returns 200 on own order item' do
        get "orders/#{@own.id}"
        expect(response).to have_http_status(200)
        expect(body).to eq @own.as_json(include: [items: { include: :product }])
      end
    end
  end
end
