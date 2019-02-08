Rails.application.routes.draw do
  
  devise_for :users
  resources :moodle_details
  resources :report_runs, only: [:index]
  resources :reports, only: [:show, :index] do
    collection do
      post 'notify_teacher'
      post 'notify_teacher_graded'
      post 'notify_teacher_signin'
      get 'dl_csv_graded'
    end
  end

  get 'home/index'

  post 'home/generate_notgraded_report'
  # get 'show_notgraded_report', to: 'home#show_notgraded_report'

  post 'home/generate_graded_report'
  # get 'home/show_graded_report'

  post 'home/generate_signin_report'
  
  root to: 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end
