Rails.application.routes.draw do
  # Authentication
  post   'auth/sign_up',  controller: :authentication, action: :sign_up
  post   'auth/sign_in',  controller: :authentication, action: :sign_in
  delete 'auth/sign_out', controller: :authentication, action: :sign_out
  get    'auth/ping',     controller: :authentication, action: :ping

  resources :products
  resources :prices
  resources :orders
  resources :order_items
end
