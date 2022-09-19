require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :routing do
  describe 'routing' do
    it 'routes to #sign_up' do
      expect(post: '/api/v1/auth/sign_up').to route_to('api/v1/authentication#sign_up')
    end

    it 'routes to #sign_in' do
      expect(post: '/api/v1/auth/sign_in').to route_to('api/v1/authentication#sign_in')
    end

    it 'routes to #sign_out' do
      expect(delete: '/api/v1/auth/sign_out').to route_to('api/v1/authentication#sign_out')
    end

    it 'routes to #ping' do
      expect(get: '/api/v1/auth/ping').to route_to('api/v1/authentication#ping')
    end
  end
end
