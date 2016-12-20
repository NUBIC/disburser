Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :repositories do
    resources :repository_users
    resources :specimen_types, only: :index do
      collection do
        patch 'bulk_update'
      end
    end

    member do
      get :download_file
    end
  end

  resources :users, only: :index

  root 'repositories#index'
end
