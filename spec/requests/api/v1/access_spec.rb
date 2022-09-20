require 'rails_helper'

class RouteProxy
  attr_reader :route

  def initialize(route)
    @route = route
  end

  def inspect
    "RouteProxy ##{to_s} controller: #{controller_string}, action: #{action}"
  end

  def controller_string
    route.defaults[:controller]
  end

  def api?
    controller_string[0..5] == 'api/v1' if controller_string
  end

  def auth?
    controller_string == 'api/v1/authentication'
  end

  def action
    route.defaults[:action]
  end

  def http_verb
    route.verb
  end

  def http_action
    http_verb.downcase
  end

  def path
    route.path.spec.to_s.gsub('(.:format)', '')
  end

  def uri
    path.gsub(':id', '1').gsub('/api/v1/', '')
  end

  def to_s
    "#{http_verb}::#{path}"
  end
end

class Routes
  def proxies
    @proxies ||= Rails.application.routes.routes.map do |route|
                  RouteProxy.new(route)
                end.reject do |route|
                  route.http_verb == 'PATCH'
                end
  end

  def api_routes
    proxies.select(&:api?)
  end

  def auth_routes
    proxies.select(&:auth?)
  end

  def protected_routes
    api_routes - auth_routes
  end

  def cud_routes
    api_routes.reject do |proxy|
      proxy.controller_string == 'api/v1/basket'
    end.select do |proxy|
      %i[create update destroy].include?(proxy.action.to_sym)
    end
  end
end
routes = Routes.new

##
# Assuming that other tests exists confirming 2xx responses for authorized users
# we now ensure that untauhtorized/prohibited access recive 40(1/3).
#
# Suggestion: maybe hardcoding all routes and expected response for each 
# type of user. Then adding routes requires elobaration on this list and ensures 
# no route is missed, as well as violations to convention can happen.
RSpec.describe 'Access Rights', type: :request do
  include AuthHelpers::RequestHelpers

  describe 'Unauthorized users recieves 401 at' do
    routes.protected_routes.each do |proxy|
      it proxy.to_s do
        send(proxy.http_action, proxy.uri)
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'Guests recives 403 at' do
    before :all do
      @user = guest
      @token = sign_in(@user)
    end

    routes.cud_routes.each do |proxy|
      it proxy.to_s do
        send(proxy.http_action, proxy.uri)
        expect(response).to have_http_status(403)
      end
    end
  end
end

# default_access: {
#   index:   {guest: 200, admin: 200}
#   create:  {guest: 403, admin: :skip}
#   sow:     {guest: 403, admin: 200}
#   update:  {guest: 403, admin: 200}
#   destroy: {guest: 403, admin: 204}
# }
# access = {
#   products: {
#     index:   {}
#     create:  {}
#     sow:     {}
#     update:  {}
#     destroy: {}
#   },
#   prices: {
#     index:   {}
#     create:  {}
#     sow:     {}
#     update:  {}
#     destroy: {}
#   },
#   orders: {
#     index:   {}
#     create:  {}
#     sow:     {}
#     update:  {}
#     destroy: {}
#   },
#   order_items: {
#     index:   {}
#     create:  {}
#     sow:     {}
#     update:  {}
#     destroy: {}
#   },
#   basket: {
#     index:    {}
#     update:   {}
#     buy:      {}
#     sell:     {}
#     checkout: {}
#     confirm:  {}
#     destroy:  {}
#   }
# }
