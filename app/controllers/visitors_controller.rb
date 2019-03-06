class VisitorsController < ApplicationController
    def index
        redirect_to SpotifyService.new(SpotifyUser.first).create_auth_url
    end
end
