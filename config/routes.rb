Rails.application.routes.draw do
  get "webhooks/mpesa"
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
        get "status", to: "orders#status", on: :member
      end
    end
  end

  namespace :admin do
    get "verifications/show"
    root "dashboard#index"
    resource :settings, only: [ :show, :update ]
    resources :users, only: [ :create, :destroy ]

    # resource :session
    get "login",  to: "sessions#new",     as: :new_session
    post "login",  to: "sessions#create",  as: :session
    delete "logout", to: "sessions#destroy", as: :destroy_session
    resources :passwords, param: :token

    resources :events do
      resources :tickets
      resources :attendees
      resources :orders, param: :order_no do
        member do
          patch :approve
          patch :disapprove
          post :resend_confirmation_email
          patch :reject_payment
        end
      end
      resources :transactions, only: [ :index ]
    end

    resource :profile, only: [ :show, :update ]
    get "verify/:token", to: "verifications#show", as: :verify_attendee
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  post "webhooks/mpesa", to: "webhooks#mpesa"

  post "paypal/create_order", to: "paypal#create_order"
  post "paypal/capture_order", to: "paypal#capture_order"
end
