class SpotifyUserArtist < ApplicationRecord
  belongs_to :spotify_user
  belongs_to :artist
end
