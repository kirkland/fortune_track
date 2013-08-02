PersonalAccounting::Application.routes.draw do
  resources :accounts, except: [:destroy]

  resources :transactions, except: [:destroy] do
    collection do
      get :new_cash
      post :create_cash
    end
  end

  resources :reports, only: [] do
    collection do
      get :expense_report
      get :income_report
      get :net_worth_report
    end
  end

  resources :account_imports, only: [:new, :create]

  root :to => 'accounts#index'
end
