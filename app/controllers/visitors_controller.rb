class VisitorsController < ApplicationController
    def index
        query_params = {
            response_type: 'code',
            client_id: Rails.application.credentials.spotify[:client_id],
            scope: 'user-read-private user-read-email playlist-modify-public playlist-modify-private',
            redirect_uri: Rails.application.credentials.spotify[:redirect_uri],
            # TODO state: state
        }

        redirect_to "https://accounts.spotify.com/authorize?#{query_params.to_query}"
    end
end
