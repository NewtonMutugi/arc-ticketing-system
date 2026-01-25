Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  scope module: :public do
    root "events#index"

    resources :events, only: [ :show ] do
      resources :orders, only: [ :new, :create, :show ], param: :order_no do
        get "attendees", to: "orders#attendees"
        patch "confirm", to: "orders#confirm"
        get "checkout", to: "orders#checkout"
        patch "pay", to: "orders#pay"
      end
    end
  end

  namespace :admin do
    root "dashboard#index"

    resource :session
    resources :passwords, param: :token

    resources :events do
      resources :tickets
      resources :attendees
      resources :orders, param: :order_no do
        member do
          patch :approve
          patch :disapprove
        end
      end
      resources :transactions, only: [ :index ]
    end

    resource :profile, only: [ :show, :update ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
