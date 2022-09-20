Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      scope 'auth', controller: :authentication do
        post   'sign_up',  action: :sign_up
        post   'sign_in',  action: :sign_in
        delete 'sign_out', action: :sign_out
        get    'ping',     action: :ping
      end
    
      resources :products
      resources :prices
      resources :orders
      resources :order_items
      resources :users
    
      scope '/basket', controller: :basket do
        get    '', action: 'index'
        delete '', action: :destroy
        get    'checkout'
        put    'checkout/confirm', action: :confirm
        scope 'product' do
          put    ':id',      action: :update
          put    ':id/buy',  action: :buy
          put    ':id/sell', action: :sell
          delete ':id',      action: :remove
        end
      end
    end
  end
end