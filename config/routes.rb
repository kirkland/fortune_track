PersonalAccounting::Application.routes.draw do
  resources :accounts, except: [:show, :destroy]

  resources :transactions, except: [:destroy] do
    collection do
      get :new_cash
      post :create_cash
    end
  end

  resources :reports, only: [] do
    collection do
      get :expense_report
    end
  end

  root :to => 'reports#expense_report'
end
