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

        # spotify_user = SpotifyUser.find_or_create_by(
        #     spotify_id: user_params['id']
        #     display_name: user_params['display_name']
        #     email: user_params['email']
        # )
        #
        # spotify_user.update(
        #     access_token: auth_params['access_token']
        #     refresh_token: auth_params['refresh_token']
        # )

        render :json => user_params
    end
end
