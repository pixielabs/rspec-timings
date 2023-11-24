require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  root 'projects#index'

  namespace :webhooks do
    post '/github', to: 'github#create'
  end

  resources :projects do
    member do
      get :settings
      get :compare
    end
    resources :test_runs, only: :create
    resources :test_cases, only: :show
  end
end
