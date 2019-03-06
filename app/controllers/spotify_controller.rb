class SpotifyController < ApplicationController

    def login
        if params[:error] || !params[:state] || params[:state] != Rails.application.credentials.secret_key_base
            return
        end

        body = {
            grant_type: 'authorization_code',
            code: params[:code],
            client_id: Rails.application.credentials.spotify[:client_id],
            client_secret: Rails.application.credentials.spotify[:secret],
            redirect_uri: Rails.application.credentials.spotify[:redirect_uri],
        }

        auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)

        auth_params = JSON.parse(auth_response.body)

        header = { Authorization: "Bearer #{auth_params['access_token']}" }

        user_response = RestClient.get('https://api.spotify.com/v1/me', header)

        user_params = JSON.parse(user_response.body)

        generated_password = Devise.friendly_token.first(8)

        user = User.find_or_initialize_by('email': user_params['email'])
        user.password = generated_password
        user.password_confirmation = generated_password
        user.save!

        spotify_user = SpotifyUser.find_or_create_by(spotify_id: user_params['id'])
        spotify_user.display_name = user_params['display_name']
        spotify_user.user_id = user.id
        spotify_user.email = user_params['email']
        spotify_user.access_token = auth_params['access_token']
        spotify_user.refresh_token = auth_params['refresh_token']
        spotify_user.expires_at = Time.now.advance(seconds: auth_params['expires_in'])
        spotify_user.save!

        SpotifyUserSetUpJob.perform_later spotify_user

        render :json => spotify_user
    end

    def artists
      spotify_users = SpotifyUser.all

      spotify_users.each do |spotify_user|
        SpotifyUserSetUpJob.perform_later spotify_user
      end

      render :json => spotify_users
    end
end
