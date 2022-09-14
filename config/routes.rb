Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Authentication
  post   'auth/sign_up',  controller: :authentication, action: :sign_up
  post   'auth/sign_in',  controller: :authentication, action: :sign_in
  delete 'auth/sign_out', controller: :authentication, action: :sign_out
  get    'auth/ping',     controller: :authentication, action: :ping
end
