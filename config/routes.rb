require 'sidekiq/web'
Rails.application.routes.draw do
  root to: 'visitors#index'
  get 'sign-up', to: 'visitors#sign_up'
  devise_for :users

  get 'email', to: 'visitors#email'

  get 'spotify/login', to: 'spotify#login'
  put 'users/metro-area', to: 'users#set_metro_area'

  get 'admin/mailer/weekly_update', to: 'admin/mailer#weekly_update'

  get 'logout', to: 'visitors#logout'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    usernameEnc = Rails.application.credentials[Rails.env.to_sym][:sidekiq][:username]
    passwordEnc = Rails.application.credentials[Rails.env.to_sym][:sidekiq][:password]
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(usernameEnc)) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(passwordEnc))
  end
  mount Sidekiq::Web, at: '/sidekiq'
end
