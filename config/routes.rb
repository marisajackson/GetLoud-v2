Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users

  get 'spotify/login', to: 'spotify#login'
  get 'spotify/artists', to: 'spotify#artists'
  get 'spotify/user/artists', to: 'spotify#user_artists'

  get 'events/ticketmaster', to: 'event#ticketmaster'
end
