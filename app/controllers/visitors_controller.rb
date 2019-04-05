class VisitorsController < ApplicationController
    def index
      if user_signed_in?
        if current_user.metro_area && current_user.metro_area != ''
          spotify_user = SpotifyUser.includes(:artists => :events).where(artists: {events: {metro_area: current_user.metro_area}}).find_by(user_id: current_user.id)
          @events = nil
          @playlist_url = nil
          if spotify_user && spotify_user.artists
            @events = spotify_user.artists.sort_by {|obj| obj.events[0].date}
            # https://open.spotify.com/user/oreolistens/playlist/3tCx3pnNsPKT6PsFKWygKo?si=VeLQcvdzRmupI_lNW415iA
            playlist = Playlist.find_by(spotify_user_id: spotify_user.id)
            if(playlist)
              @playlist_url = "https://open.spotify.com/user/#{spotify_user.spotify_id}/playlist/#{playlist.spotify_id}"
            end
          end

          render "users/home"
        else
          render "users/setup"
        end
      else
        @spotify_auth_url = SpotifyService.new(SpotifyUser.first).create_auth_url
      end
    end
end
