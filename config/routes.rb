Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path - courses listing
  root "courses#index"

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

  # Student profiles
  resources :students, only: [ :show, :edit, :update ]

  resource :student_session, only: :create
end
