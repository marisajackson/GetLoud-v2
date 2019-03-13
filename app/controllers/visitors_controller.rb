class VisitorsController < ApplicationController
    def index
      if user_signed_in?
        if current_user.metro_area
          render "home"
        else
          render "users/setup"
        end
      else
        @spotify_auth_url = SpotifyService.new(SpotifyUser.first).create_auth_url
      end
    end
end
