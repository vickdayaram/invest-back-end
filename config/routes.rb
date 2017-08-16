Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post '/signup', to: 'users#create'
      post '/login', to: 'auth#create'
      post '/newaccount', to: 'accounts#create'
      get '/getaccounts', to: 'accounts#show'
      get '/me', to: 'users#show'
      get '/holdings', to: 'holdings#show'
      post '/transact', to: 'transactions#create'
      get '/transactions', to: 'transactions#show'
    end
  end
end
