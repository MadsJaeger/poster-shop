require 'rails_helper'

RSpec.describe '/prices', type: :request do
  include AuthHelpers::RequestHelpers

  before :all do
    @uri   = 'prices'
    @user  = admin
    @token = sign_in(@user)
  end

  describe 'GET, list prices' do
    before :each do
      @items = create_list(:price, 5)
      get
    end

    it 'it returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'it returns all prices' do
      expect(body.size).to be Price.count
    end

    it 'returns prices as json' do
      expect(body).to eq Price.all.as_json
    end
  end

  describe 'POST, creating a price' do
    describe 'Valid price' do
      before :each do
        @product = create(:product, price_count: 0)
        @price = build(:price, product: @product).slice(:value, :from, :product_id)
        post params: { price: @price }
      end

      it 'returns 200' do
        expect(response).to have_http_status(201)
      end

      it 'returns price as json' do
        px = Price.find body['id']
        expect(body).to eq px.as_json
      end
    end

    describe 'invalid price' do
      it 'returns 400 on missing bag name' do
        post
        expect(response).to have_http_status(400)
      end

      it 'returns 422 on invalid item' do
        post params: { price: { value: nil } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe '/prices/:id' do
    before :each do
      @price = create(:price)
      @uri = "prices/#{@price.id}"
    end

    describe 'GET, shows a price' do
      it 'returns 404 on bad :id' do
        get 'prices/0'
        expect(response).to have_http_status(404)
      end

      it 'returns 200' do
        get
        expect(response).to have_http_status(200)
      end

      it 'returns as_json' do
        get
        expect(body).to eq @price.as_json
      end
    end

    describe 'PUT, updates a price' do
      it 'returns 422 with invalid data' do
        put params: { price: { value: nil } }
        expect(response).to have_http_status(422)
      end

      it 'returns 200 with valid data' do
        put params: { price: { value: 5 } }
        expect(response).to have_http_status(200)
      end
    end

    describe 'DELETE, destroys a price' do
      it 'returns 204' do
        delete
        expect(response).to have_http_status(204)
      end
    end
  end
end
