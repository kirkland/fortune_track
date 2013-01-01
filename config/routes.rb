PersonalAccounting::Application.routes.draw do
  resources :accounts, except: [:show]
  resources :transactions do
    collection do
      get :new_cash
      post :create_cash
    end
  end

  resources :reports, only: [:none] do
    collection do
      get :expense_report
    end
  end

  root :to => 'reports#expense_report'
end
