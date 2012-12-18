PersonalAccounting::Application.routes.draw do
  resources :accounts, except: [:show]
  resources :transactions

  root :to => 'accounts#index'
end
