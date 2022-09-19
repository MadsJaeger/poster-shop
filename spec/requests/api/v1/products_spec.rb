require 'rails_helper'

RSpec.describe '/products', type: :request do
  include AuthHelpers::RequestHelpers

  before :all do
    @uri   = 'products'
    @user  = admin
    @token = sign_in(@user)
  end

  describe 'GET, listing products' do
    before :each do
      @products = create_list(:product, 5, price_count: 1)
      get
    end

    it 'it returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'it returns all products' do
      expect(body.size).to be Product.count
    end

    it 'returns product as json' do
      expect(body).to eq Product.all.as_json
    end
  end

  describe 'POST, creating a product' do
    describe 'Valid product' do
      before :each do
        @prod = build(:product).slice(:name, :description)
        post params: { product: @prod }
      end

      it 'returns 200' do
        expect(response).to have_http_status(201)
      end

      it 'returns product as json' do
        prod = Product.find body['id']
        expect(body).to eq prod.as_json
      end
    end

    describe 'invalid product' do
      it 'returns 400 on missing bag name' do
        post
        expect(response).to have_http_status(400)
      end

      it 'returns 422 on invalid item' do
        post params: { product: { description: 'Ups!' } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe '/products/:id' do
    before :each do
      @product = create(:product)
      @uri = "products/#{@product.id}"
    end

    describe 'GET, shows a product' do
      it 'returns 404 on bad :id' do
        get 'products/0'
        expect(response).to have_http_status(404)
      end

      it 'returns 200' do
        get
        expect(response).to have_http_status(200)
      end

      it 'returns as_json, with prices' do
        get
        expect(body).to eq @product.as_json(include: :prices)
      end
    end

    describe 'PUT, updates a product' do
      it 'returns 422 with invalid data' do
        put params: { product: { name: nil } }
        expect(response).to have_http_status(422)
      end

      it 'returns 200 with valid data' do
        put params: { product: { name: 'New name' } }
        expect(response).to have_http_status(200)
      end
    end

    describe 'DELETE, destroys a product' do
      it 'returns 422 as prices are given' do
        delete
        expect(response).to have_http_status(422)
      end

      it 'returns 204, when prices has been destroyed' do
        @product.prices.destroy_all
        delete
        expect(response).to have_http_status(204)
      end
    end
  end
end
