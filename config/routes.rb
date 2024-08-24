Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  post 'auth/google', to: 'sessions#google'

  resources :users do
    member do
      get 'get_users_group'
    end
    collection do
      get 'users_with_name'
    end
  end
  resources :groups do
    member do
      get 'get_group_users'
      get 'expenses'
      get 'balances'
      get 'settle_up'
    end
  end
  resources :expenses
  resources :settles
end
