require 'rails_helper'

RSpec.describe Api::V1::OrderItemsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/order_items').to route_to('api/v1/order_items#index')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/order_items/1').to route_to('api/v1/order_items#show', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/order_items').to route_to('api/v1/order_items#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/order_items/1').to route_to('api/v1/order_items#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/order_items/1').to route_to('api/v1/order_items#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/order_items/1').to route_to('api/v1/order_items#destroy', id: '1')
    end
  end
end
