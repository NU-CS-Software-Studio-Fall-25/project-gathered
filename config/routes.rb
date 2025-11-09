Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "signup", to: "students#new"
  post "signup", to: "students#create"

  # Dashboard route (root path)
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"

  # Student profile
  resource :student, only: [:show, :edit, :update]

  # Courses and their study groups
  resources :courses, only: [ :index, :show ] do
    resources :study_groups, only: [ :index, :new, :create ]
  end

  # Study groups with member actions
  resources :study_groups, only: [ :show, :edit, :update, :destroy ] do
    member do
      post :join
      delete :leave
    end
  end

  # Student course enrollment
  resources :student_courses, only: [:create, :destroy]

  # Legacy route for backward compatibility
  resource :student_session, only: :create
end
