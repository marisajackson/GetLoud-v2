class UsersController < ApplicationController

    def set_metro_area
      metro_area = params[:metroArea]

      event = Event.find_by(metro_area: metro_area)

      if(!event)
        EventImportJob.perform_later metro_area
      end

      spotify_auth_url = SpotifyService.new(SpotifyUser.first).create_auth_url({metro_area: metro_area})

      render :json => {spotify_auth_url: spotify_auth_url}, status: :ok
    end
end
