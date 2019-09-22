class SpotifyService
  def initialize(spotify_user)
    @spotify_user = spotify_user

    if @spotify_user && (!@spotify_user.expires_at || @spotify_user.expires_at <= Time.now)
      auth_creds = "#{Rails.application.credentials[Rails.env.to_sym][:spotify][:client_id]}:#{Rails.application.credentials[Rails.env.to_sym][:spotify][:secret]}"

      header = { Authorization: "Basic #{Base64.strict_encode64(auth_creds)}" }

      body = {
        grant_type: 'refresh_token',
        refresh_token: @spotify_user.refresh_token,
      }

      auth_response = RestClient.post('https://accounts.spotify.com/api/token', body, header)

      auth_params = JSON.parse(auth_response.body)

      @spotify_user.access_token = auth_params['access_token']
      @spotify_user.expires_at = Time.now.advance(seconds: auth_params['expires_in'])
      @spotify_user.save!
    end
  end

  def create_auth_url
    query_params = {
       response_type: 'code',
       client_id: Rails.application.credentials[Rails.env.to_sym][:spotify][:client_id],
       scope: 'user-read-private user-read-email playlist-modify-public playlist-modify-private user-top-read',
       redirect_uri: Rails.application.credentials[Rails.env.to_sym][:spotify][:redirect_uri],
       state: Rails.application.credentials[Rails.env.to_sym][:secret_key_base]
    }

    return "https://accounts.spotify.com/authorize?#{query_params.to_query}"
  end

  def sync_user_artists
    header = { Authorization: "Bearer #{@spotify_user.access_token}" }

    # GET https://api.spotify.com/v1/me/top/artists (tracks is also available)

    time_ranges = ['short_term', 'long_term', 'medium_term']
    artists = nil

    time_ranges.each do |range|
      query_params = {
        limit: 50,
        time_range: range
      }

      artists_response = RestClient.get("https://api.spotify.com/v1/me/top/artists?#{query_params.to_query}", header)

      artists = JSON.parse(artists_response.body)
      artists = artists['items']

      artists.each do |artist|
        gl_artist = Artist.find_by(name: artist['name'])
        if gl_artist
          gl_artist.spotify_id = artist['id']
          gl_artist.save!
          # genres = artist['genres']

          user_artist = SpotifyUserArtist.where(spotify_user_id: @spotify_user.id)
                       .where(artist_id: gl_artist.id)
                       .first

          if !user_artist
            user_artist = SpotifyUserArtist.new
            user_artist.spotify_user_id = @spotify_user.id
            user_artist.artist_id = gl_artist.id
          end

          user_artist.relation_type = "direct"
          user_artist.save!
        end
      end
    end
  end

  def sync_user_related_artists
    spotify_user = SpotifyUser.includes(:direct_artists).find_by(id: @spotify_user.id)
    artists = spotify_user.direct_artists
    header = {Authorization: "Bearer #{spotify_user.access_token}"}

    # GET https://api.spotify.com/v1/artists/:artistID/related-artists

    artists.each do |artist|
      artist_response = RestClient.get("https://api.spotify.com/v1/artists/#{artist.spotify_id}/related-artists", header)

      related_artists = JSON.parse(artist_response.body)
      related_artists = related_artists['artists']

      # TODO this is repeated except the relation type and user genre. that's a problem
      related_artists.each do |related_artist|
        gl_artist = Artist.find_by(name: related_artist['name'])
        if gl_artist
          gl_artist.spotify_id = related_artist['id']
          gl_artist.save!
          # genres = related_artist['genres']

          user_artist = SpotifyUserArtist.where(spotify_user_id: @spotify_user.id)
                       .where(artist_id: gl_artist.id)
                       .first

          if !user_artist
            user_artist = SpotifyUserArtist.new
            user_artist.spotify_user_id = @spotify_user.id
            user_artist.artist_id = gl_artist.id
            user_artist.relation_type = "related"
            user_artist.save!
          end
        end
      end
    end
  end

  def update_playlist
    user = User.find_by_id(@spotify_user.user_id)
    spotify_user = SpotifyUser.includes(:artists => :events).where(artists: {events: {metro_area: user.metro_area}}).find_by(id: @spotify_user.id)
    artists = spotify_user.artists
    header = {Authorization: "Bearer #{spotify_user.access_token}"}

    playlist = Playlist.where('spotify_user_id = ?', spotify_user.id).last

    if(!playlist)
      # POST https://api.spotify.com/v1/users/{user_id}/playlists
      playlist_params = {
        name: 'ConcertWire',
        description: 'Created by ConcertWire. This playlist includes songs from artists with concerts coming up in your area. To buy tickets to these concerts, visit concertwire.live'
      }

      playlist_response = RestClient.post("https://api.spotify.com/v1/users/#{spotify_user.spotify_id}/playlists", playlist_params.to_json, header)

      playlist_response = JSON.parse(playlist_response)

      playlist = Playlist.new
      playlist.spotify_user_id = spotify_user.id
      playlist.spotify_id = playlist_response['id']
      playlist.last_updated_at = Time.now
      playlist.save!
    else
      playlist_params = { uris: [] }
      playlist_response = RestClient.put("https://api.spotify.com/v1/playlists/#{playlist.spotify_id}/tracks", playlist_params.to_json, header)

      playlist.last_updated_at = Time.now
      playlist.save!
    end

    all_tracks = []
    track_ids = Array.new
    new_artists = []

    tracks = nil

    artists.each_with_index do |item, index|
        track_params = {country: 'US'}
        # GET https://api.spotify.com/v1/artists/{id}/top-tracks
        track_response = RestClient.get("https://api.spotify.com/v1/artists/#{item.spotify_id}/top-tracks?#{track_params.to_query}", header)
        tracks = JSON.parse(track_response)
        tracks = tracks['tracks']
        tracks.each_with_index do |track, i|
          if(i < 2)
            track_ids = track_ids.push(track['id'])
            playlist_track = PlaylistTrack.where('playlist_id = ?', playlist.id)
                                          .where('artist_id = ?', item.id)
                                          .where('spotify_track_id = ?', track['id'])
                                          .first

            if(!playlist_track)
              playlist_track = PlaylistTrack.new
              playlist_track.playlist_id = playlist.id
              playlist_track.spotify_track_id = track['id']
              playlist_track.artist_id = item.id
              playlist_track.save!

              new_artists.push(item.id);
            end
            all_tracks.push(track['uri'])
          end
        end
    end

    # Destroys removed tracks
    PlaylistTrack.where(playlist_id: playlist.id).where.not(spotify_track_id: track_ids).destroy_all

    # Destroys track duplicates
    tracks = PlaylistTrack.where(playlist_id: playlist.id).all
    tracks.each do |t|
      # t.dedupe(:playlist_id, :spotify_track_id);
    end

    all_tracks = all_tracks.shuffle.uniq
    all_tracks = all_tracks.each_slice(100).to_a


    all_tracks.each do |tracklist|
      # POST https://api.spotify.com/v1/playlists/{playlist_id}/tracks
      playlist_track_params = { uris: tracklist }

      RestClient.post("https://api.spotify.com/v1/playlists/#{playlist.spotify_id}/tracks", playlist_track_params.to_json, header)
    end
  end

  def update_artist(artist_item)
    # https://api.spotify.com/v1/search
    header = { Authorization: "Bearer #{@spotify_user.access_token}" }

    query_params = {
      q: artist_item.name,
      type: 'artist'
    }

    artist_response = RestClient.get("https://api.spotify.com/v1/search?#{query_params.to_query}", header)

    artist = JSON.parse(artist_response.body)
    artist = artist['artists']['items'][0]

    if artist
      artist_item.spotify_id = artist['id']
      artist_item.save!
      genres = artist['genres']

      if genres
        genres.each do |genre|
          gl_genre = Genre.find_or_create_by(name: genre)
          artist_genre = ArtistGenre.where(genre_id: gl_genre.id)
                       .where(artist_id: artist_item.id)
                       .first

          if !artist_genre
            artist_genre = ArtistGenre.new
            artist_genre.genre_id = gl_genre.id
            artist_genre.artist_id = artist_item.id
            artist_genre.save!
          end
        end
      end
    end
  end
end
