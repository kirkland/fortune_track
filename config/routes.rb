PersonalAccounting::Application.routes.draw do
  resources :accounts
  resources :transactions

  root :to => 'accounts#index'
end
