class VisitorsController < ApplicationController
    def index
      if user_signed_in?
        if current_user.metro_area && current_user.metro_area != ''
          spotify_user = SpotifyUser.find_by(user_id: current_user.id)

          @events = Event.where(metro_area: current_user.metro_area).includes(:artists => :spotify_users).where(artists: {spotify_users: {user_id: current_user.id}}).order(:date)
          @events.each do |event|
            event.supporting_artists = nil
            supporting_artists = []
            event.artists.each do |artist|
              if !event.name.include? artist.name
                supporting_artists.push(artist.name)
                event.supporting_artists = supporting_artists.join(", ")
              end
            end
          end

          # https://open.spotify.com/user/oreolistens/playlist/3tCx3pnNsPKT6PsFKWygKo?si=VeLQcvdzRmupI_lNW415iA
          playlist = Playlist.find_by(spotify_user_id: spotify_user.id)
          if(playlist)
            @playlist_url = "https://open.spotify.com/user/#{spotify_user.spotify_id}/playlist/#{playlist.spotify_id}"
          end

          # @playlist_url = nil

          render "users/home"
        else
          render "users/setup"
        end
      else
        @spotify_auth_url = SpotifyService.new(SpotifyUser.first).create_auth_url
      end
    end

    def email
      user = current_user
      spotify_user = current_user.spotify_user
      artists = Event.where(metro_area: user.metro_area)
                    .includes(:artists => :spotify_user_artists)
                    .includes(:artists => :playlist_tracks)
                    .where(spotify_user_artists: {spotify_user_id: spotify_user.id})
                    .where('events.created_at <= ?', 6.days.ago)
                    .order('playlist_tracks.created_at')
                    .limit(6)
              # .order('playlist_tracks.created_at desc')
              # .distinct()

    render :json => {sql: artists.to_sql, artists: artists}

      # UserMailer.weekly_update(current_user, current_user.spotify_user, true).deliver

      # artists = Artist.includes(:spotify_users)
      #         .includes(:events)
      #         .includes(:playlist_tracks => :playlist)
      #         .where('events.created_at >= ?', 2.days.ago)
      #         .where(playlist_tracks: {playlists: {spotify_user_id: current_user.spotify_user.id}})
      #         .where(spotify_users: {user_id: current_user.id})
      #         .order('playlist_tracks.created_at desc')
      #         .limit(3)
      #
      # render :json => artists

      # @city = current_user.metro_area;
      # @this_week = Event.where(metro_area: current_user.metro_area)
      #               .includes(:artists => :spotify_users)
      #               .where(artists: {spotify_users: {user_id: current_user.id}})
      #               .where("date <= ?", 7.days.from_now)
      #               .order(:date)
      #
      # @new_additions = Event.where(metro_area: current_user.metro_area)
      #               .includes(:artists => :spotify_users)
      #               .includes(:artists => :playlist_tracks)
      #               .where(artists: {spotify_users: {user_id: current_user.id}})
      #               .where("date >= ?", 7.days.from_now)
      #               .order('playlist_tracks.created_at')
      #               .limit(10)
      #
      # @popular = Event.select("events.*, count(playlist_tracks.*) as count")
      #               .joins(:artists => :playlist_tracks)
      #               .where(metro_area: current_user.metro_area)
      #               .group('events.id, playlist_tracks.artist_id')
      #               .order(Arel.sql('COUNT(playlist_tracks.artist_id) DESC'))
      #               .limit(10)
      #
      # render "users/email"
    end
end
