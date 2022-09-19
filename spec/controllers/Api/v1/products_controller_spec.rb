# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  before :all do
    @user  = admin
    @token = create_token(@user)
  end

  before :each do
    request.headers['Authorization'] = @token
  end

  let :valid_attributes do
    {
      name: 'Test',
      description: 'A poster of a contented programmer!'
    }
  end

  let :invalid_attributes do
    {
      name: nil
    }
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Product.create! valid_attributes
      get :index
      expect(response).to be_successful
    end

    it 'returns products with last price' do
      product = Product.new valid_attributes
      product.prices.build(from: DateTime.now - 1.day, value: 5)
      product.save

      get :index
      json_product = response.parsed_body.find do |hash|
        hash['id'].to_i == product.id
      end

      expect(json_product.keys).to include('price')
      expect(json_product['price'].to_i).to be 5
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      product = Product.create! valid_attributes
      get :show, params: { id: product.to_param }
      expect(response).to be_successful
    end

    it 'returns 404 on bad :id' do
      get :show, params: { id: 0 }
      expect(response).to have_http_status(404)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Product' do
        expect do
          post :create, params: { product: valid_attributes }
        end.to change(Product, :count).by(1)
      end

      it 'renders a JSON response with the new product' do
        post :create, params: { product: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response.location).to eq(api_v1_product_url(Product.last))
      end
    end

    context 'with invalid params' do
      it 'returns 400 on mssing :product' do
        post :create, params: {  }
        expect(response).to have_http_status(400)
      end

      it 'renders a JSON response with errors for the new product' do
        post :create, params: { product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          name: 'Mega tester'
        }
      end

      it 'updates the requested product' do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param, product: new_attributes }
        product.reload
        expect(product.name).to eq(new_attributes[:name])
        expect(response.parsed_body['name']).to eq(new_attributes[:name])
      end

      it 'renders a JSON response with the product' do
        product = Product.create! valid_attributes

        put :update, params: {id: product.to_param, product: valid_attributes}
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match('application/json; charset=utf-8')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the product' do
        product = Product.create! valid_attributes

        put :update, params: { id: product.to_param, product: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end

      it 'returns 400 on mssing :product' do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param }
        expect(response).to have_http_status(400)
      end

      it 'returns 404 on bad :id' do
        put :update, params: { id: 0, product: { name: 'New'} }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested product' do
      product = Product.create! valid_attributes
      expect {
        delete :destroy, params: { id: product.to_param }
      }.to change(Product, :count).by(-1)
    end
  end

  describe 'Inheritance, implicit test on ApplicationController' do
    it 'has model Product' do
      expect(described_class.model).to be Product
    end

    it 'has model_name :product' do
      expect(described_class.model_name).to be :product
    end

    it 'has permitted_params' do
      expect(subject.permitted_params).to eq valid_attributes.keys
    end
  end

  describe 'Rights: non admins cant' do
    before :all do
      @user = guest
      @token = create_token(@user)
    end

    it 'create' do
      post :create, params: { product: valid_attributes }
      expect(response).to have_http_status(:forbidden)
    end

    it 'update' do
      product = Product.create! valid_attributes
      put :update, params: { id: product.to_param, product: { name: 'New name'} }
      expect(response).to have_http_status(:forbidden)
    end

    it 'destroy' do
      product = Product.create! valid_attributes
      delete :destroy, params: { id: product.to_param }
      expect(response).to have_http_status(:forbidden)
    end
  end
end
