Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users

  get 'spotify/login', to: 'spotify#login'
  put 'users/metro-area', to: 'users#set_metro_area'
end
