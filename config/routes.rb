Rails.application.routes.draw do

  get 'bases/new'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  patch 'month_approvals/update_month_approvals'
  resources :bases
  resources :users do
    get :search, on: :collection
    post :import, on: :collection
    get :working_members, on: :collection
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_request_one_month_change'
      patch 'attendances/request_one_month_change'
      get 'attendances/request_one_month_change'
      patch 'attendances/approval_one_month_change'
      get 'attendances/edit_approval_one_month_change'
      patch 'attendances/request_overwork'
      get 'attendances/edit_request_overwork'
      patch 'attendances/approval_overwork'
      get 'attendances/edit_approval_overwork'
      get 'csv_output'
      get 'show_reference'
      get 'show_reference_change_or_overwork'
    end
    resources :attendances, only: :update
    resources :month_approvals, only: [:create, :update, :edit]
  end
end
