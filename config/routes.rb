Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users

  get 'spotify/login', to: 'spotify#login'
  get 'events/ticketmaster', to: 'event#ticketmaster'
end
