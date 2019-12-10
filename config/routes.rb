Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users

  get 'email', to: 'visitors#email'

  get 'spotify/login', to: 'spotify#login'
  put 'users/metro-area', to: 'users#set_metro_area'

  get 'admin/mailer/weekly_update', to: 'admin/mailer#weekly_update'
end
