Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { :passwords => 'passwords' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    root to: "devise/sessions#new"
  end

  namespace :api do
    namespace :v1 do
      resources :users do
        member do
          put :update_password
          get :user_report
        end
        collection do
          put :forgot_password
        end
      end
      resources :questions do
        collection do
          # get 'today_question' => 'questions#today_question'
          get :today_question
          get :previous_questions
          get :random_questions
        end

      end
      resources :sessions
      resources :user_answers
    end
  end

end
