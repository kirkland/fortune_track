PersonalAccounting::Application.routes.draw do
  resources :accounts, except: [:show]
  resources :transactions

  resources :reports, only: [:none] do
    collection do
      get :expense_report
    end
  end

  root :to => 'accounts#index'
end
