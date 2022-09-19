require 'rails_helper'

RSpec.describe Api::V1::BasketController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/basket').to route_to('api/v1/basket#index')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/basket').to route_to('api/v1/basket#destroy')
    end

    it 'routes to #checkout' do
      expect(get: '/api/v1/basket/checkout').to route_to('api/v1/basket#checkout')
    end

    it 'routes to #confirm' do
      expect(put: '/api/v1/basket/checkout/confirm').to route_to('api/v1/basket#confirm')
    end

    it 'routes to #update' do
      expect(put: '/api/v1/basket/product/1').to route_to('api/v1/basket#update', id: '1')
    end

    it 'routes to #buy' do
      expect(put: '/api/v1/basket/product/1/buy').to route_to('api/v1/basket#buy', id: '1')
    end

    it 'routes to #sell' do
      expect(put: '/api/v1/basket/product/1/sell').to route_to('api/v1/basket#sell', id: '1')
    end

    it 'routes to #remove' do
      expect(delete: '/api/v1/basket/product/1').to route_to('api/v1/basket#remove', id: '1')
    end
  end
end
