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
      @order = create(:order)
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
        expect(body).to eq @order.as_json
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
        create(:order_item, order: @order, user: nil)
        delete
        expect(response).to have_http_status(422)
      end

      it 'returns 204' do
        delete
        expect(response).to have_http_status(204)
      end
    end
  end
end
