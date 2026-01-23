Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  resource :users, only: [ :new, :create ]
  resource :sessions, only: [ :new, :create ]
  resources :events
  resources :categories
  resources :purchases, only: [ :index ]

  get "signup", to: "users#new"
  get "login", to: "sessions#new"
  delete "logout", to: "sessions#destroy"

  root "dashboard#index"

  namespace :api do
    namespace :v1 do
      post "register", to: "auth#register"
      post "login", to: "auth#login"

      resources :events, only: [ :index, :show ] do
        resources :tickets, only: [] do
          resources :purchases, only: [ :create ]
        end
        resources :comments, only: [ :index, :create ]
      end
    end
  end
end
